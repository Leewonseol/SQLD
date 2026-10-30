-- ex03 식별 관계 vs 비식별 관계 (요구목록 §6)  | Oracle
EXEC lab_drop('M01_LOAN_I')
EXEC lab_drop('M01_LOAN_N')
EXEC lab_drop('M01_COPY_I')
EXEC lab_drop('M01_COPY_N')
EXEC lab_drop('M01_BOOK3')
CREATE TABLE m01_book3 (isbn VARCHAR2(13) CONSTRAINT pk_m01_book3 PRIMARY KEY);
-- 식별 관계: 부모 PK(isbn)가 자식 PK 의 일부 -> 자식은 부모 없이 존재할 수 없다(PK 컬럼은 NOT NULL)
CREATE TABLE m01_copy_i (isbn VARCHAR2(13) CONSTRAINT fk_m01_copy_i REFERENCES m01_book3(isbn), copy_seq NUMBER,
                         CONSTRAINT pk_m01_copy_i PRIMARY KEY (isbn, copy_seq));
-- 비식별 관계: 자식은 자기 PK(copy_id)를 갖고 부모 PK 는 일반 FK 컬럼
CREATE TABLE m01_copy_n (copy_id NUMBER CONSTRAINT pk_m01_copy_n PRIMARY KEY,
                         isbn VARCHAR2(13) CONSTRAINT fk_m01_copy_n REFERENCES m01_book3(isbn));
-- 손자 테이블: 식별 관계를 따라 PK 가 계속 내려오면 FK 컬럼 수가 늘어난다
CREATE TABLE m01_loan_i (loan_id NUMBER PRIMARY KEY, isbn VARCHAR2(13), copy_seq NUMBER,
                         CONSTRAINT fk_m01_loan_i FOREIGN KEY (isbn, copy_seq) REFERENCES m01_copy_i (isbn, copy_seq));
CREATE TABLE m01_loan_n (loan_id NUMBER PRIMARY KEY, copy_id NUMBER CONSTRAINT fk_m01_loan_n REFERENCES m01_copy_n(copy_id));
INSERT INTO m01_book3 VALUES ('A');
INSERT INTO m01_book3 VALUES ('B');
COMMIT;

PROMPT == [Q1] 식별 관계: copy_seq 는 도서마다 1부터 다시 시작할 수 있다 (A-1, B-1 공존)
INSERT INTO m01_copy_i VALUES ('A', 1);
INSERT INTO m01_copy_i VALUES ('B', 1);
SELECT * FROM m01_copy_i ORDER BY isbn, copy_seq;

PROMPT == [Q2] 식별 관계: 부모 없는 자식 불가 (isbn 이 PK 의 일부라 NULL 불가)
-- @expect-error: ORA-01400
INSERT INTO m01_copy_i VALUES (NULL, 9);

PROMPT == [Q3] 비식별 관계: FK 가 NULL 이면 부모 없는 자식도 가능 (선택 관계). 필수로 만들려면 NOT NULL 을 추가
INSERT INTO m01_copy_n VALUES (1, 'A');
INSERT INTO m01_copy_n VALUES (2, NULL);
SELECT * FROM m01_copy_n ORDER BY copy_id;

PROMPT == [Q4] 손자 테이블이 부모를 참조하는 FK 컬럼 수: 식별 관계 2개, 비식별 관계 1개
SELECT c.table_name, COUNT(*) AS fk_columns FROM user_cons_columns c JOIN user_constraints k ON k.constraint_name = c.constraint_name
WHERE k.constraint_type = 'R' AND c.table_name IN ('M01_LOAN_I', 'M01_LOAN_N') GROUP BY c.table_name ORDER BY 1;
ROLLBACK;
