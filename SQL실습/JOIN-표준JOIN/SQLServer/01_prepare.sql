-- JOIN·표준 JOIN 실습 데이터 준비 (SQL Server)
-- 대상: 깨우침/JOIN·표준 JOIN 문제 풀이표.md
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- Oracle/01_prepare.sql과 같은 example_id·같은 기대값을 쓰되, 문법만 SQL
-- Server 방언으로 옮겼다. customer_id/customer_unique_id/city/state 값은
-- 모두 저장소 루트 olist_customers_dataset.csv에서 실제로 뽑은 값이다(자세한
-- 설명은 Oracle/01_prepare.sql 상단 주석과 README 참고).

IF OBJECT_ID('sql_example_validation', 'U') IS NOT NULL DROP TABLE sql_example_validation;
IF OBJECT_ID('sql_example_result', 'U') IS NOT NULL DROP TABLE sql_example_result;
IF OBJECT_ID('sql_example_expectation', 'U') IS NOT NULL DROP TABLE sql_example_expectation;

IF OBJECT_ID('state_region2', 'U') IS NOT NULL DROP TABLE state_region2;
IF OBJECT_ID('state_region', 'U') IS NOT NULL DROP TABLE state_region;
IF OBJECT_ID('customers', 'U') IS NOT NULL DROP TABLE customers;
IF OBJECT_ID('spend_tier', 'U') IS NOT NULL DROP TABLE spend_tier;
IF OBJECT_ID('review_tier', 'U') IS NOT NULL DROP TABLE review_tier;
IF OBJECT_ID('sample_states', 'U') IS NOT NULL DROP TABLE sample_states;
IF OBJECT_ID('sample_scores', 'U') IS NOT NULL DROP TABLE sample_scores;
IF OBJECT_ID('customer_dim', 'U') IS NOT NULL DROP TABLE customer_dim;
IF OBJECT_ID('customer_orders_sample', 'U') IS NOT NULL DROP TABLE customer_orders_sample;
IF OBJECT_ID('customer_master', 'U') IS NOT NULL DROP TABLE customer_master;
IF OBJECT_ID('customer_review', 'U') IS NOT NULL DROP TABLE customer_review;
IF OBJECT_ID('full_a', 'U') IS NOT NULL DROP TABLE full_a;
IF OBJECT_ID('full_b', 'U') IS NOT NULL DROP TABLE full_b;
IF OBJECT_ID('member', 'U') IS NOT NULL DROP TABLE member;
IF OBJECT_ID('contact', 'U') IS NOT NULL DROP TABLE contact;
IF OBJECT_ID('state_branch', 'U') IS NOT NULL DROP TABLE state_branch;
IF OBJECT_ID('state_orders', 'U') IS NOT NULL DROP TABLE state_orders;

-- =====================================================================
-- 검증 테이블 3종
-- =====================================================================
CREATE TABLE sql_example_expectation (
    example_id             VARCHAR(10) PRIMARY KEY,
    topic                   VARCHAR(10),
    concept                 VARCHAR(100),
    expected_row_count      INT,
    expected_numeric_value  DECIMAL(18,4),
    expected_text_value     VARCHAR(100),
    dbms_name               VARCHAR(20),
    note                    VARCHAR(200)
);

CREATE TABLE sql_example_result (
    example_id           VARCHAR(10) PRIMARY KEY,
    actual_row_count      INT,
    actual_numeric_value  DECIMAL(18,4),
    actual_text_value     VARCHAR(100),
    executed_at           DATETIME
);

CREATE TABLE sql_example_validation (
    example_id           VARCHAR(10) PRIMARY KEY,
    status                VARCHAR(20),
    expected_value        VARCHAR(200),
    actual_value           VARCHAR(200),
    validation_message     VARCHAR(300)
);

-- =====================================================================
-- 예제 데이터 (Oracle/01_prepare.sql과 값 동일, 자료형만 SQL Server 방언)
-- =====================================================================

CREATE TABLE state_region (
    state  VARCHAR(2) PRIMARY KEY,
    region VARCHAR(20)
);
INSERT INTO state_region VALUES ('SP', 'Sudeste');
INSERT INTO state_region VALUES ('RJ', 'Sudeste');
INSERT INTO state_region VALUES ('MG', 'Sudeste');
INSERT INTO state_region VALUES ('BA', 'Nordeste'); -- CUSTOMERS 어디에도 없음(J18 LEFT JOIN 보존 대상)

CREATE TABLE customers (
    customer_id  VARCHAR(32) PRIMARY KEY,
    city          VARCHAR(40),
    state         VARCHAR(2),
    total_spent   INT
);
INSERT INTO customers VALUES ('00012a2ce6f8dcda20d059ce98491703', 'osasco', 'SP', 800);
INSERT INTO customers VALUES ('000379cdec625522490c315e70c7a9fb', 'sao paulo', 'SP', 1600);
INSERT INTO customers VALUES ('0004164d20a9e969af783496f3408652', 'valinhos', 'SP', 1250);
INSERT INTO customers VALUES ('00046a560d407e99b969756e0b10f282', 'rio de janeiro', 'RJ', 2975);
INSERT INTO customers VALUES ('00114026c1b7b52ab1773f317ef4880b', 'rio de janeiro', 'RJ', 1250);
INSERT INTO customers VALUES ('0012a5c13793cf51e253f096a7e740dd', 'rio de janeiro', 'RJ', 2850);
INSERT INTO customers VALUES ('000161a058600d5901f007fab4c27140', 'itapecerica', 'MG', 2450);
INSERT INTO customers VALUES ('0002414f95344307404f0ace7a26f1d5', 'mendonca', 'MG', 3000);

CREATE TABLE spend_tier (
    tier  INT PRIMARY KEY,
    losal INT,
    hisal INT
);
INSERT INTO spend_tier VALUES (1, 700, 1200);
INSERT INTO spend_tier VALUES (2, 1201, 1400);
INSERT INTO spend_tier VALUES (3, 1401, 2000);
INSERT INTO spend_tier VALUES (4, 2001, 3000);
INSERT INTO spend_tier VALUES (5, 3001, 9999);

-- STATE_REGION2 : ON이 열 이름 달라도 동작함을 보여주는 J14 전용 테이블
CREATE TABLE state_region2 (
    state_code  VARCHAR(2) PRIMARY KEY,
    region_name VARCHAR(20)
);
INSERT INTO state_region2 VALUES ('SP', 'Sudeste');
INSERT INTO state_region2 VALUES ('RJ', 'Sudeste');
INSERT INTO state_region2 VALUES ('MG', 'Sudeste');
INSERT INTO state_region2 VALUES ('BA', 'Nordeste');

CREATE TABLE review_tier (
    tier_id   VARCHAR(5) PRIMARY KEY,
    tier_name VARCHAR(10)
);
INSERT INTO review_tier VALUES ('T1', 'LOW');
INSERT INTO review_tier VALUES ('T2', 'MID');
INSERT INTO review_tier VALUES ('T3', 'HIGH');

CREATE TABLE sample_states (
    state VARCHAR(2) PRIMARY KEY
);
INSERT INTO sample_states VALUES ('SP');
INSERT INTO sample_states VALUES ('RJ');

CREATE TABLE sample_scores (
    score INT PRIMARY KEY
);
INSERT INTO sample_scores VALUES (1);
INSERT INTO sample_scores VALUES (3);
INSERT INTO sample_scores VALUES (5);

-- CUSTOMER_DIM / CUSTOMER_ORDERS_SAMPLE : 실제 재구매 고객(2회/3회)의 실제
-- customer_id 일부만 사용해 중복값 조인의 결과 행 수 증가(J09)를 재현한다.
CREATE TABLE customer_dim (
    customer_unique_id VARCHAR(32) PRIMARY KEY
);
INSERT INTO customer_dim VALUES ('616309b2eeb7bd9c05b0fdfbab28e6c6'); -- U1, 매칭 0건
INSERT INTO customer_dim VALUES ('02e9109b7e0a985108b43e573b6afb23'); -- U2, 실제 3회 재구매 고객 중 2건 사용
INSERT INTO customer_dim VALUES ('00172711b30d52eea8b313a7f2cced02'); -- U3, 실제 2회 재구매 고객 중 1건 사용

CREATE TABLE customer_orders_sample (
    customer_id        VARCHAR(32) PRIMARY KEY,
    customer_unique_id  VARCHAR(32)
);
INSERT INTO customer_orders_sample VALUES ('14676dd9c40ad83f2a980ac36077cdb9', '02e9109b7e0a985108b43e573b6afb23');
INSERT INTO customer_orders_sample VALUES ('1ae196062dab95e434e781a5319f0ab9', '02e9109b7e0a985108b43e573b6afb23');
INSERT INTO customer_orders_sample VALUES ('1afe8a9c67eec3516c09a8bdcc539090', '00172711b30d52eea8b313a7f2cced02');

-- CUSTOMER_MASTER / CUSTOMER_REVIEW : INNER/LEFT/RIGHT/FULL JOIN 예제(J10~J13,J13B)
-- USING/NATURAL JOIN은 SQL Server가 지원하지 않으므로(J15,J16) ON으로만 조인한다.
CREATE TABLE customer_master (
    customer_id VARCHAR(32) PRIMARY KEY,
    city         VARCHAR(40)
);
INSERT INTO customer_master VALUES ('001028b78fd413e19704b3867c369d3a', 'sao paulo'); -- Ca
INSERT INTO customer_master VALUES ('001051abfcfdbed9f87b4266213a5df1', 'sao paulo'); -- Cb
INSERT INTO customer_master VALUES ('0013280441d86a4f7a8006efdaf1b0fe', 'sao paulo'); -- Cc, 리뷰 없음

CREATE TABLE customer_review (
    rn           INT PRIMARY KEY,
    customer_id  VARCHAR(32),
    subject       VARCHAR(20),
    scoreval      INT
);
INSERT INTO customer_review VALUES (1, '001028b78fd413e19704b3867c369d3a', 'DELIVERY', 90); -- Ca
INSERT INTO customer_review VALUES (2, '001051abfcfdbed9f87b4266213a5df1', 'QUALITY', 85);  -- Cb
INSERT INTO customer_review VALUES (3, '0013cd8e350a7cc76873441e431dd5ee', 'DELIVERY', 77); -- Cd, MASTER에 없는 실제 고객

-- FULL_A / FULL_B : 첨부 표준 JOIN 문제 8번 그대로(J13, FULL OUTER JOIN 3행)
CREATE TABLE full_a (
    state VARCHAR(2) PRIMARY KEY
);
INSERT INTO full_a VALUES ('SP');
INSERT INTO full_a VALUES ('RJ');

CREATE TABLE full_b (
    state VARCHAR(2) PRIMARY KEY
);
INSERT INTO full_b VALUES ('RJ');
INSERT INTO full_b VALUES ('MG');

-- MEMBER / CONTACT : OUTER JOIN 뒤 WHERE 제거, LEFT JOIN+IS NULL,
-- COUNT(*) vs COUNT(우측열) 예제(J19~J21). Oracle (+)는 J18에서 LEFT JOIN으로 대체.
CREATE TABLE member (
    customer_id  VARCHAR(32) PRIMARY KEY,
    city          VARCHAR(40)
);
INSERT INTO member VALUES ('000fd45d6fedae68fc6676036610f879', 'piracaia');
INSERT INTO member VALUES ('001028b78fd413e19704b3867c369d3a', 'sao paulo');
INSERT INTO member VALUES ('001051abfcfdbed9f87b4266213a5df1', 'sao paulo'); -- 연락처 없음

CREATE TABLE contact (
    rn            INT PRIMARY KEY,
    customer_id   VARCHAR(32),
    contact_type  VARCHAR(10),
    contact_no    VARCHAR(20)
);
INSERT INTO contact VALUES (1, '000fd45d6fedae68fc6676036610f879', N'휴대폰', '010-1111-1111');
INSERT INTO contact VALUES (2, '000fd45d6fedae68fc6676036610f879', N'이메일', 'ma@test.com');
INSERT INTO contact VALUES (3, '001028b78fd413e19704b3867c369d3a', N'이메일', 'mb@test.com');

-- STATE_BRANCH / STATE_ORDERS : "첨부 문제 형태와 유사한 행 수 계산" 연습(J23)
CREATE TABLE state_branch (
    state VARCHAR(2) PRIMARY KEY
);
INSERT INTO state_branch VALUES ('SP');
INSERT INTO state_branch VALUES ('RJ');
INSERT INTO state_branch VALUES ('MG');

CREATE TABLE state_orders (
    rn    INT PRIMARY KEY,
    state VARCHAR(2)
);
INSERT INTO state_orders VALUES (1, 'RJ');
INSERT INTO state_orders VALUES (2, 'RJ');
INSERT INTO state_orders VALUES (3, 'MG');

-- =====================================================================
-- 기대 결과표 적재 (../../_common/expected_results.csv topic=JOIN dbms=SQLSERVER 과 동일)
-- =====================================================================
INSERT INTO sql_example_expectation VALUES ('J01','JOIN','테이블 수',1,8,NULL,'SQLSERVER','CUSTOMERS 8행 단일 테이블 조회이므로 JOIN 아님');
INSERT INTO sql_example_expectation VALUES ('J02','JOIN','연결 조건 존재 여부(카티션 곱)',1,32,NULL,'SQLSERVER','CUSTOMERS(8)xSTATE_REGION(4)=32');
INSERT INTO sql_example_expectation VALUES ('J03','JOIN','연결 조건 존재 여부(조건부 JOIN)',1,8,NULL,'SQLSERVER','전 고객 유효 STATE 보유로 8행');
INSERT INTO sql_example_expectation VALUES ('J04','JOIN','카티션 곱 계산(행수/열수)',1,12,NULL,'SQLSERVER','STATE_REGION(4)xREVIEW_TIER(3)=12행');
INSERT INTO sql_example_expectation VALUES ('J05','JOIN','CROSS JOIN(2행x3행=6행)',1,6,NULL,'SQLSERVER','SAMPLE_STATES(2)xSAMPLE_SCORES(3)=6행');
INSERT INTO sql_example_expectation VALUES ('J06','JOIN','등가 조인',1,8,NULL,'SQLSERVER','CUSTOMERS.STATE=STATE_REGION.STATE 비교');
INSERT INTO sql_example_expectation VALUES ('J07','JOIN','비등가 조인',1,8,NULL,'SQLSERVER','TOTAL_SPENT BETWEEN LOSAL AND HISAL');
INSERT INTO sql_example_expectation VALUES ('J08','JOIN','조인 조건과 일반 필터 조건 구분',1,4,NULL,'SQLSERVER','TOTAL_SPENT>2000 필터 추가');
INSERT INTO sql_example_expectation VALUES ('J09','JOIN','중복값에 따른 결과 행 수 증가',1,3,NULL,'SQLSERVER','실제 재구매 고객: U1=0 U2=2 U3=1 합계3');
INSERT INTO sql_example_expectation VALUES ('J10','JOIN','INNER JOIN',1,2,NULL,'SQLSERVER','공통 고객 Ca,Cb만 유지');
INSERT INTO sql_example_expectation VALUES ('J11','JOIN','LEFT OUTER JOIN',1,3,NULL,'SQLSERVER','MASTER 3명 전원 보존');
INSERT INTO sql_example_expectation VALUES ('J12','JOIN','RIGHT OUTER JOIN',1,3,NULL,'SQLSERVER','REVIEW 3건 보존');
INSERT INTO sql_example_expectation VALUES ('J13','JOIN','FULL OUTER JOIN',1,3,NULL,'SQLSERVER','FULL_A/FULL_B SP,RJ,MG 총3행');
INSERT INTO sql_example_expectation VALUES ('J13B','JOIN','FULL OUTER JOIN(고객/리뷰)',1,4,NULL,'SQLSERVER','Ca,Cb,Cc,Cd 총4행');
INSERT INTO sql_example_expectation VALUES ('J14','JOIN','ON(열 이름이 달라도 가능)',1,8,NULL,'SQLSERVER','STATE_REGION2.STATE_CODE로 ON 연결');
INSERT INTO sql_example_expectation VALUES ('J15','JOIN','USING',1,2,NULL,'SQLSERVER','USING 미지원, ON customer_id로 대체');
INSERT INTO sql_example_expectation VALUES ('J16','JOIN','NATURAL JOIN',1,2,NULL,'SQLSERVER','NATURAL JOIN 미지원, ON customer_id로 대체');
INSERT INTO sql_example_expectation VALUES ('J17','JOIN','구문형 JOIN',1,4,NULL,'SQLSERVER','FROM A,B WHERE 조인+필터');
INSERT INTO sql_example_expectation VALUES ('J18','JOIN','Oracle (+) 동등 표현',1,9,NULL,'SQLSERVER','(+) 미지원, STATE_REGION LEFT JOIN CUSTOMERS로 대체 9행');
INSERT INTO sql_example_expectation VALUES ('J19','JOIN','OUTER JOIN 이후 WHERE로 미일치 행 제거',1,1,NULL,'SQLSERVER','WHERE CONTACT_TYPE=휴대폰 -> Ma만');
INSERT INTO sql_example_expectation VALUES ('J20','JOIN','LEFT JOIN + IS NULL',1,1,NULL,'SQLSERVER','연락처 없는 회원 Mc');
INSERT INTO sql_example_expectation VALUES ('J21','JOIN','COUNT(*) vs COUNT(우측열) - COUNT(*)',4,NULL,NULL,'SQLSERVER','LEFT JOIN 원본 COUNT(*)=4');
INSERT INTO sql_example_expectation VALUES ('J21B','JOIN','COUNT(*) vs COUNT(우측열) - COUNT(우측열)',1,3,NULL,'SQLSERVER','COUNT(CONTACT.customer_id)=3');
INSERT INTO sql_example_expectation VALUES ('J22','JOIN','테이블 별칭',1,8,NULL,'SQLSERVER','별칭 a,b 사용');
INSERT INTO sql_example_expectation VALUES ('J23','JOIN','첨부 문제 형태와 유사한 행 수 계산',1,3,NULL,'SQLSERVER','STATE_BRANCH/STATE_ORDERS SP=0 RJ=2 MG=1 합계3행');
