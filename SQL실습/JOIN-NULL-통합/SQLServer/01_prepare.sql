-- JOIN×NULL 통합 실습 데이터 준비 (SQL Server)
-- 대상: 깨우침/JOIN·표준 JOIN 문제 풀이표.md + 깨우침/NULL 정리.md 의 교차 개념
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- Oracle/01_prepare.sql과 같은 example_id·같은 기대값을 쓰되, 문법만 SQL
-- Server 방언으로 옮겼다. customer_id 값은 모두 저장소 루트
-- olist_customers_dataset.csv에서 실제로 뽑은 값이다(자세한 설명은
-- Oracle/01_prepare.sql 상단 주석과 README 참고).

IF OBJECT_ID('sql_example_validation', 'U') IS NOT NULL DROP TABLE sql_example_validation;
IF OBJECT_ID('sql_example_result', 'U') IS NOT NULL DROP TABLE sql_example_result;
IF OBJECT_ID('sql_example_expectation', 'U') IS NOT NULL DROP TABLE sql_example_expectation;

IF OBJECT_ID('customers', 'U') IS NOT NULL DROP TABLE customers;
IF OBJECT_ID('region_lookup', 'U') IS NOT NULL DROP TABLE region_lookup;
IF OBJECT_ID('customer_orders', 'U') IS NOT NULL DROP TABLE customer_orders;
IF OBJECT_ID('customer_loyalty', 'U') IS NOT NULL DROP TABLE customer_loyalty;
IF OBJECT_ID('customer_spend', 'U') IS NOT NULL DROP TABLE customer_spend;
IF OBJECT_ID('spend_band', 'U') IS NOT NULL DROP TABLE spend_band;

-- =====================================================================
-- 검증 테이블 3종
-- =====================================================================
CREATE TABLE sql_example_expectation (
    example_id             VARCHAR(10) PRIMARY KEY,
    topic                   VARCHAR(15),
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
-- 예제 데이터 (Oracle/01_prepare.sql과 값 완전 동일)
-- =====================================================================

CREATE TABLE customers (
    customer_id   VARCHAR(32) PRIMARY KEY,
    sales_region   VARCHAR(10)
);
INSERT INTO customers VALUES ('00331de1659c7f4fb660c8810e6de3f5', 'SUL');
INSERT INTO customers VALUES ('003e45472805afa1ee701d83284fa22b', 'SUL');
INSERT INTO customers VALUES ('0054556ea954a76ad6f9c4ba79d34a98', 'SUDESTE');
INSERT INTO customers VALUES ('005b65c9a6485aa1b7ac382dd87b018f', 'SUDESTE');
INSERT INTO customers VALUES ('006496598c918064dc19eef95e5e47f8', NULL); -- 권역 미배정

CREATE TABLE region_lookup (
    sales_region  VARCHAR(10) PRIMARY KEY,
    manager_name   VARCHAR(20)
);
INSERT INTO region_lookup VALUES ('SUL', 'Manager A');
INSERT INTO region_lookup VALUES ('SUDESTE', 'Manager B');
INSERT INTO region_lookup VALUES ('NORDESTE', 'Manager C');

-- 고아 주문(O5, customer_id NULL) 포함 - NOT IN 함정(JN06) 재현용
CREATE TABLE customer_orders (
    order_id     VARCHAR(5) PRIMARY KEY,
    customer_id  VARCHAR(32),
    amount        INT
);
INSERT INTO customer_orders VALUES ('O1', '00331de1659c7f4fb660c8810e6de3f5', 100);
INSERT INTO customer_orders VALUES ('O2', '00331de1659c7f4fb660c8810e6de3f5', NULL);
INSERT INTO customer_orders VALUES ('O3', '003e45472805afa1ee701d83284fa22b', 200);
INSERT INTO customer_orders VALUES ('O4', '005b65c9a6485aa1b7ac382dd87b018f', 150);
INSERT INTO customer_orders VALUES ('O5', NULL, 999);

CREATE TABLE customer_loyalty (
    customer_id  VARCHAR(32) PRIMARY KEY,
    points        INT
);
INSERT INTO customer_loyalty VALUES ('003e45472805afa1ee701d83284fa22b', 50);
INSERT INTO customer_loyalty VALUES ('005b65c9a6485aa1b7ac382dd87b018f', 80);
INSERT INTO customer_loyalty VALUES ('0069f43bfc018147f03b7a0f64fa00bd', 20);
INSERT INTO customer_loyalty VALUES ('006b5498d9494c061f8c2f80a6c2f343', 40);

CREATE TABLE customer_spend (
    customer_id  VARCHAR(32) PRIMARY KEY,
    total_spent   INT
);
INSERT INTO customer_spend VALUES ('00331de1659c7f4fb660c8810e6de3f5', 500);
INSERT INTO customer_spend VALUES ('003e45472805afa1ee701d83284fa22b', NULL);
INSERT INTO customer_spend VALUES ('0054556ea954a76ad6f9c4ba79d34a98', 1500);
INSERT INTO customer_spend VALUES ('005b65c9a6485aa1b7ac382dd87b018f', 250);
INSERT INTO customer_spend VALUES ('006496598c918064dc19eef95e5e47f8', 50);

CREATE TABLE spend_band (
    band  VARCHAR(5) PRIMARY KEY,
    lo     INT,
    hi      INT
);
INSERT INTO spend_band VALUES ('B1', 0, 300);
INSERT INTO spend_band VALUES ('B2', 301, 1000);
INSERT INTO spend_band VALUES ('B3', 1001, 2000);

-- =====================================================================
-- 기대 결과표 적재 (../../_common/expected_results.csv topic=JOIN_NULL dbms=SQLSERVER 과 동일)
-- =====================================================================
INSERT INTO sql_example_expectation VALUES ('JN01','JOIN_NULL','등가조인 키에 NULL이 있으면 매칭 안 됨',1,4,NULL,'SQLSERVER','SALES_REGION이 NULL인 고객은 INNER JOIN에서 제외되어 4행');
INSERT INTO sql_example_expectation VALUES ('JN02','JOIN_NULL','LEFT OUTER JOIN이 만드는 NULL',1,6,NULL,'SQLSERVER','고객5명 x 주문매칭수: 2+1+1+1+1=6행');
INSERT INTO sql_example_expectation VALUES ('JN03','JOIN_NULL','COUNT(*) vs COUNT(우측열)',6,4,NULL,'SQLSERVER','COUNT(*)=6(row_count), COUNT(order_id)=4');
INSERT INTO sql_example_expectation VALUES ('JN04','JOIN_NULL','OUTER JOIN 후 WHERE로 보존행 제거 함정',1,2,NULL,'SQLSERVER','amount>100 조건이 NULL/미매칭 행을 모두 제거, 2행만 남음');
INSERT INTO sql_example_expectation VALUES ('JN05','JOIN_NULL','LEFT JOIN+IS NULL 안티조인(정상)',1,2,NULL,'SQLSERVER','주문 없는 고객 2명 정확히 탐지');
INSERT INTO sql_example_expectation VALUES ('JN06','JOIN_NULL','NOT IN 서브쿼리 함정(고아주문 NULL 때문에 깨짐)',1,0,NULL,'SQLSERVER','서브쿼리에 NULL(O5) 있어 0행 - JN05의 2행과 대조되는 오답');
INSERT INTO sql_example_expectation VALUES ('JN07','JOIN_NULL','COALESCE로 미매칭 집계값 기본값 치환',1,0,NULL,'SQLSERVER','주문 없는 고객의 SUM은 NULL, COALESCE로 0 치환');
INSERT INTO sql_example_expectation VALUES ('JN08','JOIN_NULL','JOIN 결과 집계에서 NULL 제외(AVG)',1,100,NULL,'SQLSERVER','고객1의 주문(100,NULL) 평균은 100(NULL 제외, 0 아님)');
INSERT INTO sql_example_expectation VALUES ('JN09','JOIN_NULL','LEFT JOIN + GROUP BY의 NULL 그룹',1,4,NULL,'SQLSERVER','고객1,2,4 그룹 + 미매칭 NULL 그룹 1개 = 4그룹');
INSERT INTO sql_example_expectation VALUES ('JN10','JOIN_NULL','FULL OUTER JOIN + COALESCE 키 병합',7,NULL,NULL,'SQLSERVER','공통2 + 왼쪽전용3 + 오른쪽전용2 = 7행, 병합키는 전부 NOT NULL');
INSERT INTO sql_example_expectation VALUES ('JN11','JOIN_NULL','USING 동등 표현과 NULL 키',1,4,NULL,'SQLSERVER','USING 미지원, ON으로도 JN01과 동일하게 NULL 키 제외');
INSERT INTO sql_example_expectation VALUES ('JN12','JOIN_NULL','비등가조인(BETWEEN) 경계값 NULL',1,4,NULL,'SQLSERVER','TOTAL_SPENT가 NULL인 고객은 어느 구간과도 매칭 안됨');
INSERT INTO sql_example_expectation VALUES ('JN13','JOIN_NULL','CROSS JOIN은 NULL과 무관하게 행수 유지',1,15,NULL,'SQLSERVER','5x3=15, JN01(4행)과 대조');
INSERT INTO sql_example_expectation VALUES ('JN14','JOIN_NULL','Oracle (+) 동등 표현 - WHERE 함정',1,2,NULL,'SQLSERVER','(+) 미지원, LEFT JOIN+WHERE로 JN04와 동일한 함정 재현');
