-- ex01 INSERT · UPDATE · DELETE (PDF E-04 DML, 요구목록 §7)  | Oracle
EXEC lab_drop('D13_MEMBER')
CREATE TABLE d13_member (id NUMBER CONSTRAINT pk_d13_member PRIMARY KEY, name VARCHAR2(20) NOT NULL, grade VARCHAR2(10) DEFAULT 'BASIC', point NUMBER DEFAULT 0);

PROMPT == [Q1] INSERT: 컬럼 목록 생략(모든 컬럼 순서대로) / 일부 컬럼만 -> 나머지는 DEFAULT 또는 NULL
INSERT INTO d13_member VALUES (1, 'kim', 'VIP', 100);
INSERT INTO d13_member (id, name) VALUES (2, 'lee');
INSERT INTO d13_member (id, name, grade, point) VALUES (3, 'park', NULL, DEFAULT);
SELECT * FROM d13_member ORDER BY id;

PROMPT == [Q2] 여러 행 INSERT: INSERT ALL (19c) / INSERT ... SELECT
INSERT ALL INTO d13_member (id, name) VALUES (4, 'choi') INTO d13_member (id, name) VALUES (5, 'jung') SELECT * FROM dual;
INSERT INTO d13_member (id, name, point) SELECT empno, ename, sal FROM emp WHERE deptno = 10;
SELECT COUNT(*) AS cnt FROM d13_member;

PROMPT == [Q3] UPDATE: WHERE 로 대상 제한, 여러 컬럼 동시 변경, 자기 컬럼 참조
UPDATE d13_member SET grade = 'GOLD', point = point + 50 WHERE id IN (2, 3);
SELECT id, grade, point FROM d13_member WHERE id IN (2, 3) ORDER BY id;

PROMPT == [Q4] DELETE: WHERE 없는 DELETE 는 모든 행 (Oracle 은 FROM 생략 가능: DELETE d13_member WHERE ...)
DELETE d13_member WHERE id > 100;
SELECT COUNT(*) AS cnt_after_delete FROM d13_member;

PROMPT == [Q5] 제약 위반 INSERT 는 문장 전체가 실패한다 (PK 중복, NOT NULL)
-- @expect-error: ORA-00001, ORA-01400
INSERT INTO d13_member (id, name) VALUES (1, 'dup');
INSERT INTO d13_member (id, name) VALUES (9, NULL);

PROMPT == [Q6] 값 개수와 컬럼 수 불일치 -> 오류
-- @expect-error: ORA-00947
INSERT INTO d13_member VALUES (10, 'short');
ROLLBACK;
EXEC lab_drop('D13_MEMBER')
