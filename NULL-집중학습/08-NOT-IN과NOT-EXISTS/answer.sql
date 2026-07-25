-- 08. NOT IN과 NOT EXISTS — 정답 및 해설

-- Q1 정답: ③
-- 해설: dept_code NOT IN (SELECT dept_code FROM null_lab_excluded_codes)는
-- dept_code <> 'D02' AND dept_code <> 'D03' AND dept_code <> NULL로 풀린다.
-- 마지막 항은 dept_code가 무엇이든 항상 UNKNOWN이므로 AND 전체가 절대
-- TRUE가 될 수 없다. WHERE는 TRUE인 행만 통과시키므로 결과는 0행이다.

-- Q2 정답: ②
-- 해설: EXISTS/NOT EXISTS는 "상관 서브쿼리에 매칭되는 행이 있는가"만 보는
-- 술어라서 그 자체는 절대 UNKNOWN이 되지 않고 항상 TRUE 또는 FALSE로만
-- 평가된다. 서브쿼리 내부에서 e.dept_code = c.dept_code 비교가 NULL 때문에
-- UNKNOWN이 되어도, 그건 그 행이 매칭 후보에서 빠진다는 뜻일 뿐 EXISTS
-- 판정 자체를 오염시키지 않는다. 그래서 NOT IN과 달리 NULL이 섞여 있어도
-- 정상적으로 동작한다.

-- Q3 정답
SELECT customer_id, customer_name, dept_code
FROM null_lab_customer
WHERE dept_code NOT IN (
    SELECT dept_code FROM null_lab_excluded_codes WHERE dept_code IS NOT NULL
)
ORDER BY customer_id;
-- 결과: customer_id 1, 5, 8, 9 (4행)

-- Q3-보충 정답
-- 서브쿼리의 NULL은 제거됐지만, 바깥쪽 dept_code 자체가 NULL인 행(4, 10)은
-- dept_code <> 'D02' AND dept_code <> 'D03' 비교 자체가 UNKNOWN이 되어
-- 여전히 결과에서 빠지기 때문이다(NOT EXISTS의 6행보다 2행 적은 이유).

-- Q4 정답 (Oracle/SQL Server 공통)
SELECT c.customer_id, c.customer_name, c.dept_code
FROM null_lab_customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM null_lab_excluded_codes e
    WHERE e.dept_code = c.dept_code
)
ORDER BY c.customer_id;
-- 결과: customer_id 1(D01), 4(NULL), 5(D01), 8(D99), 9(D01), 10(NULL) → 6행
-- NOT IN으로는 절대 이 결과(NULL dept_code 행까지 포함한 6행)를 정확히
-- 얻을 수 없다는 것이 이 폴더의 최종 결론이다 — dept_code가 NULL을 허용하는
-- 컬럼이라면 "제외 목록에 없는 행"을 찾는 로직은 NOT EXISTS로 작성하는 것이
-- 원칙이다.
