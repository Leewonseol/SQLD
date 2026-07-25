-- 10. NULL과 형변환 — 정답 및 해설

-- Q1 정답: ②
-- 해설: 형변환 함수는 값의 표현 형식만 바꿀 뿐 "값이 없음"이라는 NULL의
-- 상태 자체를 없애지 못한다. CAST(NULL AS 어떤자료형)은 항상 그 자료형의
-- NULL이다. 0이나 빈 문자열 같은 기본값으로 바뀌지 않는다.

-- Q2 정답: ③
-- 해설: 'A001'은 실제로 존재하는 값이지만 숫자로 변환할 수 없는 형식이다.
-- NULL 입력과 달리 "값은 있지만 변환 불가능한 값"은 Oracle에서 런타임
-- 에러(ORA-01722)를 발생시킨다. NULL 입력(에러 없이 NULL 반환)과 변환
-- 실패(에러 발생)를 구분하는 것이 이 폴더의 핵심이다.

-- Q3 정답
SELECT customer_id, membership_code,
       TRY_CAST(membership_code AS INT) AS converted
FROM null_lab_customer
ORDER BY customer_id;
-- 결과: customer_id=5만 converted=0, 나머지 11행은 converted=NULL
-- (에러 없이 전체 12행이 모두 조회된다는 것이 핵심 — 일반 CAST였다면
-- customer_id=1에서 에러로 멈췄을 것이다.)

-- Q4 정답: ②
-- 해설: Oracle 12c부터 TO_NUMBER, TO_DATE, TO_CHAR에 DEFAULT 값 ON
-- CONVERSION ERROR 절을 붙일 수 있다. 이는 SQL Server의 TRY_CONVERT/
-- TRY_CAST와 동등한 효과(변환 실패 시 에러 대신 지정한 기본값, 흔히 NULL을
-- 반환)를 낸다. Oracle에는 TRY_CAST라는 이름의 함수 자체가 없다는 것에
-- 주의해야 한다.

-- Q5 정답
SELECT customer_id, join_date,
       TO_CHAR(join_date, 'YYYY-MM-DD') AS join_date_str
FROM null_lab_customer
ORDER BY customer_id;

-- 결과값(서술):
-- customer_id 3, 11(join_date가 원래 NULL인 행)의 join_date_str은 화면에
-- 아무 값도 표시되지 않는 SQL NULL이다. 문자열 "NULL"이라는 4글자짜리
-- 값이 저장되는 것이 아니다 — TO_CHAR에 NULL을 넣으면 결과도 NULL이라는
-- STEP 2의 원칙이 날짜 변환에도 그대로 적용된다.
