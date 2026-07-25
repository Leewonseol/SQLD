-- 07. NULL과 JOIN — 정답 및 해설

-- Q1 정답: ①
-- 해설: customer_id=4,10은 dept_code가 NULL이라 = 비교가 항상 UNKNOWN이고,
-- customer_id=8은 dept_code='D99'로 null_lab_dept에 대응하는 행이 없어
-- FALSE다. 셋 다 ON 조건이 TRUE가 될 수 없어 INNER JOIN 결과에서 빠진다.

-- Q2 정답: ②
-- 해설: UNION(중복 제거를 수행하는 집합연산)은 = 비교와 달리 NULL과 NULL을
-- "같은 값"으로 취급한다. 두 SELECT 결과가 모두 (NULL) 하나뿐이므로 중복
-- 으로 인식되어 1행으로 합쳐진다.

-- Q3 정답: ①
-- 해설: EXISTS 서브쿼리 안의 c1.dept_code = c2.dept_code는 결국 = 비교다.
-- Q2의 UNION과 데이터는 같지만 여기서는 "같은 그룹으로 묶기"가 아니라
-- "두 값이 같은지 판정"하는 문맥이므로 NULL = NULL은 여전히 UNKNOWN이고,
-- WHERE는 UNKNOWN을 FALSE와 함께 버린다. 그 결과 이 쿼리는 0행을 반환한다.
-- Q2(집합연산)와 Q3(= 비교)가 같은 데이터로 정반대 결과를 낸다는 것이
-- 이 폴더의 핵심 함정이다.

-- Q4 정답
SELECT c.customer_id, c.dept_code
FROM null_lab_customer c
LEFT JOIN null_lab_dept d ON c.dept_code = d.dept_code
WHERE d.dept_name IS NULL;
-- 결과: customer_id = 4(dept_code=NULL), 8(dept_code='D99'), 10(dept_code=NULL).
-- LEFT JOIN으로 일단 전체 고객을 보존한 뒤, 매칭되는 부서가 없어 dept_name이
-- NULL로 채워진 행만 걸러내는 것이 "대응 데이터가 없는 행을 찾는" 표준 패턴이다.
