-- 08. NOT IN과 NOT EXISTS — 연습문제
-- null_lab_customer.dept_code: D01(1,5,9) / D02(2,6,11) / D03(3,7,12) /
-- D99(8, 부서 테이블에 없음) / NULL(4,10)
-- null_lab_excluded_codes = {'D02', 'D03', NULL}

-- =====================================================================
-- Q1. (객관식) 다음 쿼리의 실행 결과로 옳은 것은?
--
--   SELECT COUNT(*) FROM null_lab_customer
--   WHERE dept_code NOT IN (SELECT dept_code FROM null_lab_excluded_codes);
--
--   ① 6 (D02, D03이 아닌 행 + dept_code NULL인 행)
--   ② 4 (D02, D03이 아니면서 dept_code가 NULL이 아닌 행)
--   ③ 0 (서브쿼리에 NULL이 섞여 있어 어떤 행도 조건을 만족할 수 없음)
--   ④ 에러 발생
--
-- 답: (      )
-- =====================================================================


-- =====================================================================
-- Q2. (객관식) Q1과 같은 의도를, dept_code가 null_lab_excluded_codes에
-- 없는 행을 찾는 것으로 바꾸어 아래처럼 NOT EXISTS로 다시 작성했다.
--
--   SELECT COUNT(*) FROM null_lab_customer c
--   WHERE NOT EXISTS (
--       SELECT 1 FROM null_lab_excluded_codes e
--       WHERE e.dept_code = c.dept_code
--   );
--
-- 이 쿼리가 Q1의 NOT IN 쿼리와 다른 결과를 내는 근본적인 이유는?
--
--   ① NOT EXISTS는 SQL Server에서만 지원되기 때문
--   ② EXISTS/NOT EXISTS는 매칭 존재 여부만 보는 술어라 항상 TRUE/FALSE로만
--      평가되고, NOT IN처럼 서브쿼리의 NULL 때문에 AND 체인 전체가
--      UNKNOWN이 되는 문제가 생기지 않기 때문
--   ③ NOT EXISTS는 NULL을 자동으로 0으로 치환하기 때문
--   ④ 두 쿼리는 사실 항상 같은 결과를 낸다
--
-- 답: (      )
-- =====================================================================


-- =====================================================================
-- Q3. (SQL 작성) null_lab_excluded_codes 서브쿼리에 IS NOT NULL 조건을
-- 추가해서 NOT IN을 "부분적으로" 안전하게 만든 쿼리를 작성하시오.
-- (customer_id, customer_name, dept_code를 조회)
--
-- 여기에 작성:



-- Q3-보충. (서술) 위 Q3 쿼리가 여전히 NOT EXISTS 버전과 결과가 다른 이유를
-- 한 문장으로 설명하시오.
--
-- 답:
-- =====================================================================


-- =====================================================================
-- Q4. (SQL 작성) null_lab_customer에서 dept_code가 null_lab_excluded_codes에
-- 들어있지 않은 행(NULL인 dept_code 포함)을 정확히 6행 모두 가져오는
-- 쿼리를 NOT EXISTS를 이용해 작성하시오.
--
-- 여기에 작성:


