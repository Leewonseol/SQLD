-- ex06 GROUP BY 와 윈도우 함수의 차이 (요구목록 §9)  | Oracle
PROMPT == [Q1] GROUP BY: 그룹마다 1행 -> 3행. 개별 사원 컬럼은 볼 수 없다
SELECT deptno, SUM(sal) AS dept_sum FROM emp GROUP BY deptno ORDER BY deptno;

PROMPT == [Q2] 윈도우: 행 수 유지(14행) + 그룹 값을 각 행에 붙인다
SELECT deptno, ename, sal, SUM(sal) OVER (PARTITION BY deptno) AS dept_sum, ROUND(sal / SUM(sal) OVER (PARTITION BY deptno) * 100, 1) AS pct
FROM emp ORDER BY deptno, sal DESC, ename;

PROMPT == [Q3] 윈도우 함수는 GROUP BY 결과 위에서도 동작한다 (처리 순서: GROUP BY -> SELECT 의 윈도우)
SELECT deptno, SUM(sal) AS dept_sum, SUM(SUM(sal)) OVER () AS grand_total, RANK() OVER (ORDER BY SUM(sal) DESC) AS rnk
FROM emp GROUP BY deptno ORDER BY deptno;

PROMPT == [Q4] 행 수 비교
SELECT (SELECT COUNT(*) FROM (SELECT deptno FROM emp GROUP BY deptno)) group_rows,
       (SELECT COUNT(*) FROM (SELECT deptno, SUM(sal) OVER (PARTITION BY deptno) s FROM emp)) window_rows,
       (SELECT COUNT(*) FROM (SELECT DISTINCT deptno, SUM(sal) OVER (PARTITION BY deptno) s FROM emp)) window_distinct_rows FROM dual;
