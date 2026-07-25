-- 01. NULL 판정 — 정답 및 해설

-- Q1 정답: ②
-- 해설: Oracle은 VARCHAR2(및 CHAR) 컬럼에 저장되는 빈 문자열을 NULL과
-- 동일하게 취급한다. INSERT문 자체는 에러 없이 성공하지만, 저장된 값은
-- NULL이 되어 IS NULL 조건이 TRUE가 된다.

-- Q2 정답: ②
-- 해설: SQL Server(ANSI SQL 표준)는 = 비교 시 길이가 다른 문자열의 짧은
-- 쪽을 공백으로 채워(pad) 비교한다. ''(길이0)이 ' '(길이1)로 패딩되어
-- 같다고 판정되므로, ''을 찾는 조건이 공백 한 칸짜리 값도 함께 찾아온다.
-- "SQL Server는 ''과 NULL을 구분한다"는 사실과 "= 비교로 ''과 ' '을
-- 구분할 수 있다"는 것은 별개라는 점이 이 문제의 핵심.

-- Q3 정답
SELECT customer_id, nickname
FROM null_lab_customer
WHERE nickname = '' AND DATALENGTH(nickname) = 0;
-- 결과: customer_id = 3만 나온다. DATALENGTH로 실제 바이트 길이를 추가
-- 확인해야 ' '(DATALENGTH=1)이 걸러진다.

-- Q4 정답 (Oracle/SQL Server 공통)
SELECT customer_id
FROM null_lab_customer
WHERE nickname IS NULL;
-- Oracle 결과: customer_id 2, 3, 8 (3행 — Oracle은 3행의 ''도 NULL로
-- 저장했으므로 여기 포함된다)
-- SQL Server 결과: customer_id 2, 8 (2행 — 3행은 ''으로 남아 있어 제외된다)
-- 같은 SQL, 같은 데이터를 넣었는데 결과 행 수가 DBMS에 따라 다르다는 것
-- 자체가 01 폴더 전체의 핵심 결론이다.
