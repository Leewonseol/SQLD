-- JOIN·표준 JOIN 실습 데이터 준비 (Oracle)
-- 대상: 깨우침/JOIN·표준 JOIN 문제 풀이표.md
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- 데이터 원칙: 모든 customer_id/customer_unique_id/city/state 값은 저장소 루트의
-- olist_customers_dataset.csv(99,441행, 결측 0건)에서 실제로 뽑은 값이다
-- (분석기법/_data/build_db.py가 "실제 고객 표본 + 합성 특성" 방식으로 하는 것과
-- 같은 원칙). 다만 SALARY류 숫자(총구매액 성격)와 CONTACT/REVIEW 같은 부가
-- 속성은 이 실습을 위해 새로 붙인 값이며, Olist 실제 거래 금액이 아니다 —
-- customer_id 자체는 실제 문자열, 그 위에 얹은 숫자만 실습용 고정값이다.
-- customer_unique_id가 실제로 2번·3번 반복 등장하는 실제 재구매 고객을 그대로
-- 이용해 "중복값에 따른 결과 행 수 증가"(J09)를 값 조작 없이 재현한다.
--
-- 최초 실행 시 아래 DROP 구문들이 ORA-00942(테이블/뷰 없음)를 낼 수 있다.
-- 이는 정상이며 무시하고 계속 진행하면 된다(이 저장소의 다른 모듈과 동일 관례).

DROP TABLE sql_example_validation;
DROP TABLE sql_example_result;
DROP TABLE sql_example_expectation;

DROP TABLE state_region2;
DROP TABLE state_region;
DROP TABLE customers;
DROP TABLE spend_tier;
DROP TABLE review_tier;
DROP TABLE sample_states;
DROP TABLE sample_scores;
DROP TABLE customer_dim;
DROP TABLE customer_orders_sample;
DROP TABLE customer_master;
DROP TABLE customer_review;
DROP TABLE full_a;
DROP TABLE full_b;
DROP TABLE member;
DROP TABLE contact;
DROP TABLE state_branch;
DROP TABLE state_orders;

-- =====================================================================
-- 검증 테이블 3종 (공통 스키마는 ../../_common/validation_schema.sql 참고)
-- =====================================================================
CREATE TABLE sql_example_expectation (
    example_id             VARCHAR2(10) PRIMARY KEY,
    topic                   VARCHAR2(10),
    concept                 VARCHAR2(100),
    expected_row_count      NUMBER,
    expected_numeric_value  NUMBER,
    expected_text_value     VARCHAR2(100),
    dbms_name               VARCHAR2(20),
    note                    VARCHAR2(200)
);

CREATE TABLE sql_example_result (
    example_id           VARCHAR2(10) PRIMARY KEY,
    actual_row_count      NUMBER,
    actual_numeric_value  NUMBER,
    actual_text_value     VARCHAR2(100),
    executed_at           DATE
);

CREATE TABLE sql_example_validation (
    example_id           VARCHAR2(10) PRIMARY KEY,
    status                VARCHAR2(20),
    expected_value        VARCHAR2(200),
    actual_value           VARCHAR2(200),
    validation_message     VARCHAR2(300)
);

-- =====================================================================
-- 예제 데이터 (olist_customers_dataset.csv에서 뽑은 실제 값의 고정 INSERT)
-- =====================================================================

-- STATE_REGION : 브라질 주(state) 코드 -> 지역(region) 매핑(실제 지리 정보).
-- 'BA'는 아래 CUSTOMERS 테이블 어디에도 쓰이지 않는다 - Oracle (+) 예제(J18)에서
-- "짝이 없는 쪽도 보존"되는 대상 역할을 한다(옛 DEPT 40/OPERATIONS 역할).
CREATE TABLE state_region (
    state  VARCHAR2(2) PRIMARY KEY,
    region VARCHAR2(20)
);
INSERT INTO state_region VALUES ('SP', 'Sudeste');
INSERT INTO state_region VALUES ('RJ', 'Sudeste');
INSERT INTO state_region VALUES ('MG', 'Sudeste');
INSERT INTO state_region VALUES ('BA', 'Nordeste');

-- CUSTOMERS : olist_customers_dataset.csv 실제 8행(customer_id 오름차순 정렬 후
-- SP/RJ/MG 주에서 뽑음). total_spent는 실제 구매액이 아니라 이 실습을 위해
-- 붙인 실습용 숫자(옛 EMP.SALARY 값을 그대로 재사용해 카티션 곱·등가/비등가
-- 조인·필터 결과가 이전과 동일하게 나오도록 맞췄다).
CREATE TABLE customers (
    customer_id  VARCHAR2(32) PRIMARY KEY,
    city          VARCHAR2(40),
    state         VARCHAR2(2),
    total_spent   NUMBER
);
INSERT INTO customers VALUES ('00012a2ce6f8dcda20d059ce98491703', 'osasco', 'SP', 800);
INSERT INTO customers VALUES ('000379cdec625522490c315e70c7a9fb', 'sao paulo', 'SP', 1600);
INSERT INTO customers VALUES ('0004164d20a9e969af783496f3408652', 'valinhos', 'SP', 1250);
INSERT INTO customers VALUES ('00046a560d407e99b969756e0b10f282', 'rio de janeiro', 'RJ', 2975);
INSERT INTO customers VALUES ('00114026c1b7b52ab1773f317ef4880b', 'rio de janeiro', 'RJ', 1250);
INSERT INTO customers VALUES ('0012a5c13793cf51e253f096a7e740dd', 'rio de janeiro', 'RJ', 2850);
INSERT INTO customers VALUES ('000161a058600d5901f007fab4c27140', 'itapecerica', 'MG', 2450);
INSERT INTO customers VALUES ('0002414f95344307404f0ace7a26f1d5', 'mendonca', 'MG', 3000);

-- SPEND_TIER : total_spent 구간표(옛 SALGRADE 값 그대로) - 비등가 조인(J07)용.
CREATE TABLE spend_tier (
    tier  NUMBER PRIMARY KEY,
    losal NUMBER,
    hisal NUMBER
);
INSERT INTO spend_tier VALUES (1, 700, 1200);
INSERT INTO spend_tier VALUES (2, 1201, 1400);
INSERT INTO spend_tier VALUES (3, 1401, 2000);
INSERT INTO spend_tier VALUES (4, 2001, 3000);
INSERT INTO spend_tier VALUES (5, 3001, 9999);

-- STATE_REGION2 : STATE_REGION과 값은 같지만 PK 열 이름이 다르다 - ON이 열
-- 이름 달라도 동작함(USING/NATURAL은 불가)을 보여주는 J14 전용 테이블.
CREATE TABLE state_region2 (
    state_code  VARCHAR2(2) PRIMARY KEY,
    region_name VARCHAR2(20)
);
INSERT INTO state_region2 VALUES ('SP', 'Sudeste');
INSERT INTO state_region2 VALUES ('RJ', 'Sudeste');
INSERT INTO state_region2 VALUES ('MG', 'Sudeste');
INSERT INTO state_region2 VALUES ('BA', 'Nordeste');

-- REVIEW_TIER : STATE_REGION(4행) x REVIEW_TIER(3행) = 12행 카티션 곱(J04).
CREATE TABLE review_tier (
    tier_id   VARCHAR2(5) PRIMARY KEY,
    tier_name VARCHAR2(10)
);
INSERT INTO review_tier VALUES ('T1', 'LOW');
INSERT INTO review_tier VALUES ('T2', 'MID');
INSERT INTO review_tier VALUES ('T3', 'HIGH');

-- SAMPLE_STATES / SAMPLE_SCORES : 첨부 표준 JOIN 문제 9번 유형 CROSS JOIN
-- (2행x3행=6행, J05). 실제 주 코드 2개 x 리뷰 점수 3개.
CREATE TABLE sample_states (
    state VARCHAR2(2) PRIMARY KEY
);
INSERT INTO sample_states VALUES ('SP');
INSERT INTO sample_states VALUES ('RJ');

CREATE TABLE sample_scores (
    score NUMBER PRIMARY KEY
);
INSERT INTO sample_scores VALUES (1);
INSERT INTO sample_scores VALUES (3);
INSERT INTO sample_scores VALUES (5);

-- CUSTOMER_DIM / CUSTOMER_ORDERS_SAMPLE : 첨부 JOIN 문제 5번 유형, 중복값에
-- 따른 결과 행 수 증가(J09). U2는 실제로 3번 재구매한 고객
-- (customer_unique_id=02e9109b7e0a985108b43e573b6afb23)의 실제 customer_id
-- 중 2개만, U3는 실제로 2번 재구매한 고객
-- (customer_unique_id=00172711b30d52eea8b313a7f2cced02)의 실제 customer_id
-- 중 1개만 담아 "1명당 매칭 2건/1건"을 실제 재구매 데이터로 재현한다.
-- U1은 재구매 이력이 없는(1회성) 실제 고객이라 매칭 0건이다.
CREATE TABLE customer_dim (
    customer_unique_id VARCHAR2(32) PRIMARY KEY
);
INSERT INTO customer_dim VALUES ('616309b2eeb7bd9c05b0fdfbab28e6c6'); -- U1, 매칭 0건
INSERT INTO customer_dim VALUES ('02e9109b7e0a985108b43e573b6afb23'); -- U2, 실제 3회 재구매 고객 중 2건 사용
INSERT INTO customer_dim VALUES ('00172711b30d52eea8b313a7f2cced02'); -- U3, 실제 2회 재구매 고객 중 1건 사용

CREATE TABLE customer_orders_sample (
    customer_id        VARCHAR2(32) PRIMARY KEY,
    customer_unique_id  VARCHAR2(32)
);
INSERT INTO customer_orders_sample VALUES ('14676dd9c40ad83f2a980ac36077cdb9', '02e9109b7e0a985108b43e573b6afb23');
INSERT INTO customer_orders_sample VALUES ('1ae196062dab95e434e781a5319f0ab9', '02e9109b7e0a985108b43e573b6afb23');
INSERT INTO customer_orders_sample VALUES ('1afe8a9c67eec3516c09a8bdcc539090', '00172711b30d52eea8b313a7f2cced02');

-- CUSTOMER_MASTER / CUSTOMER_REVIEW : INNER/LEFT/RIGHT/FULL JOIN, USING,
-- NATURAL JOIN 예제(J10~J13,J13B,J15,J16). 실제 customer_id 3개를 MASTER에,
-- 그 중 2개 + MASTER에 없는 실제 customer_id 1개를 REVIEW에 담아
-- "공통 2건, 왼쪽만 1건, 오른쪽만 1건" 구조를 실제 값으로 재현한다.
CREATE TABLE customer_master (
    customer_id VARCHAR2(32) PRIMARY KEY,
    city         VARCHAR2(40)
);
INSERT INTO customer_master VALUES ('001028b78fd413e19704b3867c369d3a', 'sao paulo'); -- Ca
INSERT INTO customer_master VALUES ('001051abfcfdbed9f87b4266213a5df1', 'sao paulo'); -- Cb
INSERT INTO customer_master VALUES ('0013280441d86a4f7a8006efdaf1b0fe', 'sao paulo'); -- Cc, 리뷰 없음(LEFT에서만 남음)

CREATE TABLE customer_review (
    rn           NUMBER PRIMARY KEY,
    customer_id  VARCHAR2(32),
    subject       VARCHAR2(20),
    scoreval      NUMBER
);
INSERT INTO customer_review VALUES (1, '001028b78fd413e19704b3867c369d3a', 'DELIVERY', 90); -- Ca
INSERT INTO customer_review VALUES (2, '001051abfcfdbed9f87b4266213a5df1', 'QUALITY', 85);  -- Cb
INSERT INTO customer_review VALUES (3, '0013cd8e350a7cc76873441e431dd5ee', 'DELIVERY', 77); -- Cd, MASTER에 없는 실제 고객(RIGHT/FULL에서만 남음)

-- FULL_A / FULL_B : 첨부 표준 JOIN 문제 8번 그대로(J13, FULL OUTER JOIN 3행).
-- 실제 주 코드로 재현: SP는 A에만, RJ는 양쪽에, MG는 B에만.
CREATE TABLE full_a (
    state VARCHAR2(2) PRIMARY KEY
);
INSERT INTO full_a VALUES ('SP');
INSERT INTO full_a VALUES ('RJ');

CREATE TABLE full_b (
    state VARCHAR2(2) PRIMARY KEY
);
INSERT INTO full_b VALUES ('RJ');
INSERT INTO full_b VALUES ('MG');

-- MEMBER / CONTACT : OUTER JOIN 뒤 WHERE 제거, LEFT JOIN+IS NULL,
-- COUNT(*) vs COUNT(우측열) 예제(J19~J21). 실제 customer_id 3명을 회원으로,
-- 그 중 1명은 연락처 2건(휴대폰+이메일), 1명은 1건(이메일), 1명은 0건.
CREATE TABLE member (
    customer_id  VARCHAR2(32) PRIMARY KEY,
    city          VARCHAR2(40)
);
INSERT INTO member VALUES ('000fd45d6fedae68fc6676036610f879', 'piracaia');   -- Ma
INSERT INTO member VALUES ('001028b78fd413e19704b3867c369d3a', 'sao paulo'); -- Mb
INSERT INTO member VALUES ('001051abfcfdbed9f87b4266213a5df1', 'sao paulo'); -- Mc, 연락처 없음

CREATE TABLE contact (
    rn            NUMBER PRIMARY KEY,
    customer_id   VARCHAR2(32),
    contact_type  VARCHAR2(10),
    contact_no    VARCHAR2(20)
);
INSERT INTO contact VALUES (1, '000fd45d6fedae68fc6676036610f879', '휴대폰', '010-1111-1111');
INSERT INTO contact VALUES (2, '000fd45d6fedae68fc6676036610f879', '이메일', 'ma@test.com');
INSERT INTO contact VALUES (3, '001028b78fd413e19704b3867c369d3a', '이메일', 'mb@test.com');

-- STATE_BRANCH / STATE_ORDERS : "첨부 문제 형태와 유사한 행 수 계산" 연습(J23).
-- CUSTOMER_DIM과 같은 0/2/1 구조를 실제 주 코드로 한 번 더 연습한다.
CREATE TABLE state_branch (
    state VARCHAR2(2) PRIMARY KEY
);
INSERT INTO state_branch VALUES ('SP');
INSERT INTO state_branch VALUES ('RJ');
INSERT INTO state_branch VALUES ('MG');

CREATE TABLE state_orders (
    rn    NUMBER PRIMARY KEY,
    state VARCHAR2(2)
);
INSERT INTO state_orders VALUES (1, 'RJ');
INSERT INTO state_orders VALUES (2, 'RJ');
INSERT INTO state_orders VALUES (3, 'MG');

COMMIT;

-- =====================================================================
-- 기대 결과표 적재 (../../_common/expected_results.csv topic=JOIN dbms=ORACLE 과 동일)
-- 실제 값이 바뀌어도 각 테이블의 행 수·매칭 구조는 이전과 동일하게 맞췄으므로
-- expected_row_count / expected_numeric_value는 전부 그대로다.
-- =====================================================================
INSERT INTO sql_example_expectation VALUES ('J01','JOIN','테이블 수',1,8,NULL,'ORACLE','CUSTOMERS 8행 단일 테이블 조회이므로 JOIN 아님');
INSERT INTO sql_example_expectation VALUES ('J02','JOIN','연결 조건 존재 여부(카티션 곱)',1,32,NULL,'ORACLE','CUSTOMERS(8)xSTATE_REGION(4)=32');
INSERT INTO sql_example_expectation VALUES ('J03','JOIN','연결 조건 존재 여부(조건부 JOIN)',1,8,NULL,'ORACLE','전 고객 유효 STATE 보유로 8행');
INSERT INTO sql_example_expectation VALUES ('J04','JOIN','카티션 곱 계산(행수/열수)',1,12,NULL,'ORACLE','STATE_REGION(4)xREVIEW_TIER(3)=12행');
INSERT INTO sql_example_expectation VALUES ('J05','JOIN','CROSS JOIN(2행x3행=6행)',1,6,NULL,'ORACLE','SAMPLE_STATES(2)xSAMPLE_SCORES(3)=6행');
INSERT INTO sql_example_expectation VALUES ('J06','JOIN','등가 조인',1,8,NULL,'ORACLE','CUSTOMERS.STATE=STATE_REGION.STATE 비교');
INSERT INTO sql_example_expectation VALUES ('J07','JOIN','비등가 조인',1,8,NULL,'ORACLE','TOTAL_SPENT BETWEEN LOSAL AND HISAL 8명 전원 등급 매칭');
INSERT INTO sql_example_expectation VALUES ('J08','JOIN','조인 조건과 일반 필터 조건 구분',1,4,NULL,'ORACLE','STATE 조인 + TOTAL_SPENT>2000 필터');
INSERT INTO sql_example_expectation VALUES ('J09','JOIN','중복값에 따른 결과 행 수 증가',1,3,NULL,'ORACLE','실제 재구매 고객: U1=0 U2=2 U3=1 합계3');
INSERT INTO sql_example_expectation VALUES ('J10','JOIN','INNER JOIN',1,2,NULL,'ORACLE','공통 고객 Ca,Cb만 유지');
INSERT INTO sql_example_expectation VALUES ('J11','JOIN','LEFT OUTER JOIN',1,3,NULL,'ORACLE','MASTER 3명 전원 보존');
INSERT INTO sql_example_expectation VALUES ('J12','JOIN','RIGHT OUTER JOIN',1,3,NULL,'ORACLE','REVIEW 3건 보존');
INSERT INTO sql_example_expectation VALUES ('J13','JOIN','FULL OUTER JOIN',1,3,NULL,'ORACLE','FULL_A/FULL_B SP,RJ,MG 총3행');
INSERT INTO sql_example_expectation VALUES ('J13B','JOIN','FULL OUTER JOIN(고객/리뷰)',1,4,NULL,'ORACLE','Ca,Cb,Cc,Cd 총4행');
INSERT INTO sql_example_expectation VALUES ('J14','JOIN','ON(열 이름이 달라도 가능)',1,8,NULL,'ORACLE','STATE_REGION2.STATE_CODE로 ON 연결');
INSERT INTO sql_example_expectation VALUES ('J15','JOIN','USING',1,2,NULL,'ORACLE','USING(customer_id) 직접 사용');
INSERT INTO sql_example_expectation VALUES ('J16','JOIN','NATURAL JOIN',1,2,NULL,'ORACLE','공통열 customer_id 자동조건');
INSERT INTO sql_example_expectation VALUES ('J17','JOIN','구문형 JOIN',1,4,NULL,'ORACLE','FROM A,B WHERE 조인+필터');
INSERT INTO sql_example_expectation VALUES ('J18','JOIN','Oracle (+)',1,9,NULL,'ORACLE','STATE_REGION a CUSTOMERS b(+): BA 보존 포함 9행');
INSERT INTO sql_example_expectation VALUES ('J19','JOIN','OUTER JOIN 이후 WHERE로 미일치 행 제거',1,1,NULL,'ORACLE','WHERE CONTACT_TYPE=휴대폰 -> Ma만');
INSERT INTO sql_example_expectation VALUES ('J20','JOIN','LEFT JOIN + IS NULL',1,1,NULL,'ORACLE','연락처 없는 회원 Mc');
INSERT INTO sql_example_expectation VALUES ('J21','JOIN','COUNT(*) vs COUNT(우측열) - COUNT(*)',4,NULL,NULL,'ORACLE','LEFT JOIN 원본 COUNT(*)=4');
INSERT INTO sql_example_expectation VALUES ('J21B','JOIN','COUNT(*) vs COUNT(우측열) - COUNT(우측열)',1,3,NULL,'ORACLE','COUNT(CONTACT.customer_id)=3');
INSERT INTO sql_example_expectation VALUES ('J22','JOIN','테이블 별칭',1,8,NULL,'ORACLE','별칭 a,b 사용');
INSERT INTO sql_example_expectation VALUES ('J23','JOIN','첨부 문제 형태와 유사한 행 수 계산',1,3,NULL,'ORACLE','STATE_BRANCH/STATE_ORDERS SP=0 RJ=2 MG=1 합계3행');

COMMIT;
