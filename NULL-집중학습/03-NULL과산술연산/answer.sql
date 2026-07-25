-- 03. NULL과 산술 연산 — 정답 및 해설

-- Q1 정답: ②
-- 해설: NULL이 관여한 산술연산은 곱하는 값이 0이더라도 항상 NULL이다.
-- NULL은 "알 수 없는 값"이므로 "알 수 없는 값 × 0"도 "알 수 없다"로 남는다
-- — 수학적으로 0을 곱하면 0이 된다는 직관을 SQL의 NULL에 그대로 적용하면
-- 틀린다.

-- Q2 정답: ①
-- 해설: discount_qty=0인 customer_id=2 행에서 "0으로 나누기" 에러가
-- 발생해 쿼리 전체(모든 행)가 실패한다 — SQL은 한 행에서 에러가 나면
-- 그 SELECT 문 전체가 실패하고 다른 행의 결과도 반환되지 않는다.
-- customer_id=7(discount_qty=NULL)은 에러가 아니라 NULL을 반환하지만,
-- customer_id=2의 에러 때문에 그 결과조차 보이지 않는다.

-- Q3 정답 (Oracle/SQL Server 공통)
SELECT customer_id,
       order_qty,
       discount_qty,
       order_qty / NULLIF(discount_qty, 0) AS ratio
FROM null_lab_customer
ORDER BY customer_id;
-- 결과: customer_id=2 → ratio=NULL(에러 대신 NULL로 방어됨).
-- customer_id=7 → ratio=NULL(원래도 NULL이었으므로 동일). 나머지 10행은
-- 정상적인 나눗셈 결과(Oracle은 소수 포함, SQL Server는 order_qty/
-- discount_qty가 둘 다 INT라 정수 나눗셈 결과).

-- Q4 정답 — Oracle 버전
SELECT customer_id,
       nickname,
       NVL(nickname, '고객') || '님' AS greeting
FROM null_lab_customer
ORDER BY customer_id;
-- 결과: customer_id 2, 3(Oracle에서 ''→NULL로 저장됨), 8 → '고객님'.
-- 나머지는 '원래닉네임님'.

-- Q4 정답 — SQL Server 버전
SELECT customer_id,
       nickname,
       ISNULL(nickname, N'고객') + N'님' AS greeting
FROM null_lab_customer
ORDER BY customer_id;
-- 결과: customer_id 2, 8 → '고객님'. customer_id=3은 nickname이 ''(NULL
-- 아님)이라 ISNULL이 관여하지 않아 '님'만 남는다 — Oracle 버전과 다른
-- 결과가 나오는 것이 정상이다(01 폴더의 ''→NULL 저장 규칙 차이 때문).
