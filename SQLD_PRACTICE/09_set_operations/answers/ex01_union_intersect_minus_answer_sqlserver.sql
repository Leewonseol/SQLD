-- =====================================================================
-- H. 정답 및 검증 | 09_set_operations ex01_union_intersect_minus | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_union_intersect_minus.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 사원이 없는 부서';
-- SQL Server 에서 MINUS 로 쓰면 오류 없이 dept 전체(4행)와 emp 의 deptno(14행)가 따로 나온다 → 뷰 생성 단계에서 실패하거나 의도와 다른 결과.
GO
CREATE OR ALTER VIEW ans09_01_g1 (deptno) AS
SELECT deptno FROM dept EXCEPT SELECT deptno FROM emp;
GO
CREATE OR ALTER VIEW exp09_01_g1 (deptno) AS
SELECT * FROM (VALUES (40)) v(deptno);
GO
EXEC lab_check N'09-ex01-G1', N'ans09_01_g1', N'exp09_01_g1';
SELECT * FROM ans09_01_g1 ORDER BY 1;
GO

PRINT N'== [G2] 1981 입사 직무 + 3000 이상 직무 (UNION ALL 행 수)';
-- 1981년 입사 10명 + 3000 이상 3명(SCOTT·KING·FORD) = 13. UNION 이면 중복 직무가 줄어 5종 이하.
GO
CREATE OR ALTER VIEW ans09_01_g2 (cnt) AS
SELECT COUNT(*) FROM (SELECT job FROM emp WHERE hiredate BETWEEN '1981-01-01' AND '1981-12-31'
 UNION ALL SELECT job FROM emp WHERE sal >= 3000) t;
GO
CREATE OR ALTER VIEW exp09_01_g2 (cnt) AS
SELECT * FROM (VALUES (13)) v(cnt);
GO
EXEC lab_check N'09-ex01-G2', N'ans09_01_g2', N'exp09_01_g2';
SELECT * FROM ans09_01_g2 ORDER BY 1;
GO
