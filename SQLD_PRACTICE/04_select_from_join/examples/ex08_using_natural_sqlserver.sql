-- ex08 ON·USING·NATURAL JOIN  | SQL Server : USING, NATURAL JOIN 은 지원하지 않는다 (PDF E-16, E-17 서술과 일치하는지 확인)
PRINT N'== [Q1] NATURAL JOIN -> 구문 오류';
GO
-- @expect-error: MSG-102
SELECT * FROM nj_t1 NATURAL JOIN nj_t2;
GO
PRINT N'== [Q2] USING -> 구문 오류';
GO
-- @expect-error: MSG-102
SELECT no FROM nj_t1 a JOIN nj_t2 b USING (no);
GO
PRINT N'== [Q3] NATURAL JOIN nj_t1-nj_t2 대체: 같은 이름의 모든 컬럼을 ON 에 나열';
SELECT a.no, a.name FROM nj_t1 a JOIN nj_t2 b ON a.no = b.no AND a.name = b.name;
PRINT N'== [Q4] NATURAL JOIN nj_t1-nj_t3 대체';
SELECT a.no, a.name, b.pos FROM nj_t1 a JOIN nj_t3 b ON a.no = b.no ORDER BY a.no, b.pos;
PRINT N'== [Q5] USING (no) 대체';
SELECT a.no, a.name AS t1_name, b.name AS t2_name FROM nj_t1 a JOIN nj_t2 b ON a.no = b.no ORDER BY a.no;
PRINT N'== [Q6] ON 조인: SELECT * 이면 no 가 두 번';
SELECT * FROM nj_t1 a JOIN nj_t2 b ON a.no = b.no ORDER BY a.no;
PRINT N'== [Q7] EMP-DEPT NATURAL JOIN 대체 (deptno = 10)';
SELECT e.deptno, e.empno, e.ename, d.dname FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE e.deptno = 10 ORDER BY e.empno;
GO
