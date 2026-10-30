-- =====================================================================
-- H. 정답 및 검증 | 12_hierarchical_queries ex03_recursive_with | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_recursive_with.md
-- =====================================================================

PROMPT == [G1] 상위 관리자 수
CREATE OR REPLACE VIEW ans12_03_g1 (ename, mgr_cnt) AS
WITH t (empno, ename, d) AS (SELECT empno, ename, 0 FROM emp WHERE mgr IS NULL
 UNION ALL SELECT e.empno, e.ename, t.d + 1 FROM emp e JOIN t ON e.mgr = t.empno)
SELECT ename, d FROM t;
CREATE OR REPLACE VIEW exp12_03_g1 (ename, mgr_cnt) AS
-- (ename, mgr_cnt)
SELECT 'ADAMS', 3 FROM dual
UNION ALL SELECT 'ALLEN', 2 FROM dual
UNION ALL SELECT 'BLAKE', 1 FROM dual
UNION ALL SELECT 'CLARK', 1 FROM dual
UNION ALL SELECT 'FORD', 2 FROM dual
UNION ALL SELECT 'JAMES', 2 FROM dual
UNION ALL SELECT 'JONES', 1 FROM dual
UNION ALL SELECT 'KING', 0 FROM dual
UNION ALL SELECT 'MARTIN', 2 FROM dual
UNION ALL SELECT 'MILLER', 2 FROM dual
UNION ALL SELECT 'SCOTT', 2 FROM dual
UNION ALL SELECT 'SMITH', 3 FROM dual
UNION ALL SELECT 'TURNER', 2 FROM dual
UNION ALL SELECT 'WARD', 2 FROM dual;
EXEC lab_check('12-ex03-G1', 'ANS12_03_G1', 'EXP12_03_G1')
SELECT * FROM ans12_03_g1 ORDER BY 1, 2;

PROMPT == [G2] BLAKE 조직 급여 합계
-- BLAKE 2850 + 부하 5명(ALLEN 1600, WARD 1250, MARTIN 1250, TURNER 1500, JAMES 950) = 9400 = 30번 부서 합계와 같다(이 데이터에서만 우연히 같다).
CREATE OR REPLACE VIEW ans12_03_g2 (total) AS
WITH t (empno, sal) AS (SELECT empno, sal FROM emp WHERE ename = 'BLAKE'
 UNION ALL SELECT e.empno, e.sal FROM emp e JOIN t ON e.mgr = t.empno)
SELECT SUM(sal) FROM t;
CREATE OR REPLACE VIEW exp12_03_g2 (total) AS
-- (total)
SELECT 9400 FROM dual;
EXEC lab_check('12-ex03-G2', 'ANS12_03_G2', 'EXP12_03_G2')
SELECT * FROM ans12_03_g2 ORDER BY 1;
