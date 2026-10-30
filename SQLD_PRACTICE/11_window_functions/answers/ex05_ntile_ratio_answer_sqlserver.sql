-- =====================================================================
-- H. 정답 및 검증 | 11_window_functions ex05_ntile_ratio | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex05_ntile_ratio.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 급여 4분위 요약';
-- 14/4 = 3 나머지 2 → 앞 두 그룹이 4명, 뒤 두 그룹이 3명. 동점 1250(WARD·MARTIN)이 1·2분위로 갈라진다.
GO
CREATE OR ALTER VIEW ans11_05_g1 (q, cnt, min_sal, max_sal) AS
SELECT q, COUNT(*), MIN(sal), MAX(sal) FROM (SELECT sal, NTILE(4) OVER (ORDER BY sal, empno) q FROM emp) t GROUP BY q;
GO
CREATE OR ALTER VIEW exp11_05_g1 (q, cnt, min_sal, max_sal) AS
SELECT * FROM (VALUES (1, 4, 800, 1250),
       (2, 4, 1250, 1600),
       (3, 3, 2450, 2975),
       (4, 3, 3000, 5000)) v(q, cnt, min_sal, max_sal);
GO
EXEC lab_check N'11-ex05-G1', N'ans11_05_g1', N'exp11_05_g1';
SELECT * FROM ans11_05_g1 ORDER BY 1, 2, 3, 4;
GO

PRINT N'== [G2] 30번 부서 CUME_DIST <= 0.5';
GO
CREATE OR ALTER VIEW ans11_05_g2 (ename) AS
SELECT ename FROM (SELECT ename, CUME_DIST() OVER (ORDER BY sal) cd FROM emp WHERE deptno = 30) t WHERE cd <= 0.5;
GO
CREATE OR ALTER VIEW exp11_05_g2 (ename) AS
SELECT * FROM (VALUES (N'JAMES'),
       (N'MARTIN'),
       (N'WARD')) v(ename);
GO
EXEC lab_check N'11-ex05-G2', N'ans11_05_g2', N'exp11_05_g2';
SELECT * FROM ans11_05_g2 ORDER BY 1;
GO
