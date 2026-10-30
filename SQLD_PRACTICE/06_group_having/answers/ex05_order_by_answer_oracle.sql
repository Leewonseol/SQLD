-- =====================================================================
-- H. 정답 및 검증 | 06_group_having ex05_order_by | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex05_order_by.md
-- =====================================================================

PROMPT == [G1] 30번 부서 커미션 NULL 우선 정렬 순번
-- 순서를 검증하려고 ROW_NUMBER(11단원)로 순번을 만들었다. 실제 출력은 SELECT ... ORDER BY comm NULLS FIRST, ename (Oracle).
-- SQL Server 는 ASC 기본이 NULL 먼저이므로 ORDER BY comm, ename 만으로도 같은 순서지만, 의도를 드러내려고 CASE 를 썼다.
CREATE OR REPLACE VIEW ans06_05_g1 (ename, ord_no) AS
SELECT ename, ROW_NUMBER() OVER (ORDER BY comm NULLS FIRST, ename) FROM emp WHERE deptno = 30;
CREATE OR REPLACE VIEW exp06_05_g1 (ename, ord_no) AS
-- (ename, ord_no)
SELECT 'ALLEN', 4 FROM dual
UNION ALL SELECT 'BLAKE', 1 FROM dual
UNION ALL SELECT 'JAMES', 2 FROM dual
UNION ALL SELECT 'MARTIN', 6 FROM dual
UNION ALL SELECT 'TURNER', 3 FROM dual
UNION ALL SELECT 'WARD', 5 FROM dual;
EXEC lab_check('06-ex05-G1', 'ANS06_05_G1', 'EXP06_05_G1')
SELECT * FROM ans06_05_g1 ORDER BY 1, 2;

PROMPT == [G2] 부서 최고 급여 오름차순 순번
-- 윈도우 함수의 ORDER BY 에도 GROUP BY 뒤의 규칙(그룹 컬럼·집계만)이 적용된다. MAX(sal) 는 SELECT 목록에 없어도 된다.
CREATE OR REPLACE VIEW ans06_05_g2 (deptno, cnt, ord_no) AS
SELECT deptno, COUNT(*), ROW_NUMBER() OVER (ORDER BY MAX(sal)) FROM emp GROUP BY deptno;
CREATE OR REPLACE VIEW exp06_05_g2 (deptno, cnt, ord_no) AS
-- (deptno, cnt, ord_no)
SELECT 10, 3, 3 FROM dual
UNION ALL SELECT 20, 5, 2 FROM dual
UNION ALL SELECT 30, 6, 1 FROM dual;
EXEC lab_check('06-ex05-G2', 'ANS06_05_G2', 'EXP06_05_G2')
SELECT * FROM ans06_05_g2 ORDER BY 1, 2, 3;
