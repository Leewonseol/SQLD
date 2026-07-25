-- 06. NULL과 WHERE/CASE — 연습문제
-- null_lab_customer: score(NULL 3,9행), dept_code(NULL 4,10행, 'D99' 8행,
-- 나머지 D01/D02/D03 정상 매칭)

-- =====================================================================
-- Q1. (객관식) WHERE score > 80 AND dept_code = 'D01' 조건에서
-- customer_id=9(score=NULL, dept_code='D01')가 결과에서 빠지는 이유는?
--
--   ① dept_code 조건이 FALSE라서
--   ② score 조건이 FALSE라서
--   ③ score 조건이 UNKNOWN이고 dept_code 조건이 TRUE라 전체가 UNKNOWN이 되어서
--   ④ 두 조건 모두 FALSE라서
--
-- 답: (      )
-- =====================================================================


-- =====================================================================
-- Q2. (객관식) 다음 SQL을 실행했을 때 dept_code가 NULL인 행(customer_id
-- 4, 10)의 결과는?
--
--   SELECT customer_id,
--          CASE dept_code WHEN NULL THEN 'A' ELSE 'B' END AS result
--   FROM null_lab_customer;
--
--   ① 'A' (NULL을 정상적으로 잡는다)
--   ② 'B' (Simple CASE는 NULL을 절대 못 잡는다)
--   ③ NULL
--   ④ 에러 발생
--
-- 답: (      )
-- =====================================================================


-- =====================================================================
-- Q3. (SQL 작성) Q2의 SQL을 Simple CASE 대신 Searched CASE로 고쳐서,
-- dept_code가 NULL인 행은 'A', 아니면 'B'가 정확히 나오도록 작성하시오.
--
-- 여기에 작성:



-- =====================================================================
-- Q4. (SQL 작성) null_lab_customer에서 score가 60 이상이면서 동시에
-- dept_code가 'D02'인 행만 조회하는 SQL을 작성하고, 이 조건에서 NULL
-- 때문에 배제되는 행이 있는지(customer_id로) 확인하시오.
--
-- 여기에 작성:


