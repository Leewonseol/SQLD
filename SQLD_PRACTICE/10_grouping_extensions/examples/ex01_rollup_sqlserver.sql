-- ex01 ROLLUP (PDF E-28, E-29)  | SQL Server (ROLLUP(...) 과 옛 WITH ROLLUP 둘 다 지원)
PRINT N'== [Q1] ROLLUP(DNAME, JOB) 13행';
SELECT d.dname, e.job, COUNT(*) "Total Empl", SUM(e.sal) "Total Sal"
FROM emp e, dept d WHERE d.deptno = e.deptno
GROUP BY ROLLUP (d.dname, e.job)
ORDER BY d.dname, e.job;
PRINT N'== [Q2] ROLLUP(species, breed) (ISNULL 로 합계 표시)';
SELECT ISNULL(species, N'합계') AS species_l, ISNULL(breed, N'합계') AS breed_l, ROUND(AVG(age), 2) AS avg_age, COUNT(*) AS cnt
FROM animal_hotel GROUP BY ROLLUP (species, breed) ORDER BY GROUPING(species), species, GROUPING(breed), breed;
PRINT N'== [Q3] ROLLUP(breed, species)';
SELECT ISNULL(species, N'합계') AS species_l, ISNULL(breed, N'합계') AS breed_l, ROUND(AVG(age), 2) AS avg_age, COUNT(*) AS cnt
FROM animal_hotel GROUP BY ROLLUP (breed, species) ORDER BY GROUPING(breed), breed, GROUPING(species), species;
PRINT N'== [Q4] ROLLUP = UNION ALL 세 개 (집합 차이 0행)';
WITH r AS (SELECT species, breed, COUNT(*) c FROM animal_hotel GROUP BY ROLLUP (species, breed)),
     u AS (SELECT species, breed, COUNT(*) c FROM animal_hotel GROUP BY species, breed
           UNION ALL SELECT species, NULL, COUNT(*) FROM animal_hotel GROUP BY species
           UNION ALL SELECT NULL, NULL, COUNT(*) FROM animal_hotel)
SELECT (SELECT COUNT(*) FROM (SELECT * FROM r EXCEPT SELECT * FROM u) x) + (SELECT COUNT(*) FROM (SELECT * FROM u EXCEPT SELECT * FROM r) y) AS diff_rows;
PRINT N'== [Q5] SQL Server 옛 문법 WITH ROLLUP (같은 결과)';
SELECT species, COUNT(*) AS cnt FROM animal_hotel GROUP BY species WITH ROLLUP ORDER BY GROUPING(species), species;
GO
