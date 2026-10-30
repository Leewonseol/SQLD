-- ex06 선언적 제약조건만으로 구현할 수 없는 업무 규칙  | SQL Server
DROP TABLE IF EXISTS m01_loan6;
CREATE TABLE m01_loan6 (loan_id INT PRIMARY KEY, member_id INT NOT NULL, loan_dt DATE NOT NULL, return_dt DATE,
                        CONSTRAINT ck_m01_loan6_dt CHECK (return_dt >= loan_dt));
GO
PRINT N'== [Q1] R5 CHECK';
GO
-- @expect-error: MSG-547
INSERT INTO m01_loan6 VALUES (1, 7, '2024-03-10', '2024-03-01');
GO
PRINT N'== [Q2] CHECK 안에 서브쿼리 -> 오류';
GO
-- @expect-error: MSG-1046
ALTER TABLE m01_loan6 ADD CONSTRAINT ck_m01_loan6_max3 CHECK ((SELECT COUNT(*) FROM m01_loan6 x WHERE x.member_id = member_id AND x.return_dt IS NULL) <= 3);
GO
PRINT N'== [Q3] 제약만으로는 4번째 대출이 들어간다';
BEGIN TRAN;
INSERT INTO m01_loan6 VALUES (11, 7, '2024-03-01', NULL), (12, 7, '2024-03-01', NULL), (13, 7, '2024-03-01', NULL), (14, 7, '2024-03-01', NULL);
SELECT member_id, COUNT(*) AS open_loans FROM m01_loan6 WHERE return_dt IS NULL GROUP BY member_id;
ROLLBACK;
GO
PRINT N'== [Q4] 대안: AFTER 트리거';
GO
CREATE OR ALTER TRIGGER trg_m01_loan6_max3 ON m01_loan6 AFTER INSERT, UPDATE AS
BEGIN
  IF EXISTS (SELECT 1 FROM m01_loan6 l WHERE l.return_dt IS NULL AND l.member_id IN (SELECT member_id FROM inserted)
             GROUP BY l.member_id HAVING COUNT(*) > 3)
    THROW 50006, N'R6 위반: 미반납 대출은 회원당 최대 3권', 1;
END;
GO
INSERT INTO m01_loan6 VALUES (21, 8, '2024-03-01', NULL), (22, 8, '2024-03-01', NULL), (23, 8, '2024-03-01', NULL);
GO
-- @expect-error: MSG-50006
INSERT INTO m01_loan6 VALUES (24, 8, '2024-03-01', NULL);
GO
SELECT member_id, COUNT(*) AS open_loans FROM m01_loan6 WHERE return_dt IS NULL GROUP BY member_id;
DROP TABLE IF EXISTS m01_loan6;
GO
