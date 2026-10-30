-- ex02 GROUP BY 규칙 (요구목록 §7)  | Oracle
PROMPT == [Q1] GROUP BY 에 없는 컬럼을 SELECT 에 쓰면 오류
-- @expect-error: ORA-00979
SELECT deptno, ename, COUNT(*) FROM emp GROUP BY deptno;

PROMPT == [Q2] 여러 컬럼 GROUP BY: (deptno, job) 조합마다 1행
SELECT deptno, job, COUNT(*) AS cnt, SUM(sal) AS sum_sal FROM emp GROUP BY deptno, job ORDER BY deptno, job;

PROMPT == [Q3] NULL 도 하나의 그룹이 된다 (WHERE 의 = 비교와 다르다)
SELECT grp, COUNT(*) AS cnt, SUM(v) AS sum_v FROM g_num GROUP BY grp ORDER BY grp;

PROMPT == [Q4] 집계함수 없는 GROUP BY = DISTINCT 와 같은 행
SELECT job FROM emp GROUP BY job ORDER BY job;

PROMPT == [Q5] 집계함수만 있고 GROUP BY 가 없으면 전체가 한 그룹
SELECT COUNT(*) AS cnt, SUM(sal) AS total FROM emp;

PROMPT == [Q6] 집계함수와 일반 컬럼을 GROUP BY 없이 섞으면 오류
-- @expect-error: ORA-00937
SELECT ename, SUM(sal) FROM emp;

PROMPT == [Q7] GROUP BY 에 표현식 사용
SELECT TO_CHAR(hiredate, 'YYYY') AS hire_year, COUNT(*) AS cnt FROM emp GROUP BY TO_CHAR(hiredate, 'YYYY') ORDER BY hire_year;
