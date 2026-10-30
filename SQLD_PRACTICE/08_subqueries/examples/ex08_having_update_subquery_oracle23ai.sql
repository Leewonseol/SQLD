-- ex08 버전 비교용: Oracle 23ai 계열(26ai Free 23.26.3) 에서 Q1 재실행
-- @requires: 00_common
PROMPT == [Q1] HAVING 서브쿼리 + ORDER BY deptno (21c XE 21.3 에서 정렬이 어긋났던 쿼리)
SELECT deptno, ROUND(AVG(sal), 2) AS avg_sal FROM emp GROUP BY deptno HAVING AVG(sal) > (SELECT AVG(sal) FROM emp) ORDER BY deptno;
SELECT banner_full FROM v$version;
