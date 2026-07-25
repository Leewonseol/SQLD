-- 02. NULL 치환 함수 — 정답 및 해설

-- Q1 정답: ②
-- 해설: SQL Server의 ISNULL은 (Sybase에서 물려받은 T-SQL 고유 함수라서)
-- 첫 번째 인수의 데이터 타입/길이를 그대로 따르고, 표준 SQL 함수인
-- COALESCE는 인수 전체 중 데이터 타입 우선순위가 가장 높은 타입으로
-- 결과를 승격한다. 그래서 ISNULL(짧은컬럼, 긴리터럴)은 조용히 잘릴 수
-- 있고, COALESCE(짧은컬럼, 긴리터럴)은 SELECT에서는 잘리지 않는다.
-- COALESCE는 인수 개수 제한이 없고(③ 오답), ISNULL은 SQL Server 전용이라
-- Oracle에는 없다(④ 오답).

-- Q2 정답: ②
-- 해설: (A)는 SELECT 목록에서 COALESCE 결과를 그대로 조회만 하는 것이라
-- 결과 컬럼에 물리적 폭 제약이 없어 항상 에러 없이 성공한다. (B)는 그
-- 결과를 VARCHAR(5) 컬럼(null_lab_memo_staging.memo)에 INSERT하려는
-- 것이라, COALESCE 결과 문자열이 5자를 넘으면 Oracle은 ORA-12899, SQL
-- Server는 "String or binary data would be truncated" 에러가 난다.
-- 이 저장소 데이터셋에서는 membership_code가 실제로 NULL인 행이 없어
-- (B)도 이 데이터 그대로는 에러가 안 나지만, 만약 NULL인 행이 있었다면
-- 그 행에서 에러가 났을 것이다 — oracle.sql/sqlserver.sql STEP 5는
-- CAST(NULL AS VARCHAR(5))로 이 상황을 직접 시뮬레이션해서 실제로 에러가
-- 나는 것을 보여준다.

-- Q3 정답 (Oracle/SQL Server 공통)
SELECT customer_id, age, NULLIF(age, 0) AS age_nullif
FROM null_lab_customer
ORDER BY customer_id;
-- 결과: customer_id=4(age=0)만 age_nullif가 NULL로 바뀐다. customer_id=5는
-- 원래 age가 NULL이므로 NULLIF를 거쳐도 그대로 NULL(0과 비교할 대상 자체가
-- 없어 조건이 성립하지 않기 때문 — NULLIF(NULL, 0)은 NULL <> 0이 UNKNOWN이라
-- "같지 않다"로 판정되어 첫 번째 인수인 NULL을 그대로 반환한다).

-- Q4 정답 — Oracle 버전
SELECT customer_id,
       join_date,
       COALESCE(TO_CHAR(join_date, 'YYYY-MM-DD'), '정보없음') AS join_date_display
FROM null_lab_customer
ORDER BY customer_id;
-- 결과: customer_id=3, 11 → '정보없음'. 나머지 → 'YYYY-MM-DD' 문자열.

-- Q4 정답 — SQL Server 버전
SELECT customer_id,
       join_date,
       COALESCE(CONVERT(VARCHAR(10), join_date, 120), '정보없음') AS join_date_display
FROM null_lab_customer
ORDER BY customer_id;
-- 결과: Oracle 버전과 동일한 행 구성(customer_id 3, 11만 '정보없음').
-- CONVERT의 세 번째 인수 120은 ODBC 표준 스타일('YYYY-MM-DD HH:MI:SS')이며
-- VARCHAR(10)으로 자르면 날짜 부분('YYYY-MM-DD')만 남는다.
