-- =====================================================================
-- H. 정답 및 검증 | 06_group_having ex05_order_by | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex05_order_by.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 30번 부서 커미션 NULL 우선 정렬 순번';
-- 순서를 검증하려고 ROW_NUMBER(11단원)로 순번을 만들었다. 실제 출력은 SELECT ... ORDER BY comm NULLS FIRST, ename (Oracle).
-- SQL Server 는 ASC 기본이 NULL 먼저이므로 ORDER BY comm, ename 만으로도 같은 순서지만, 의도를 드러내려고 CASE 를 썼다.
GO
CREATE OR ALTER VIEW ans06_05_g1 (ename, ord_no) AS
SELECT ename, ROW_NUMBER() OVER (ORDER BY CASE WHEN comm IS NULL THEN 0 ELSE 1 END, comm, ename) FROM emp WHERE deptno = 30;
GO
CREATE OR ALTER VIEW exp06_05_g1 (ename, ord_no) AS
SELECT * FROM (VALUES (N'ALLEN', 4),
       (N'BLAKE', 1),
       (N'JAMES', 2),
       (N'MARTIN', 6),
       (N'TURNER', 3),
       (N'WARD', 5)) v(ename, ord_no);
GO
EXEC lab_check N'06-ex05-G1', N'ans06_05_g1', N'exp06_05_g1';
SELECT * FROM ans06_05_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 부서 최고 급여 오름차순 순번';
-- 윈도우 함수의 ORDER BY 에도 GROUP BY 뒤의 규칙(그룹 컬럼·집계만)이 적용된다. MAX(sal) 는 SELECT 목록에 없어도 된다.
GO
CREATE OR ALTER VIEW ans06_05_g2 (deptno, cnt, ord_no) AS
SELECT deptno, COUNT(*), ROW_NUMBER() OVER (ORDER BY MAX(sal)) FROM emp GROUP BY deptno;
GO
CREATE OR ALTER VIEW exp06_05_g2 (deptno, cnt, ord_no) AS
SELECT * FROM (VALUES (10, 3, 3),
       (20, 5, 2),
       (30, 6, 1)) v(deptno, cnt, ord_no);
GO
EXEC lab_check N'06-ex05-G2', N'ans06_05_g2', N'exp06_05_g2';
SELECT * FROM ans06_05_g2 ORDER BY 1, 2, 3;
GO
