-- ex10 뷰(VIEW) — 저장된 쿼리 (요구목록 "PDF에 추가로 등장하는 항목" 후보. 추출본에서 확인되지 않음. E-21 "인라인 뷰 = 동적 뷰" 와 대비)  | Oracle
PROMPT == [Q1] 뷰 생성: 실제 데이터는 저장하지 않고 정의(쿼리)만 저장한다
CREATE OR REPLACE VIEW v_emp20 AS SELECT empno, ename, sal, deptno FROM emp WHERE deptno = 20;
SELECT * FROM v_emp20 ORDER BY empno;

PROMPT == [Q2] 기본 테이블이 바뀌면 뷰 결과도 바로 바뀐다 (실험 후 ROLLBACK)
UPDATE emp SET sal = sal + 1 WHERE empno = 7369;
SELECT ename, sal FROM v_emp20 WHERE empno = 7369;
ROLLBACK;

PROMPT == [Q3] WITH CHECK OPTION: 뷰 조건(deptno = 20)을 벗어나게 만드는 변경을 막는다
CREATE OR REPLACE VIEW v_emp20_chk AS SELECT empno, ename, sal, deptno FROM emp WHERE deptno = 20 WITH CHECK OPTION;
-- @expect-error: ORA-01402
UPDATE v_emp20_chk SET deptno = 30 WHERE empno = 7369;

PROMPT == [Q4] WITH READ ONLY (Oracle): 뷰를 통한 DML 금지
CREATE OR REPLACE VIEW v_emp20_ro AS SELECT empno, ename FROM emp WHERE deptno = 20 WITH READ ONLY;
-- @expect-error: ORA-42399
UPDATE v_emp20_ro SET ename = 'X' WHERE empno = 7369;

PROMPT == [Q5] 정리
DROP VIEW v_emp20;
DROP VIEW v_emp20_chk;
DROP VIEW v_emp20_ro;
