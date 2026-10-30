-- ex02 GROUPING 함수 (PDF E-29)  | SQL Server (DECODE 없음 -> CASE)
PRINT N'== [Q1] CASE GROUPING(...)';
SELECT CASE GROUPING(d.dname) WHEN 1 THEN 'All Departments' ELSE d.dname END AS dname,
       CASE GROUPING(e.job) WHEN 1 THEN 'All Jobs' ELSE e.job END AS job,
       COUNT(*) "Total Empl", SUM(e.sal) "Total Sal"
FROM emp e, dept d WHERE d.deptno = e.deptno
GROUP BY ROLLUP (d.dname, e.job)
ORDER BY GROUPING(d.dname), d.dname, GROUPING(e.job), e.job;
PRINT N'== [Q2] ISNULL 로 이름 붙이기의 함정';
SELECT species, ISNULL(breed, N'소계') AS breed_isnull, SUM(cnt) AS s FROM ah_null GROUP BY ROLLUP (species, breed) ORDER BY species, breed;
PRINT N'== [Q3] GROUPING 으로 구별';
SELECT species, breed, GROUPING(species) g_sp, GROUPING(breed) g_br,
       CASE WHEN GROUPING(species) = 1 THEN N'총계' WHEN GROUPING(breed) = 1 THEN N'소계' ELSE ISNULL(breed, N'(NULL값)') END AS label,
       SUM(cnt) AS s
FROM ah_null GROUP BY ROLLUP (species, breed) ORDER BY GROUPING(species), species, GROUPING(breed), breed;
PRINT N'== [Q4] GROUPING_ID';
SELECT species, breed, GROUPING_ID(species, breed) AS gid, SUM(cnt) s FROM ah_null GROUP BY CUBE (species, breed) ORDER BY gid, species, breed;
GO
