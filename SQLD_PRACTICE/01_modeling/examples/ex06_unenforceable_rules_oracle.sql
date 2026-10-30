-- ex06 선언적 제약조건만으로 구현할 수 없는 업무 규칙 (요구목록 §6 "DBMS 제약조건만으로 구현할 수 없는 업무 규칙은 […] 별도로 설명")  | Oracle
EXEC lab_drop('M01_LOAN6')
CREATE TABLE m01_loan6 (loan_id NUMBER PRIMARY KEY, member_id NUMBER NOT NULL, loan_dt DATE NOT NULL, return_dt DATE,
                        CONSTRAINT ck_m01_loan6_dt CHECK (return_dt >= loan_dt));
PROMPT == [Q1] R5 반납일 >= 대출일: 한 행 안의 조건 -> CHECK 로 구현된다
-- @expect-error: ORA-02290
INSERT INTO m01_loan6 VALUES (1, 7, DATE '2024-03-10', DATE '2024-03-01');

PROMPT == [Q2] R6 '회원당 미반납 대출 최대 3권': 여러 행을 세야 한다 -> CHECK 안에 서브쿼리 불가
-- @expect-error: ORA-02251
ALTER TABLE m01_loan6 ADD CONSTRAINT ck_m01_loan6_max3 CHECK ((SELECT COUNT(*) FROM m01_loan6 x WHERE x.member_id = member_id AND x.return_dt IS NULL) <= 3);

PROMPT == [Q3] 그래서 제약조건만 있으면 4번째 대출이 그대로 들어간다
INSERT INTO m01_loan6 VALUES (11, 7, DATE '2024-03-01', NULL);
INSERT INTO m01_loan6 VALUES (12, 7, DATE '2024-03-01', NULL);
INSERT INTO m01_loan6 VALUES (13, 7, DATE '2024-03-01', NULL);
INSERT INTO m01_loan6 VALUES (14, 7, DATE '2024-03-01', NULL);
SELECT member_id, COUNT(*) AS open_loans FROM m01_loan6 WHERE return_dt IS NULL GROUP BY member_id;
ROLLBACK;

PROMPT == [Q4] 대안: 트리거(절차적 구현). 문장 단위 AFTER 트리거로 위반 시 오류
CREATE OR REPLACE TRIGGER trg_m01_loan6_max3 AFTER INSERT OR UPDATE ON m01_loan6
DECLARE v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM (SELECT member_id FROM m01_loan6 WHERE return_dt IS NULL GROUP BY member_id HAVING COUNT(*) > 3);
  IF v_cnt > 0 THEN RAISE_APPLICATION_ERROR(-20006, 'R6 위반: 미반납 대출은 회원당 최대 3권'); END IF;
END;
/
INSERT INTO m01_loan6 VALUES (21, 8, DATE '2024-03-01', NULL);
INSERT INTO m01_loan6 VALUES (22, 8, DATE '2024-03-01', NULL);
INSERT INTO m01_loan6 VALUES (23, 8, DATE '2024-03-01', NULL);
-- @expect-error: ORA-20006, ORA-06512, ORA-04088
INSERT INTO m01_loan6 VALUES (24, 8, DATE '2024-03-01', NULL);
SELECT member_id, COUNT(*) AS open_loans FROM m01_loan6 WHERE return_dt IS NULL GROUP BY member_id;
PROMPT (주의: 트리거는 동시에 들어오는 두 세션의 INSERT 를 서로 보지 못해 둘 다 통과할 수 있다. 잠금·직렬화가 필요하다 - 미실행 설명)
ROLLBACK;
EXEC lab_drop('TRG_M01_LOAN6_MAX3', 'TRIGGER')
EXEC lab_drop('M01_LOAN6')
