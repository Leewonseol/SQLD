-- ex06 CREATE TABLE AS SELECT(CTAS) 가 복사하는 것과 복사하지 않는 것 (요구목록 §7 CREATE)  | Oracle
EXEC lab_drop('D13_EMP_COPY')
PROMPT == [Q1] 원본 EMP 의 제약: PK, FK 2개, NOT NULL(ename)
SELECT constraint_type, COUNT(*) cnt FROM user_constraints WHERE table_name = 'EMP' GROUP BY constraint_type ORDER BY constraint_type;

PROMPT == [Q2] CTAS: 데이터와 컬럼(자료형)·NOT NULL 만 복사, PK/FK/UNIQUE/CHECK/DEFAULT 는 복사하지 않는다
CREATE TABLE d13_emp_copy AS SELECT * FROM emp;
SELECT constraint_type, COUNT(*) cnt FROM user_constraints WHERE table_name = 'D13_EMP_COPY' GROUP BY constraint_type ORDER BY constraint_type;
SELECT COUNT(*) AS copied_rows FROM d13_emp_copy;

PROMPT == [Q3] PK 가 없으니 중복 입력이 된다
INSERT INTO d13_emp_copy SELECT * FROM emp WHERE empno = 7369;
SELECT COUNT(*) AS dup_7369 FROM d13_emp_copy WHERE empno = 7369;
ROLLBACK;

PROMPT == [Q4] 구조만 복사: WHERE 1 = 0
EXEC lab_drop('D13_EMP_COPY')
CREATE TABLE d13_emp_copy AS SELECT * FROM emp WHERE 1 = 0;
SELECT COUNT(*) AS rows_struct_only FROM d13_emp_copy;
EXEC lab_drop('D13_EMP_COPY')
