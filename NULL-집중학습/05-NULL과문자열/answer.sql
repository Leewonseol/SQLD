-- 05. NULL과 문자열 함수 — 정답 및 해설

-- Q1 정답: ②
-- 해설: SQL Server의 + 는 NULL이 하나라도 섞이면 결과 문자열 전체가 NULL이
-- 된다. CONCAT은 NULL을 빈 문자열로 취급하므로 결과가 NULL이 되지 않는다.
-- nickname이 NULL인 customer_id=2,8에서만 두 식의 결과가 갈린다.

-- Q2 정답: ③
-- 해설: Oracle의 내장 CONCAT 함수는 정확히 2개의 인수만 받는다. 3개를
-- 한 번에 넘기면 ORA-00909(인수 개수 부적합)로 컴파일이 실패한다.
-- 3개 이상을 이으려면 CONCAT(CONCAT(a, b), c)처럼 중첩하거나 || 를 써야 한다.

-- Q3 정답: ②
-- 해설: SQL Server의 LEN은 문자열의 뒤쪽(trailing) 공백을 잘라내고 길이를
-- 센다. 공백 한 칸짜리 문자열은 뒤쪽 공백이 통째로 제거되어 길이가 0으로
-- 나온다 — 그래서 LEN만으로는 빈 문자열과 공백 문자열을 구분할 수 없고,
-- DATALENGTH를 함께 써야 한다(01 폴더의 함정과 같은 맥락).

-- Q4 정답
SELECT customer_id,
       CONCAT(customer_name, N'(', nickname, N')') AS full_label
FROM null_lab_customer;
-- CONCAT은 NULL을 빈 문자열로 취급하므로 nickname이 NULL인 행도
-- "이서연()"처럼 괄호만 남고 전체가 NULL이 되지 않는다.

-- Q5 정답
SELECT customer_id, nickname,
       DATALENGTH(nickname) AS nickname_bytes
FROM null_lab_customer
ORDER BY customer_id;
-- DATALENGTH는 실제 저장된 바이트 수를 그대로 반환한다.
-- customer_id=2,8(NULL) → NULL
-- customer_id=3(''): 0
-- customer_id=4(' '): 1
-- LEN을 썼다면 3행과 4행이 둘 다 0으로 나와 구분되지 않았을 것이다.
