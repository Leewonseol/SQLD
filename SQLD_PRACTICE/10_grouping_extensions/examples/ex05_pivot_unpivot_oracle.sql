-- ex05 PIVOT · UNPIVOT (요구목록 §7. 추출본에서 확인되지 않음)  | Oracle 11g+
PROMPT == [Q1] PIVOT: 직무별 행, 부서별 열 (급여 합계). 원본에서 쓰지 않은 컬럼은 인라인 뷰로 미리 제거
SELECT * FROM (SELECT job, deptno, sal FROM emp)
PIVOT (SUM(sal) FOR deptno IN (10 AS d10, 20 AS d20, 30 AS d30))
ORDER BY job;

PROMPT == [Q2] 같은 결과를 CASE + 집계로 (모든 DBMS 공통 방식)
SELECT job, SUM(CASE WHEN deptno = 10 THEN sal END) d10, SUM(CASE WHEN deptno = 20 THEN sal END) d20,
       SUM(CASE WHEN deptno = 30 THEN sal END) d30
FROM emp GROUP BY job ORDER BY job;

PROMPT == [Q3] 함정: 인라인 뷰 없이 테이블 전체로 PIVOT 하면 남은 모든 컬럼(empno, ename …)이 그룹 기준이 된다
SELECT COUNT(*) AS rows_without_inline_view FROM (SELECT * FROM emp PIVOT (SUM(sal) FOR deptno IN (10, 20, 30)));

PROMPT == [Q4] UNPIVOT: 열을 행으로. NULL 값 칸은 기본적으로 빠진다 (INCLUDE NULLS 로 포함)
WITH p AS (SELECT * FROM (SELECT job, deptno, sal FROM emp) PIVOT (SUM(sal) FOR deptno IN (10 AS d10, 20 AS d20, 30 AS d30)))
SELECT job, dept, total FROM p UNPIVOT (total FOR dept IN (d10 AS '10', d20 AS '20', d30 AS '30')) ORDER BY job, dept;
WITH p AS (SELECT * FROM (SELECT job, deptno, sal FROM emp) PIVOT (SUM(sal) FOR deptno IN (10 AS d10, 20 AS d20, 30 AS d30)))
SELECT COUNT(*) AS include_nulls_rows FROM p UNPIVOT INCLUDE NULLS (total FOR dept IN (d10 AS '10', d20 AS '20', d30 AS '30'));
