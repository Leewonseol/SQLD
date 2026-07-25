-- 09. NULL 정렬과 윈도우 함수 — 정답 및 해설

-- Q1 정답: ②
-- 해설: Oracle은 ORDER BY ... ASC(오름차순)에서 NULL을 기본적으로 가장
-- 큰 값처럼 취급해 맨 뒤에 둔다(NULLS LAST가 기본값). customer_id 3, 9는
-- 결과의 마지막 두 행으로 나온다.

-- Q2 정답: ②
-- 해설: SQL Server는 NULL을 항상 가장 작은 값처럼 취급한다. 그래서
-- ORDER BY ... ASC에서는 NULL이 맨 앞에 온다 — Oracle의 기본값과 정확히
-- 반대다. 같은 SQL, 같은 데이터라도 DBMS 기본값 차이 때문에 결과 순서가
-- 달라진다는 점이 이 폴더의 핵심이다.

-- Q3 정답
SELECT customer_id, score
FROM null_lab_customer
ORDER BY CASE WHEN score IS NULL THEN 1 ELSE 0 END, score ASC, customer_id;
-- 해설: SQL Server 기본값(ASC=NULL 맨 앞)을 뒤집으려면 NULL 여부를 먼저
-- CASE로 0/1 그룹핑하고, 그 다음 실제 값으로 정렬해야 한다. 이 쿼리는
-- score 오름차순으로 정렬하되 NULL인 3, 9행만 맨 뒤로 보낸다.

-- Q4 정답: ②
-- 해설: RANK/DENSE_RANK 같은 정렬·순위 계산 맥락에서는 NULL을 서로 "같다"고
-- 취급하는 것이 SQL 표준의 공통 규칙이다. = 비교에서 NULL끼리 절대 같다고
-- 판정되지 않는 3값 논리(00, 01 폴더)와는 별개의 규칙이라는 점을 구분해야
-- 한다.

-- Q5 정답 (Oracle/SQL Server 공통 — SELECT 문법 동일)
SELECT customer_id, dept_code, score,
       ROW_NUMBER() OVER (PARTITION BY dept_code ORDER BY customer_id) AS rn_in_dept
FROM null_lab_customer
ORDER BY dept_code, customer_id;
-- 결과: dept_code가 NULL인 customer_id 4, 10이 하나의 파티션으로 묶여
-- 그 안에서만 rn_in_dept = 1, 2가 매겨진다(4번이 1, 10번이 2). D01, D02,
-- D03, D99 각각도 독립된 파티션으로 나뉜다.
-- 참고: dept_code가 NULL인 행을 결과 맨 뒤/앞 어디에 표시할지는 ORDER BY의
-- NULL 정렬 기본값(Oracle=뒤, SQL Server=앞)을 따른다 — 이는 파티션이
-- 나뉘는 방식과는 무관하고 단순히 "출력 순서"의 문제일 뿐이다.
