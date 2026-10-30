-- ex05 ORDER BY (PDF E-08)  | Oracle
PROMPT == [Q1] ASC 기본: Oracle 은 NULL 을 가장 큰 값으로 보아 맨 뒤에
SELECT ename, comm FROM emp WHERE deptno = 30 ORDER BY comm, ename;

PROMPT == [Q2] DESC: NULL 이 맨 앞
SELECT ename, comm FROM emp WHERE deptno = 30 ORDER BY comm DESC, ename;

PROMPT == [Q3] NULLS FIRST / NULLS LAST 로 위치 지정 (PDF 의 "NULL LAST | NULL FISRT" 는 오기, 정확한 키워드는 NULLS)
SELECT ename, comm FROM emp WHERE deptno = 30 ORDER BY comm NULLS FIRST, ename;
SELECT ename, comm FROM emp WHERE deptno = 30 ORDER BY comm DESC NULLS LAST, ename;

PROMPT == [Q4] 별칭·위치 번호·표현식, 여러 키와 서로 다른 방향
SELECT deptno, ename, sal * 12 AS annual FROM emp WHERE deptno IN (10, 20) ORDER BY 1 DESC, annual, ename;

PROMPT == [Q5] SELECT 에 없는 컬럼으로 정렬 (GROUP BY·DISTINCT 가 없으면 허용)
SELECT ename FROM emp WHERE deptno = 10 ORDER BY sal DESC;

PROMPT == [Q6] DISTINCT 와 SELECT 에 없는 컬럼 정렬 -> 오류
-- @expect-error: ORA-01791
SELECT DISTINCT job FROM emp ORDER BY sal;

PROMPT == [Q7] GROUP BY 후 그룹 컬럼도 집계도 아닌 컬럼으로 정렬 -> 오류
-- @expect-error: ORA-00979
SELECT deptno, COUNT(*) FROM emp GROUP BY deptno ORDER BY ename;

PROMPT == [Q8] GROUP BY 후 SELECT 에 없는 '그룹 컬럼'이나 '집계'로 정렬 -> 허용 (PDF E-08 서술과 비교)
SELECT deptno, COUNT(*) AS cnt FROM emp GROUP BY deptno, job ORDER BY job, deptno FETCH FIRST 4 ROWS ONLY;
SELECT deptno FROM emp GROUP BY deptno ORDER BY MAX(sal);

PROMPT == [Q9] 인라인 뷰 안의 ORDER BY: Oracle 은 허용
SELECT * FROM (SELECT ename, sal FROM emp ORDER BY sal DESC) WHERE ROWNUM <= 2;
