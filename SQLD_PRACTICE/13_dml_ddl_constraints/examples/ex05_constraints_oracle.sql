-- ex05 제약조건 PK · FK · UNIQUE · CHECK · NOT NULL · DEFAULT (요구목록 §7, PDF E-03 자기참조 FK)  | Oracle
EXEC lab_drop('D13_EMP')
EXEC lab_drop('D13_DEPT')
CREATE TABLE d13_dept (deptno NUMBER CONSTRAINT pk_d13_dept PRIMARY KEY, dname VARCHAR2(10) CONSTRAINT uq_d13_dept_dname UNIQUE);
CREATE TABLE d13_emp (
  empno  NUMBER       CONSTRAINT pk_d13_emp PRIMARY KEY,
  ename  VARCHAR2(10) CONSTRAINT nn_d13_emp_ename NOT NULL,
  email  VARCHAR2(20) CONSTRAINT uq_d13_emp_email UNIQUE,
  sal    NUMBER       CONSTRAINT ck_d13_emp_sal CHECK (sal > 0),
  deptno NUMBER       CONSTRAINT fk_d13_emp_dept REFERENCES d13_dept(deptno) ON DELETE SET NULL,
  mentor NUMBER       CONSTRAINT fk_d13_emp_mentor REFERENCES d13_emp(empno)
);
INSERT INTO d13_dept VALUES (10, 'A');
INSERT INTO d13_dept VALUES (20, 'B');
INSERT INTO d13_emp VALUES (1, 'kim', 'k@x', 100, 10, NULL);
INSERT INTO d13_emp VALUES (2, 'lee', NULL, 200, 20, 1);
COMMIT;

PROMPT == [Q1] UNIQUE 는 NULL 을 여러 개 허용한다 (Oracle) -> 성공
INSERT INTO d13_emp VALUES (3, 'park', NULL, 300, 10, 1);
SELECT COUNT(*) AS null_email_rows FROM d13_emp WHERE email IS NULL;

PROMPT == [Q2] CHECK 는 NULL 이면 통과 (조건이 UNKNOWN 이면 위반이 아니다)
INSERT INTO d13_emp VALUES (4, 'choi', 'c@x', NULL, 10, NULL);
SELECT empno, sal FROM d13_emp WHERE empno = 4;

PROMPT == [Q3] 위반 사례: CHECK / UNIQUE / PK / NOT NULL / FK(없는 부모) / 자기참조 FK(없는 멘토)
-- @expect-error: ORA-02290, ORA-00001, ORA-01400, ORA-02291
INSERT INTO d13_emp VALUES (5, 'x', 'x@x', -1, 10, NULL);
INSERT INTO d13_emp VALUES (6, 'y', 'k@x', 10, 10, NULL);
INSERT INTO d13_emp VALUES (1, 'z', 'z@x', 10, 10, NULL);
INSERT INTO d13_emp VALUES (7, NULL, 'n@x', 10, 10, NULL);
INSERT INTO d13_emp VALUES (8, 'w', 'w@x', 10, 99, NULL);
INSERT INTO d13_emp VALUES (9, 'v', 'v@x', 10, 10, 77);

PROMPT == [Q4] ON DELETE SET NULL: 부모(10번) 삭제 -> 자식의 deptno 가 NULL
DELETE FROM d13_dept WHERE deptno = 10;
SELECT empno, deptno FROM d13_emp ORDER BY empno;
ROLLBACK;

PROMPT == [Q5] 자식이 참조 중인 자기참조 행(멘토 1) 삭제 -> 오류 (기본 옵션 = NO ACTION)
-- @expect-error: ORA-02292
DELETE FROM d13_emp WHERE empno = 1;

PROMPT == [Q6] Oracle 은 ON UPDATE CASCADE 를 지원하지 않는다 -> 오류
-- @expect-error: ORA-00905
CREATE TABLE d13_bad (id NUMBER REFERENCES d13_dept(deptno) ON UPDATE CASCADE);

PROMPT == [Q7] 제약조건 목록 (데이터 사전)
SELECT constraint_name, constraint_type, search_condition_vc FROM user_constraints WHERE table_name = 'D13_EMP' ORDER BY constraint_name;
EXEC lab_drop('D13_EMP')
EXEC lab_drop('D13_DEPT')
