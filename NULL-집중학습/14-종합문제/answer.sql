-- 14. 종합문제 — 정답 및 해설

-- Q1 정답: ② FALSE
-- 해설: AND는 FALSE가 하나라도 있으면 다른 값과 무관하게 무조건 FALSE다
-- (00 폴더 진리표, 단축 평가).

-- Q2 정답
SELECT COUNT(*) AS null_nickname_count
FROM null_lab_customer
WHERE nickname IS NULL;
-- Oracle: 3 (customer_id 2,3,8 — 3행의 원래 빈 문자열 ''이 Oracle에서
-- NULL로 저장되기 때문)
-- SQL Server: 2 (customer_id 2,8 — SQL Server는 ''과 NULL을 구분해서
-- 저장하므로 3행은 nickname=''으로 남아 IS NULL이 FALSE)

-- Q3 정답 (Oracle)
SELECT customer_id,
       COALESCE(TO_CHAR(join_date, 'YYYY-MM-DD'), '정보없음') AS join_date_display
FROM null_lab_customer
ORDER BY customer_id;
-- join_date를 먼저 TO_CHAR로 문자열로 바꾼 뒤에 COALESCE해야 한다.
-- COALESCE(join_date, '정보없음')을 그대로 쓰면 '정보없음'을 DATE로
-- 변환하려다 에러가 난다(02 폴더 "날짜와 문자열 혼합" 참고).

-- Q4 정답
SELECT customer_id, order_qty, discount_qty,
       order_qty / NULLIF(discount_qty, 0) AS safe_division
FROM null_lab_customer
ORDER BY customer_id;
-- discount_qty=0인 행(customer_id=2)은 NULLIF가 0을 NULL로 바꿔줘서
-- 나눗셈 결과가 에러 대신 NULL이 된다(03 폴더).

-- Q5 정답
SELECT COUNT(*) AS count_star, COUNT(score) AS count_score,
       COUNT(*) - COUNT(score) AS null_score_count
FROM null_lab_customer;
-- count_star=12, count_score=10, null_score_count=2
-- (customer_id 3, 9의 score가 NULL — 04 폴더)

-- Q6 정답: ② 결과가 NULL이 됨
-- 해설: 정정 — 이 문제는 함정이다. SQL Server의 CONCAT() 함수는 NULL을
-- 빈 문자열로 취급하므로 실제로는 ③에 가까운 동작(nickname이 빈 문자열
-- 취급되어 '님'만 반환)을 한다. `nickname + '님'`(+ 연산자)이라면 결과가
-- NULL이 되지만, CONCAT()은 그렇지 않다는 것이 05 폴더의 핵심 대조점이다.
-- 정답: ③ '님'만 반환됨 (CONCAT은 NULL을 빈 문자열로 취급 — + 와 정반대)

-- Q7 정답: ② 'Y'
-- 해설: Simple CASE(`CASE expr WHEN val THEN ...`)의 내부 비교는 결국
-- `dept_code = NULL`과 동치라서 항상 UNKNOWN이 되어 절대 'X'로 못 간다.
-- ELSE로 떨어져 'Y'가 반환된다(06 폴더).

-- Q8 정답
SELECT c.customer_id, c.dept_code, d.dept_name
FROM null_lab_customer c
LEFT JOIN null_lab_dept d ON c.dept_code = d.dept_code
WHERE d.dept_name IS NULL
ORDER BY c.customer_id;
-- 결과: customer_id 4, 10(dept_code NULL), 8(dept_code='D99', 대응 부서
-- 없음) — 총 3행 (07 폴더).

-- Q9 정답: ② 0행이 나온다
-- 해설: NOT IN은 내부적으로 모든 값과 <> 비교를 AND로 묶는데, 목록에
-- NULL이 섞여 있으면 그 항의 <> 비교가 항상 UNKNOWN이라 AND 전체가
-- 절대 TRUE가 될 수 없다(08 폴더, 00 폴더 진리표).

-- Q10 정답: ① 맨 앞
-- 해설: SQL Server는 ASC/DESC와 무관하게 NULL을 가장 작은 값처럼 취급해
-- 항상 먼저 정렬한다. Oracle은 기본적으로 ASC일 때 NULL이 맨 뒤, DESC일
-- 때 맨 앞으로 SQL Server와 다르다(09 폴더).

-- Q11 정답: ③ 에러가 발생한다
-- 해설: 'A001'은 숫자로 변환할 수 없는 문자열이라 Oracle은
-- ORA-01722(invalid number) 에러를 낸다. 반면 membership_code='0'인 행
-- (customer_id=5)은 정상적으로 0으로 변환된다(10 폴더).

-- Q12 정답: ② 정상적으로 허용된다(CHECK는 UNKNOWN을 통과시킨다)
-- 해설: CHECK 제약은 그 조건이 명시적으로 FALSE가 되는 행만 거부한다.
-- score가 NULL이면 `score >= 0`은 UNKNOWN이고, UNKNOWN은 위반(FALSE)이
-- 아니므로 통과된다 — WHERE가 UNKNOWN을 버리는 것과 정반대 동작이다
-- (11 폴더, 이 모듈에서 가장 자주 나오는 함정 중 하나).

-- Q13 정답 예시
-- kNN(strict)의 전체 RMSE(31360.29)가 평균(39576.11)·중앙값(41995.17)보다
-- 낮은 것은 사실이지만, 이 수치는 C019 한 행의 압도적인 오차에 크게
-- 좌우된다. C019를 제외하면 kNN RMSE는 6.33까지 떨어져 평균 대체
-- (6331.5)와 격차가 훨씬 커지는 반면, C019가 포함된 전체 비교만 보면
-- kNN의 우위가 실제보다 작아 보인다 — "전체 RMSE 한 숫자"만으로 방법의
-- 우열을 단정하면 개별 사례(이웃이 근본적으로 부족한 특이 관측치)에서의
-- 실패를 놓칠 수 있다.

-- Q14 정답 예시
-- 1) NULL은 "알 수 없음"이며 =/<>로는 절대 판정할 수 없다 — IS NULL만이
--    유일하게 올바른 방법이다.
-- 2) 같은 SQL이라도 Oracle과 SQL Server는 빈 문자열·정렬 순서·UNIQUE
--    제약 등에서 NULL을 다르게 처리하므로, "표준 SQL이니 결과도 같을
--    것"이라고 가정하면 안 된다.
-- 3) NULL 처리 함수(NVL/ISNULL/COALESCE)나 대치 전략(평균/중앙값/kNN)은
--    상황에 따라 결과가 크게 달라지므로, 자료형·극단값·예외 사례까지
--    직접 확인한 뒤에 선택해야 한다.
