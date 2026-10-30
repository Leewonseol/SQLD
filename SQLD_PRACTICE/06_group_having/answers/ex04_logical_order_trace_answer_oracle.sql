-- =====================================================================
-- H. 정답 및 검증 | 06_group_having ex04_logical_order_trace | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_logical_order_trace.md
-- =====================================================================

PROMPT == [G1] 근무지별 집계 최상위 1곳
-- 단계별 행 수: FROM·JOIN 14 → WHERE 12(SMITH·JAMES 제외) → GROUP BY 3(NEW YORK 3/8750, DALLAS 4/10075, CHICAGO 5/8450) → HAVING 3 → ORDER BY → 1.
CREATE OR REPLACE VIEW ans06_04_g1 (loc, cnt, total) AS
SELECT d.loc, COUNT(*), SUM(e.sal) FROM emp e JOIN dept d ON e.deptno = d.deptno
WHERE e.sal >= 1000 GROUP BY d.loc HAVING COUNT(*) >= 3
ORDER BY SUM(e.sal) DESC FETCH FIRST 1 ROWS ONLY;
CREATE OR REPLACE VIEW exp06_04_g1 (loc, cnt, total) AS
-- (loc, cnt, total)
SELECT 'DALLAS', 4, 10075 FROM dual;
EXEC lab_check('06-ex04-G1', 'ANS06_04_G1', 'EXP06_04_G1')
SELECT * FROM ans06_04_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 직무 내림차순 2~3번째
-- DISTINCT → ORDER BY → OFFSET/FETCH 순서. 뷰 안의 ORDER BY 는 SQL Server 에서 OFFSET/TOP 이 있을 때만 허용된다.
CREATE OR REPLACE VIEW ans06_04_g2 (job) AS
SELECT DISTINCT job FROM emp ORDER BY job DESC OFFSET 1 ROWS FETCH NEXT 2 ROWS ONLY;
CREATE OR REPLACE VIEW exp06_04_g2 (job) AS
-- (job)
SELECT 'MANAGER' FROM dual
UNION ALL SELECT 'PRESIDENT' FROM dual;
EXEC lab_check('06-ex04-G2', 'ANS06_04_G2', 'EXP06_04_G2')
SELECT * FROM ans06_04_g2 ORDER BY 1;
