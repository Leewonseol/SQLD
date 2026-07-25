-- 06. NULL과 WHERE/CASE — 정답 및 해설

-- Q1 정답: ③
-- 해설: score>80은 score가 NULL이라 UNKNOWN, dept_code='D01'은 TRUE다.
-- UNKNOWN AND TRUE = UNKNOWN(00 폴더 진리표)이라 WHERE는 이 행을 버린다.
-- "dept_code 조건은 맞는데 왜 안 나오지"라는 함정이 여기서 나온다.

-- Q2 정답: ②
-- 해설: Simple CASE(`CASE dept_code WHEN NULL THEN ...`)는 내부적으로
-- dept_code = NULL과 동치인 비교를 하므로 dept_code가 실제로 NULL이어도
-- 절대 TRUE가 될 수 없다. 그래서 모든 행이(NULL인 행 포함) ELSE인 'B'로
-- 떨어진다.

-- Q3 정답
SELECT customer_id,
       CASE WHEN dept_code IS NULL THEN 'A' ELSE 'B' END AS result
FROM null_lab_customer;
-- Searched CASE는 IS NULL 술어를 조건으로 직접 쓸 수 있어 dept_code가
-- 정말 NULL인 4, 10행만 'A'로 정확히 분류된다.

-- Q4 정답
SELECT customer_id, score, dept_code
FROM null_lab_customer
WHERE score >= 60 AND dept_code = 'D02';
-- 결과: customer_id = 2(score=92), 11(score=82) — 2행.
--
-- NULL 때문에 배제되는 행이 있는지 확인:
SELECT customer_id, score, dept_code
FROM null_lab_customer
WHERE dept_code = 'D02';
-- dept_code='D02'인 행은 customer_id 2, 6, 11 세 개뿐이고 이 중 score가
-- NULL인 행은 없다(6번은 score=0으로 실제 값 있음, 0 < 60이라 확정 FALSE로
-- 배제된 것이지 UNKNOWN 때문이 아니다). 따라서 이 특정 조건에서는 NULL로
-- 인해 "몰라서" 빠진 행이 없다 — 매번 "NULL이 있으니 결과가 이상하겠지"라고
-- 넘겨짚지 말고 실제 데이터를 확인해야 한다는 것이 이 문제의 요점이다.
