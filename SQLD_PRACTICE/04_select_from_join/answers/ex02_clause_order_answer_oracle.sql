-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex02_clause_order | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_clause_order.md
-- =====================================================================

PROMPT == [G1] 급여 1500 이상, 직무별 인원·평균(2명 이상)
-- WHERE 로 먼저 행을 거르고(1500 미만 6명 제외) 그룹을 만든 뒤 HAVING 으로 그룹을 거른다.
-- 오류 조건: HAVING 대신 WHERE COUNT(*) >= 2 → ORA-00934 / Msg 147.
CREATE OR REPLACE VIEW ans04_02_g1 (job, cnt, avg_sal) AS
SELECT job, COUNT(*), ROUND(AVG(sal), 1) FROM emp WHERE sal >= 1500 GROUP BY job HAVING COUNT(*) >= 2;
CREATE OR REPLACE VIEW exp04_02_g1 (job, cnt, avg_sal) AS
-- (job, cnt, avg_sal)
SELECT 'ANALYST', 2, 3000 FROM dual
UNION ALL SELECT 'MANAGER', 3, 2758.3 FROM dual
UNION ALL SELECT 'SALESMAN', 2, 1550 FROM dual;
EXEC lab_check('04-ex02-G1', 'ANS04_02_G1', 'EXP04_02_G1')
SELECT * FROM ans04_02_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 연봉 30000 이상 (계산식 1회)
-- 인라인 뷰 안의 SELECT 가 먼저 처리되어 바깥 WHERE 에서 별칭 annual 을 쓸 수 있다.
-- SQL Server 는 FROM 절 파생 테이블에 별칭(t)이 필수다(없으면 Msg 102).
CREATE OR REPLACE VIEW ans04_02_g2 (ename, annual) AS
SELECT ename, annual FROM (SELECT ename, sal * 12 AS annual FROM emp) WHERE annual >= 30000;
CREATE OR REPLACE VIEW exp04_02_g2 (ename, annual) AS
-- (ename, annual)
SELECT 'BLAKE', 34200 FROM dual
UNION ALL SELECT 'FORD', 36000 FROM dual
UNION ALL SELECT 'JONES', 35700 FROM dual
UNION ALL SELECT 'KING', 60000 FROM dual
UNION ALL SELECT 'SCOTT', 36000 FROM dual;
EXEC lab_check('04-ex02-G2', 'ANS04_02_G2', 'EXP04_02_G2')
SELECT * FROM ans04_02_g2 ORDER BY 1, 2;
