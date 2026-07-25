-- 09-NULL정렬과윈도우함수: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
-- =====================================================================
-- NULL-집중학습 공통 테스트 데이터 (Oracle)
-- null_lab_customer / null_lab_dept / null_lab_excluded_codes
--
-- Olist 원자료(olist_customers_dataset.csv)와 무관한, 이 학습 모듈 전용의
-- 작은 합성(synthetic) 데이터다. Olist 원자료에는 실제 결측이 없다
-- (Olist-고객데이터/00-데이터사전/profile.py로 확인됨) — 혼동 금지.
--
-- *** Oracle 고유 함정: nickname에 ''(빈 문자열)를 넣는 INSERT는 Oracle에서
-- 그 값을 NULL로 저장한다(Oracle은 ''와 NULL을 구분하지 않는다). 그래서
-- customer_id=3(설계 의도: 빈 문자열)은 Oracle에 적재되는 순간부터
-- nickname이 NULL이 되어, customer_id=2/8(원래부터 NULL)과 구분이 불가능
-- 해진다. 이는 버그가 아니라 이 모듈이 보여주려는 핵심 차이다 — SQL Server
-- 버전(sqlserver.sql)에서는 ''가 그대로 ''로 남아 NULL과 구분된다. ***
-- =====================================================================

DROP TABLE null_lab_customer;

CREATE TABLE null_lab_customer (
    customer_id      NUMBER        PRIMARY KEY,
    customer_name    VARCHAR2(20)  NOT NULL,
    nickname         VARCHAR2(20),
    age              NUMBER,
    membership_code  VARCHAR2(5),
    score             NUMBER,
    purchase_amt     NUMBER(10,2),
    order_qty        NUMBER,
    discount_qty     NUMBER,
    dept_code        VARCHAR2(5),
    join_date        DATE
);

INSERT INTO null_lab_customer VALUES (1, '김민준', '민준', 28,   'A001', 85,  120000, 10, 2,    'D01', DATE '2024-01-10');
INSERT INTO null_lab_customer VALUES (2, '이서연', NULL,  34,   'A002', 92,  98000,  5,  0,    'D02', DATE '2024-02-15');
INSERT INTO null_lab_customer VALUES (3, '박지훈', '',    41,   'A003', NULL,150000, 8,  4,    'D03', NULL);
INSERT INTO null_lab_customer VALUES (4, '최유진', ' ',   0,    'A004', 77,  0,      3,  1,    NULL,  DATE '2024-03-05');
INSERT INTO null_lab_customer VALUES (5, '정하은', '하은',NULL, '0',   60,  NULL,   6,  2,    'D01', DATE '2024-01-22');
INSERT INTO null_lab_customer VALUES (6, '강도현', '도현',29,   'A006', 0,   45000,  0,  3,    'D02', DATE '2024-04-11');
INSERT INTO null_lab_customer VALUES (7, '윤서준', '서준',33,   'A007', 88,  76000,  4,  NULL, 'D03', DATE '2024-05-02');
INSERT INTO null_lab_customer VALUES (8, '임수아', NULL,  45,   'A008', 95,  210000, 12, 5,    'D99', DATE '2024-06-19');
INSERT INTO null_lab_customer VALUES (9, '한지민', '지민',26,   'A009', NULL,89000,  7,  2,    'D01', DATE '2024-07-08');
INSERT INTO null_lab_customer VALUES (10,'오세훈', '세훈',38,   'A010', 70,  132000, 9,  3,    NULL,  DATE '2024-08-14');
INSERT INTO null_lab_customer VALUES (11,'배수지', '수지',31,   'A011', 82,  NULL,   5,  2,    'D02', NULL);
INSERT INTO null_lab_customer VALUES (12,'조현우', '현우',50,   'A012', 99,  300000, 15, 5,    'D03', DATE '2024-09-30');

COMMIT;

DROP TABLE null_lab_dept;

CREATE TABLE null_lab_dept (
    dept_code  VARCHAR2(5) PRIMARY KEY,
    dept_name  VARCHAR2(20)
);

INSERT INTO null_lab_dept VALUES ('D01', '총무팀');
INSERT INTO null_lab_dept VALUES ('D02', '영업팀');
INSERT INTO null_lab_dept VALUES ('D03', '개발팀');

COMMIT;
-- customer_id=8(dept_code='D99'), 4·10(dept_code=NULL)은 null_lab_dept에
-- 대응하는 부서가 없다 — JOIN 키 NULL/불일치 실습용(07 폴더).

DROP TABLE null_lab_excluded_codes;

CREATE TABLE null_lab_excluded_codes (
    dept_code VARCHAR2(5)
);

INSERT INTO null_lab_excluded_codes VALUES ('D02');
INSERT INTO null_lab_excluded_codes VALUES ('D03');
INSERT INTO null_lab_excluded_codes VALUES (NULL);

COMMIT;
-- NOT IN (SELECT dept_code FROM null_lab_excluded_codes)는 NULL이 섞여
-- 있어 예상과 다르게 0행이 된다 — 08 폴더 핵심 실습(이 폴더에서는 쓰지 않음).

-- =====================================================================
-- STEP 1. NULL 정렬 순서 — Oracle 기본값
--   Oracle은 ORDER BY ... ASC일 때 NULL을 기본적으로 "가장 큰 값"처럼
--   취급해 맨 뒤에 둔다(NULLS LAST가 기본). DESC일 때는 반대로 맨 앞에
--   둔다(NULLS FIRST가 기본). score가 NULL인 행은 customer_id 3, 9다.
--   customer_id를 2차 정렬 키로 추가해 동순위 행의 순서까지 결정적으로
--   만들었다.
-- =====================================================================
SELECT customer_id, score
FROM null_lab_customer
ORDER BY score ASC, customer_id;
-- 예상: 6,5,10,4,11,1,7,2,8,12 순으로 score 오름차순 → 마지막에 3,9(NULL)

SELECT customer_id, score
FROM null_lab_customer
ORDER BY score DESC, customer_id;
-- 예상: 3,9(NULL)가 맨 앞 → 이후 12,8,2,7,1,11,4,10,5,6 순으로 score 내림차순

-- NULLS FIRST/LAST로 Oracle 기본값을 명시적으로 뒤집을 수 있다(SQL Server엔
-- 이 절 자체가 없다 — STEP 1b, 05절 참고).
SELECT customer_id, score
FROM null_lab_customer
ORDER BY score ASC NULLS FIRST, customer_id;
-- 예상: 3,9(NULL)가 맨 앞 → 이후 score 오름차순(위 DESC 기본값과 NULL 위치는
-- 같지만 나머지 행의 정렬 방향은 오름차순이라는 점이 다름)

SELECT customer_id, score
FROM null_lab_customer
ORDER BY score DESC NULLS LAST, customer_id;
-- 예상: score 내림차순 먼저 → 3,9(NULL)가 맨 뒤

-- =====================================================================
-- STEP 2. ROW_NUMBER, RANK, DENSE_RANK와 NULL — purchase_amt 기준
--   purchase_amt가 NULL인 행은 customer_id 5, 11. Oracle 기본(ASC는
--   NULLS LAST)이므로 이 두 행은 정렬 순서상 맨 뒤에 위치하고, 서로는
--   "같다"고 취급되어 RANK/DENSE_RANK가 동일한 순위로 묶인다.
-- =====================================================================
SELECT customer_id, purchase_amt,
       ROW_NUMBER() OVER (ORDER BY purchase_amt ASC, customer_id) AS rn,
       RANK()       OVER (ORDER BY purchase_amt ASC) AS rnk,
       DENSE_RANK() OVER (ORDER BY purchase_amt ASC) AS drnk
FROM null_lab_customer
ORDER BY purchase_amt ASC NULLS LAST, customer_id;
-- 예상(값 오름차순 4,6,7,9,2,1,10,3,8,12 뒤에 NULL인 5,11):
--   rn 1~10은 위 10행에 순서대로 부여, NULL인 5,11은 rn 11,12(customer_id
--   순서로 동점 처리).
--   rnk: NULL이 아닌 10행은 서로 값이 모두 달라 rnk 1~10, NULL 두 행은
--        동순위로 묶여 둘 다 rnk=11.
--   drnk: 위와 동일 논리로 NULL이 아닌 10행 drnk 1~10, NULL 두 행 모두
--        drnk=11 (RANK와 값이 같다 — 앞선 10행이 전부 서로 다른 값이라
--        둘 사이에 차이가 안 생김).

-- =====================================================================
-- STEP 3. PARTITION BY dept_code — NULL도 하나의 파티션으로 묶인다
--   dept_code가 NULL인 customer_id 4, 10은 같은 파티션으로 묶여 그
--   안에서만 ROW_NUMBER가 1, 2로 매겨진다. GROUP BY가 NULL을 하나의
--   그룹으로 묶는 것(04 폴더)과 같은 원리다.
-- =====================================================================
SELECT customer_id, dept_code, score,
       ROW_NUMBER() OVER (PARTITION BY dept_code ORDER BY customer_id) AS rn_in_dept
FROM null_lab_customer
ORDER BY dept_code NULLS LAST, customer_id;
-- 예상 파티션: D01={1,5,9}, D02={2,6,11}, D03={3,7,12}, D99={8},
-- NULL={4,10} → NULL 파티션 안에서 4번(rn_in_dept=1), 10번(rn_in_dept=2)
