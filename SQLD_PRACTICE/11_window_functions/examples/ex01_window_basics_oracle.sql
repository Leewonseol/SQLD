-- ex01 윈도우 함수의 효과와 집계 윈도우 (PDF E-32)  | Oracle
PROMPT == [Q1] PDF: 집계함수 결과와 행 정보는 GROUP BY 없이 함께 출력할 수 없다 -> 오류
-- @expect-error: ORA-00937
SELECT empno, ename, sal, SUM(sal) AS total FROM emp;

PROMPT == [Q2] 해결 1 스칼라 서브쿼리 / 해결 2 윈도우 함수 SUM(sal) OVER ()
SELECT empno, ename, sal, (SELECT SUM(sal) FROM emp) AS total_subq, SUM(sal) OVER () AS total_win FROM emp WHERE deptno = 10 ORDER BY empno;

PROMPT == [Q3] PDF: SUM(price) OVER (PARTITION BY publisher ORDER BY price) -> 출판사 안에서 가격순 누적합
SELECT book_name, publisher, price, SUM(price) OVER (PARTITION BY publisher ORDER BY price) AS total FROM bookshelf ORDER BY publisher, price;

PROMPT == [Q4] PDF: AVG(price) OVER (PARTITION BY publisher ORDER BY price) -> 누적 평균 (PDF 의 13,566.57 과 비교)
SELECT book_name, publisher, price, ROUND(AVG(price) OVER (PARTITION BY publisher ORDER BY price), 2) AS avg FROM bookshelf ORDER BY publisher, price;

PROMPT == [Q5] ORDER BY 를 빼면 누적이 아니라 파티션 전체 합 (PDF "ORDER BY를 명시하지 않을 경우엔 합이 누적으로 계산되지 않음")
SELECT book_name, publisher, price, SUM(price) OVER (PARTITION BY publisher) AS total FROM bookshelf ORDER BY publisher, price;

PROMPT == [Q6] COUNT·MAX·MIN 윈도우
SELECT ename, deptno, sal, COUNT(*) OVER (PARTITION BY deptno) cnt, MAX(sal) OVER (PARTITION BY deptno) mx, MIN(sal) OVER (PARTITION BY deptno) mn
FROM emp WHERE deptno = 10 ORDER BY sal DESC;
