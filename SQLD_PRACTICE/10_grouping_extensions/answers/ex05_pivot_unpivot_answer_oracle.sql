-- =====================================================================
-- H. 정답 및 검증 | 10_grouping_extensions ex05_pivot_unpivot | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex05_pivot_unpivot.md
-- =====================================================================

PROMPT == [G1] 부서별 직무 인원 PIVOT
-- PIVOT 안의 COUNT 는 해당 칸에 행이 없으면 0 이다(Oracle COUNT(*) 도 0). NVL 은 안전장치.
-- SQL Server PIVOT 은 COUNT(*) 를 받지 않아 COUNT(empno) 로 셌다.
CREATE OR REPLACE VIEW ans10_05_g1 (deptno, clerk, manager, salesman) AS
SELECT deptno, NVL(c, 0), NVL(m, 0), NVL(s, 0) FROM (SELECT deptno, job FROM emp)
PIVOT (COUNT(*) FOR job IN ('CLERK' AS c, 'MANAGER' AS m, 'SALESMAN' AS s));
CREATE OR REPLACE VIEW exp10_05_g1 (deptno, clerk, manager, salesman) AS
-- (deptno, clerk, manager, salesman)
SELECT 10, 1, 1, 0 FROM dual
UNION ALL SELECT 20, 2, 1, 0 FROM dual
UNION ALL SELECT 30, 1, 1, 4 FROM dual;
EXEC lab_check('10-ex05-G1', 'ANS10_05_G1', 'EXP10_05_G1')
SELECT * FROM ans10_05_g1 ORDER BY 1, 2, 3, 4;

PROMPT == [G2] UNPIVOT 0 초과 칸
CREATE OR REPLACE VIEW ans10_05_g2 (deptno, job, cnt) AS
SELECT deptno, job, cnt FROM (
  SELECT * FROM (SELECT deptno, job FROM emp) PIVOT (COUNT(*) FOR job IN ('CLERK' AS clerk, 'MANAGER' AS manager, 'SALESMAN' AS salesman))
) UNPIVOT (cnt FOR job IN (clerk AS 'CLERK', manager AS 'MANAGER', salesman AS 'SALESMAN')) WHERE cnt > 0;
CREATE OR REPLACE VIEW exp10_05_g2 (deptno, job, cnt) AS
-- (deptno, job, cnt)
SELECT 10, 'CLERK', 1 FROM dual
UNION ALL SELECT 10, 'MANAGER', 1 FROM dual
UNION ALL SELECT 20, 'CLERK', 2 FROM dual
UNION ALL SELECT 20, 'MANAGER', 1 FROM dual
UNION ALL SELECT 30, 'CLERK', 1 FROM dual
UNION ALL SELECT 30, 'MANAGER', 1 FROM dual
UNION ALL SELECT 30, 'SALESMAN', 4 FROM dual;
EXEC lab_check('10-ex05-G2', 'ANS10_05_G2', 'EXP10_05_G2')
SELECT * FROM ans10_05_g2 ORDER BY 1, 2, 3;
