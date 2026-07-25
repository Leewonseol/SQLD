-- 07. NULL과 JOIN — 연습문제
-- null_lab_customer.dept_code: 4,10=NULL / 8='D99'(불일치) / 나머지=D01/D02/D03
-- null_lab_dept: D01/D02/D03 3행(PK)

-- =====================================================================
-- Q1. (객관식) null_lab_customer와 null_lab_dept를 dept_code로
-- INNER JOIN했을 때 결과에서 빠지는 customer_id를 모두 고르면?
--
--   ① 4, 8, 10
--   ② 4, 10만
--   ③ 8만
--   ④ 빠지는 행 없음(전부 매칭됨)
--
-- 답: (      )
-- =====================================================================


-- =====================================================================
-- Q2. (객관식) 다음 두 SELECT 결과를 UNION(중복 제거)으로 합치면 몇 행이
-- 나오는가? (둘 다 dept_code 컬럼만 조회하며 값은 각각 NULL이다)
--
--   SELECT dept_code FROM null_lab_customer WHERE customer_id = 4
--   UNION
--   SELECT dept_code FROM null_lab_customer WHERE customer_id = 10;
--
--   ① 0행
--   ② 1행
--   ③ 2행
--   ④ 에러 발생
--
-- 답: (      )
-- =====================================================================


-- =====================================================================
-- Q3. (객관식) Q2와 완전히 같은 데이터로 다음 조건을 실행하면 몇 행이
-- 나오는가?
--
--   SELECT customer_id FROM null_lab_customer c1
--   WHERE EXISTS (
--       SELECT 1 FROM null_lab_customer c2
--       WHERE c2.customer_id = 10 AND c1.dept_code = c2.dept_code
--   ) AND c1.customer_id = 4;
--
--   ① 0행 (NULL = NULL이 여전히 UNKNOWN이라 매칭 안 됨)
--   ② 1행 (NULL끼리는 매칭됨)
--   ③ 2행
--   ④ 에러 발생
--
-- 답: (      )
-- =====================================================================


-- =====================================================================
-- Q4. (SQL 작성) null_lab_customer를 null_lab_dept와 LEFT JOIN해서,
-- 대응하는 부서가 없는(dept_name이 NULL인) 고객의 customer_id와
-- dept_code를 조회하는 SQL을 작성하시오.
--
-- 여기에 작성:


