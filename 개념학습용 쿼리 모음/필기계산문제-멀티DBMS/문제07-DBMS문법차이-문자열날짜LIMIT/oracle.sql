-- 문제07: 문자열·날짜·상위N행·NULL 문법 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요 (이 세션에는 Oracle 실행 환경이 없음)

DROP TABLE customers;

CREATE TABLE customers (
    last_name   VARCHAR2(5),
    first_name  VARCHAR2(5),
    signup_date DATE,
    phone       VARCHAR2(20)
);

INSERT INTO customers VALUES ('김','민준', DATE '2024-03-15', '010-1111-2222');
INSERT INTO customers VALUES ('이','서연', DATE '2024-07-01', NULL);
INSERT INTO customers VALUES ('박','도윤', DATE '2023-11-20', '010-3333-4444');
INSERT INTO customers VALUES ('최','하은', DATE '2025-01-10', NULL);
INSERT INTO customers VALUES ('정','지호', DATE '2024-05-05', '010-5555-6666');
COMMIT;

-- (1) 문자열 결합: || / (2) 날짜 차이: DATE - DATE = 일수(숫자) / (3) NULL 처리: NVL
-- (4) 상위 3행: FETCH FIRST (12c+) 또는 ROWNUM 서브쿼리
SELECT last_name || first_name AS full_name,
       signup_date,
       DATE '2025-06-01' - signup_date AS days_since_signup,
       NVL(phone, '미등록') AS phone_display
FROM customers
ORDER BY signup_date DESC
FETCH FIRST 3 ROWS ONLY;

-- ROWNUM 버전(11g 이하 호환) - 반드시 서브쿼리로 정렬을 먼저 끝내야 "상위 N행"이 된다.
-- 정렬 없이 바로 WHERE ROWNUM <= 3을 걸면 "정렬 전 임의 3건"이 되는 함정이 있다.
SELECT * FROM (
    SELECT last_name || first_name AS full_name,
           signup_date,
           DATE '2025-06-01' - signup_date AS days_since_signup,
           NVL(phone, '미등록') AS phone_display
    FROM customers
    ORDER BY signup_date DESC
)
WHERE ROWNUM <= 3;

-- NULL 함정: Oracle은 빈 문자열 ''을 VARCHAR2 컬럼에 넣으면 NULL로 저장한다.
INSERT INTO customers VALUES ('강','서준', DATE '2024-09-09', '');
SELECT phone, phone IS NULL AS is_actually_null
FROM customers
WHERE last_name = '강';
-- 예상: phone은 화면에 빈 값으로 보이지만 IS NULL 조건이 TRUE(1)로 나온다.
