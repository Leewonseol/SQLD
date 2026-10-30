-- ex02 GROUPING 함수와 소계 이름 붙이기 (PDF E-29 DECODE(GROUPING(DNAME), 1, 'All Departments', DNAME))  | Oracle
PROMPT == [Q1] PDF 쿼리: GROUPING(col) = 1 이면 그 컬럼이 집계되어(소계·총계로) 사라진 행
SELECT DECODE(GROUPING(d.dname), 1, 'All Departments', d.dname) AS dname,
       DECODE(GROUPING(e.job), 1, 'All Jobs', e.job) AS job,
       COUNT(*) "Total Empl", SUM(e.sal) "Total Sal"
FROM emp e, dept d WHERE d.deptno = e.deptno
GROUP BY ROLLUP (d.dname, e.job)
ORDER BY GROUPING(d.dname), d.dname, GROUPING(e.job), e.job;

PROMPT == [Q2] NVL 로 이름을 붙이면 '진짜 NULL 값 그룹'과 '소계'를 구별하지 못한다 (AH_NULL: A 에 breed NULL 행 있음)
SELECT species, NVL(breed, '소계') AS breed_nvl, SUM(cnt) AS s FROM ah_null GROUP BY ROLLUP (species, breed) ORDER BY species, breed;

PROMPT == [Q3] GROUPING 으로 구별: 실제 NULL 은 GROUPING = 0, 소계는 1
SELECT species, breed, GROUPING(species) g_sp, GROUPING(breed) g_br,
       CASE WHEN GROUPING(species) = 1 THEN '총계' WHEN GROUPING(breed) = 1 THEN '소계' ELSE NVL(breed, '(NULL값)') END AS label,
       SUM(cnt) AS s
FROM ah_null GROUP BY ROLLUP (species, breed) ORDER BY GROUPING(species), species, GROUPING(breed), breed;

PROMPT == [Q4] GROUPING_ID(a, b) = GROUPING(a)*2 + GROUPING(b) (비트 벡터)
SELECT species, breed, GROUPING_ID(species, breed) AS gid, SUM(cnt) s FROM ah_null GROUP BY CUBE (species, breed) ORDER BY gid, species, breed;
