-- 04. NULL과 집계함수 — 정답 및 해설

-- Q1 정답: ③
-- 해설: COUNT(*)는 NULL 여부와 무관하게 전체 행 수(12)를 센다. COUNT(score)
-- 는 score가 NULL이 아닌 행만 센다 — score가 NULL인 customer_id 3, 9를
-- 제외한 10이 나온다.

-- Q2 정답: ②
-- 해설: AVG(score)는 NULL 2개를 아예 분모·분자 계산에서 제외한
-- 748/10=74.8이고, AVG(COALESCE(score,0))는 NULL을 0으로 채워 분모를
-- 12로 늘린 748/12=62.333...이다. 분자(합계)는 748로 동일하지만 분모가
-- 커지므로 AVG(COALESCE(score,0))이 항상 더 작거나 같다(NULL을 0이 아닌
-- 양수로 채웠다면 결과는 또 달라졌을 것이다 — 이 문제는 "0으로 채운
-- 경우"에 한정된 비교라는 점에 유의).

-- Q3 정답 (SQL Server)
SELECT AVG(CAST(score AS DECIMAL(10,2))) AS avg_score_decimal
FROM null_lab_customer;
-- 결과: 74.80(정확한 값). CAST 없이 AVG(score)만 쓰면 score가 INT라
-- 반환 타입도 INT로 고정되어 74.8의 소수부가 잘려 74가 나온다 — SQL
-- Server가 정수 컬럼의 AVG 결과 타입을 입력 타입과 같은 카테고리로
-- 고정하기 때문(공식 문서 근거). Oracle은 NUMBER가 정수/소수를 구분하지
-- 않아 이 CAST 없이도 74.8이 정확히 나온다.

-- Q4 정답 (Oracle/SQL Server 공통)
SELECT dept_code,
       COUNT(*)     AS n_all,
       COUNT(score) AS n_scored,
       SUM(score)   AS sum_score,
       MIN(score)   AS min_score,
       MAX(score)   AS max_score
FROM null_lab_customer
WHERE score IS NULL
GROUP BY dept_code;
-- 결과: dept_code='D01'(customer_id=9)과 'D03'(customer_id=3) 두 그룹이
-- 나오고, 두 그룹 모두 n_all=1, n_scored=0, sum_score/min_score/max_score
-- 는 전부 NULL이다. WHERE절에서 이미 score가 NULL인 행만 걸러냈으므로
-- 남은 각 그룹의 score 값은 전부 NULL이고, 더하거나 비교할 값 자체가
-- 없으므로 SUM/MIN/MAX가 NULL이 되는 것이 당연한 결과다. COUNT(*)만
-- "행이 존재한다"는 사실 자체를 세므로 1이 나온다.
