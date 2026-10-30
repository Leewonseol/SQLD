-- ex05 NTILE · PERCENT_RANK · CUME_DIST · RATIO_TO_REPORT (PDF E-35)  | Oracle
PROMPT == [Q1] PDF: 14명을 3그룹 -> 5, 5, 4 (나누어떨어지지 않으면 앞 그룹이 1명씩 더 많다)
SELECT grp, COUNT(*) AS cnt FROM (SELECT NTILE(3) OVER (ORDER BY sal, empno) grp FROM emp) GROUP BY grp ORDER BY grp;

PROMPT == [Q2] PDF: NTILE(2) OVER (ORDER BY SAL)
SELECT ename, sal, deptno, NTILE(2) OVER (ORDER BY sal, empno) AS group_no FROM emp ORDER BY sal, empno;

PROMPT == [Q3] PERCENT_RANK = (RANK-1)/(행수-1), CUME_DIST = (현재 값 이하 행 수)/행수
SELECT ename, sal, RANK() OVER (ORDER BY sal) rnk, ROUND(PERCENT_RANK() OVER (ORDER BY sal), 3) pct_rank,
       ROUND(CUME_DIST() OVER (ORDER BY sal), 3) cume FROM emp WHERE deptno = 30 ORDER BY sal, ename;

PROMPT == [Q4] RATIO_TO_REPORT(Oracle 전용): 합계 대비 비율
SELECT ename, sal, ROUND(RATIO_TO_REPORT(sal) OVER (), 3) ratio, ROUND(sal / SUM(sal) OVER (), 3) same_by_sum FROM emp WHERE deptno = 10 ORDER BY sal DESC;
