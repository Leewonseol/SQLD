-- H. 정답 및 검증 | 13 ex01 | Oracle  (문제: ../exercises/ex01_insert_update_delete.md)
EXEC lab_drop('D13_G_DEPT')
CREATE TABLE d13_g_dept AS SELECT * FROM dept;
-- [학습자 작성 구간 시작]
INSERT INTO d13_g_dept VALUES (50, 'IT', 'SEOUL');
UPDATE d13_g_dept SET loc = 'BUSAN' WHERE deptno = 40;
DELETE FROM d13_g_dept WHERE deptno = 20;
COMMIT;
-- [학습자 작성 구간 끝]
-- 오류 조건: INSERT 값 개수 불일치(ORA-00947), UPDATE/DELETE 에 WHERE 를 빠뜨리면 모든 행이 바뀌어 CHECK_FAIL
CREATE OR REPLACE VIEW ans13_01_g1 AS SELECT deptno, dname, loc FROM d13_g_dept;
CREATE OR REPLACE VIEW exp13_01_g1 (deptno, dname, loc) AS
SELECT 10, 'ACCOUNTING', 'NEW YORK' FROM dual UNION ALL SELECT 30, 'SALES', 'CHICAGO' FROM dual
UNION ALL SELECT 40, 'OPERATIONS', 'BUSAN' FROM dual UNION ALL SELECT 50, 'IT', 'SEOUL' FROM dual;
EXEC lab_check('13-ex01-G1', 'ANS13_01_G1', 'EXP13_01_G1')
SELECT * FROM ans13_01_g1 ORDER BY deptno;
