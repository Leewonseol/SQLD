-- ex01 ROLLUP (PDF E-28, E-29)  | Oracle
PROMPT == [Q1] PDF E-29 데이터 재현: ROLLUP(DNAME, JOB) = (DNAME,JOB) 9 + DNAME 소계 3 + 총계 1 = 13행
SELECT d.dname, e.job, COUNT(*) "Total Empl", SUM(e.sal) "Total Sal"
FROM emp e, dept d WHERE d.deptno = e.deptno
GROUP BY ROLLUP (d.dname, e.job)
ORDER BY d.dname, e.job;

PROMPT == [Q2] PDF E-28 구조(학습용 가상 데이터): ROLLUP(species, breed) -> 소계 기준 = species
SELECT NVL(species, '합계') AS species_l, NVL(breed, '합계') AS breed_l, ROUND(AVG(age), 2) AS avg_age, COUNT(*) AS cnt
FROM animal_hotel GROUP BY ROLLUP (species, breed) ORDER BY GROUPING(species), species, GROUPING(breed), breed;

PROMPT == [Q3] 인수 순서를 바꾸면 ROLLUP(breed, species) -> 소계 기준 = breed. 행 집합 자체가 달라진다
SELECT NVL(species, '합계') AS species_l, NVL(breed, '합계') AS breed_l, ROUND(AVG(age), 2) AS avg_age, COUNT(*) AS cnt
FROM animal_hotel GROUP BY ROLLUP (breed, species) ORDER BY GROUPING(breed), breed, GROUPING(species), species;

PROMPT == [Q4] ROLLUP(A, B) = (A,B) 그룹 UNION ALL (A) 그룹 UNION ALL 전체 — 집합 차이 0행이면 같다
SELECT COUNT(*) AS diff_rows FROM (
  (SELECT species, breed, COUNT(*) c FROM animal_hotel GROUP BY ROLLUP (species, breed)
   MINUS
   (SELECT species, breed, COUNT(*) FROM animal_hotel GROUP BY species, breed
    UNION ALL SELECT species, NULL, COUNT(*) FROM animal_hotel GROUP BY species
    UNION ALL SELECT NULL, NULL, COUNT(*) FROM animal_hotel))
  UNION ALL
  ((SELECT species, breed, COUNT(*) FROM animal_hotel GROUP BY species, breed
    UNION ALL SELECT species, NULL, COUNT(*) FROM animal_hotel GROUP BY species
    UNION ALL SELECT NULL, NULL, COUNT(*) FROM animal_hotel)
   MINUS
   SELECT species, breed, COUNT(*) FROM animal_hotel GROUP BY ROLLUP (species, breed)));
