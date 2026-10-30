-- =====================================================================
-- H. 정답 및 검증 | 10_grouping_extensions ex05_pivot_unpivot | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex05_pivot_unpivot.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 부서별 직무 인원 PIVOT';
-- PIVOT 안의 COUNT 는 해당 칸에 행이 없으면 0 이다(Oracle COUNT(*) 도 0). NVL 은 안전장치.
-- SQL Server PIVOT 은 COUNT(*) 를 받지 않아 COUNT(empno) 로 셌다.
GO
CREATE OR ALTER VIEW ans10_05_g1 (deptno, clerk, manager, salesman) AS
SELECT deptno, [CLERK], [MANAGER], [SALESMAN] FROM (SELECT deptno, job, empno FROM emp) s
PIVOT (COUNT(empno) FOR job IN ([CLERK], [MANAGER], [SALESMAN])) p;
GO
CREATE OR ALTER VIEW exp10_05_g1 (deptno, clerk, manager, salesman) AS
SELECT * FROM (VALUES (10, 1, 1, 0),
       (20, 2, 1, 0),
       (30, 1, 1, 4)) v(deptno, clerk, manager, salesman);
GO
EXEC lab_check N'10-ex05-G1', N'ans10_05_g1', N'exp10_05_g1';
SELECT * FROM ans10_05_g1 ORDER BY 1, 2, 3, 4;
GO

PRINT N'== [G2] UNPIVOT 0 초과 칸';
GO
CREATE OR ALTER VIEW ans10_05_g2 (deptno, job, cnt) AS
SELECT deptno, job, cnt FROM (
  SELECT deptno, [CLERK], [MANAGER], [SALESMAN] FROM (SELECT deptno, job, empno FROM emp) s
  PIVOT (COUNT(empno) FOR job IN ([CLERK], [MANAGER], [SALESMAN])) p
) x UNPIVOT (cnt FOR job IN ([CLERK], [MANAGER], [SALESMAN])) u WHERE cnt > 0;
GO
CREATE OR ALTER VIEW exp10_05_g2 (deptno, job, cnt) AS
SELECT * FROM (VALUES (10, N'CLERK', 1),
       (10, N'MANAGER', 1),
       (20, N'CLERK', 2),
       (20, N'MANAGER', 1),
       (30, N'CLERK', 1),
       (30, N'MANAGER', 1),
       (30, N'SALESMAN', 4)) v(deptno, job, cnt);
GO
EXEC lab_check N'10-ex05-G2', N'ans10_05_g2', N'exp10_05_g2';
SELECT * FROM ans10_05_g2 ORDER BY 1, 2, 3;
GO
