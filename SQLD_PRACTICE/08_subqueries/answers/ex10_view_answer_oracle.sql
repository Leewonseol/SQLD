-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex10_view | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex10_view.md
-- =====================================================================

PROMPT == [G1] 20번 부서 사원·부서명 뷰
CREATE OR REPLACE VIEW ans08_10_g1 (ename, dname) AS
SELECT e.ename, d.dname FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE e.deptno = 20;
CREATE OR REPLACE VIEW exp08_10_g1 (ename, dname) AS
-- (ename, dname)
SELECT 'ADAMS', 'RESEARCH' FROM dual
UNION ALL SELECT 'FORD', 'RESEARCH' FROM dual
UNION ALL SELECT 'JONES', 'RESEARCH' FROM dual
UNION ALL SELECT 'SCOTT', 'RESEARCH' FROM dual
UNION ALL SELECT 'SMITH', 'RESEARCH' FROM dual;
EXEC lab_check('08-ex10-G1', 'ANS08_10_G1', 'EXP08_10_G1')
SELECT * FROM ans08_10_g1 ORDER BY 1, 2;

PROMPT == [G2] 3명 이상 부서 요약 뷰
-- SQL Server ROUND 는 자릿수 인수가 필수다. 뷰 정의에 ORDER BY 를 넣으면 SQL Server 는 Msg 1033.
CREATE OR REPLACE VIEW ans08_10_g2 (deptno, cnt, avg_sal) AS
SELECT deptno, COUNT(*), ROUND(AVG(sal)) FROM emp GROUP BY deptno HAVING COUNT(*) >= 3;
CREATE OR REPLACE VIEW exp08_10_g2 (deptno, cnt, avg_sal) AS
-- (deptno, cnt, avg_sal)
SELECT 10, 3, 2917 FROM dual
UNION ALL SELECT 20, 5, 2175 FROM dual
UNION ALL SELECT 30, 6, 1567 FROM dual;
EXEC lab_check('08-ex10-G2', 'ANS08_10_G2', 'EXP08_10_G2')
SELECT * FROM ans08_10_g2 ORDER BY 1, 2, 3;
