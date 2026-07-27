-- JOIN×NULL 통합 실습 데이터 준비 (Oracle)
-- 대상: 깨우침/JOIN·표준 JOIN 문제 풀이표.md + 깨우침/NULL 정리.md 의 교차 개념
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- 이 폴더는 ../JOIN-표준JOIN, ../NULL 두 실습을 대체하지 않는다. 그 두 폴더는
-- 그대로 두고, 여기서는 "JOIN과 NULL이 동시에 문제를 일으키는 지점"만
-- 골라 14개 예제(JN01~JN14)로 묶었다 - 예를 들어 조인 키 자체가 NULL이면
-- 등가조인이 매칭되지 않는다는 것, OUTER JOIN 뒤 WHERE가 NULL 행을 지우는
-- 함정, NOT IN 서브쿼리가 NULL 때문에 깨지는 것과 LEFT JOIN+IS NULL이
-- 안전한 이유를 나란히 비교하는 것 등이다.
--
-- 데이터 원칙: customer_id는 저장소 루트 olist_customers_dataset.csv에서
-- 실제로 뽑은 값이다. sales_region/amount/points/total_spent 같은 부가
-- 속성은 이 실습을 위해 새로 부여한 값이다(../JOIN-표준JOIN, ../NULL과 같은
-- 원칙, 자세한 근거는 ../../깨우침 두 문서와 ../JOIN-표준JOIN/README.md 참고).
--
-- 최초 실행 시 아래 DROP 구문들이 ORA-00942(테이블/뷰 없음)를 낼 수 있다.
-- 이는 정상이며 무시하고 계속 진행하면 된다.

DROP TABLE sql_example_validation;
DROP TABLE sql_example_result;
DROP TABLE sql_example_expectation;

DROP TABLE customers;
DROP TABLE region_lookup;
DROP TABLE customer_orders;
DROP TABLE customer_loyalty;
DROP TABLE customer_spend;
DROP TABLE spend_band;

-- =====================================================================
-- 검증 테이블 3종 (공통 스키마는 ../../_common/validation_schema.sql 참고)
-- =====================================================================
CREATE TABLE sql_example_expectation (
    example_id             VARCHAR2(10) PRIMARY KEY,
    topic                   VARCHAR2(15),
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
-- 예제 데이터 (customer_id는 olist_customers_dataset.csv 실제 값)
-- =====================================================================

-- CUSTOMERS : 5명 중 1명(다섯 번째)은 아직 영업권역이 배정되지 않아
-- SALES_REGION이 NULL이다 - 등가조인/USING 이 이 고객을 왜 제외하는지(JN01,
-- JN11), CROSS JOIN은 왜 영향을 받지 않는지(JN13) 비교하는 데 쓴다.
CREATE TABLE customers (
    customer_id   VARCHAR2(32) PRIMARY KEY,
    sales_region   VARCHAR2(10)
);
INSERT INTO customers VALUES ('00331de1659c7f4fb660c8810e6de3f5', 'SUL');
INSERT INTO customers VALUES ('003e45472805afa1ee701d83284fa22b', 'SUL');
INSERT INTO customers VALUES ('0054556ea954a76ad6f9c4ba79d34a98', 'SUDESTE');
INSERT INTO customers VALUES ('005b65c9a6485aa1b7ac382dd87b018f', 'SUDESTE');
INSERT INTO customers VALUES ('006496598c918064dc19eef95e5e47f8', NULL); -- 권역 미배정

-- REGION_LOOKUP : 영업권역 담당자 매핑. NORDESTE는 CUSTOMERS 어느 행도
-- 쓰지 않는다(CROSS JOIN 행수 계산에서만 의미가 있음, JN13).
CREATE TABLE region_lookup (
    sales_region  VARCHAR2(10) PRIMARY KEY,
    manager_name   VARCHAR2(20)
);
INSERT INTO region_lookup VALUES ('SUL', 'Manager A');
INSERT INTO region_lookup VALUES ('SUDESTE', 'Manager B');
INSERT INTO region_lookup VALUES ('NORDESTE', 'Manager C');

-- CUSTOMER_ORDERS : 첫 번째 고객은 주문 2건(하나는 금액 미기재 NULL),
-- 두 번째·네 번째 고객은 1건, 세 번째·다섯 번째 고객은 주문이 없다.
-- 다섯 번째 행(O5)은 고객 식별이 안 된 "고아 주문"(CUSTOMER_ID가 NULL) -
-- NOT IN 서브쿼리 함정(JN06)을 재현하는 데 핵심적인 행이다.
CREATE TABLE customer_orders (
    order_id     VARCHAR2(5) PRIMARY KEY,
    customer_id  VARCHAR2(32),
    amount        NUMBER
);
INSERT INTO customer_orders VALUES ('O1', '00331de1659c7f4fb660c8810e6de3f5', 100);
INSERT INTO customer_orders VALUES ('O2', '00331de1659c7f4fb660c8810e6de3f5', NULL);
INSERT INTO customer_orders VALUES ('O3', '003e45472805afa1ee701d83284fa22b', 200);
INSERT INTO customer_orders VALUES ('O4', '005b65c9a6485aa1b7ac382dd87b018f', 150);
INSERT INTO customer_orders VALUES ('O5', NULL, 999); -- 고아 주문(고객 미상)

-- CUSTOMER_LOYALTY : CUSTOMERS와 부분적으로만 겹치는 실제 고객 목록
-- (2명은 CUSTOMERS와 공통, 2명은 CUSTOMERS에 없는 새로운 실제 고객) -
-- FULL OUTER JOIN + COALESCE 키 병합(JN10)에 쓴다.
CREATE TABLE customer_loyalty (
    customer_id  VARCHAR2(32) PRIMARY KEY,
    points        NUMBER
);
INSERT INTO customer_loyalty VALUES ('003e45472805afa1ee701d83284fa22b', 50);
INSERT INTO customer_loyalty VALUES ('005b65c9a6485aa1b7ac382dd87b018f', 80);
INSERT INTO customer_loyalty VALUES ('0069f43bfc018147f03b7a0f64fa00bd', 20);
INSERT INTO customer_loyalty VALUES ('006b5498d9494c061f8c2f80a6c2f343', 40);

-- CUSTOMER_SPEND / SPEND_BAND : 비등가 조인(BETWEEN) 경계값이 NULL이면
-- 매칭되지 않음을 보여주는 전용 테이블(JN12). 두 번째 고객은 누적
-- 구매액이 아직 집계되지 않아 TOTAL_SPENT가 NULL이다.
CREATE TABLE customer_spend (
    customer_id  VARCHAR2(32) PRIMARY KEY,
    total_spent   NUMBER
);
INSERT INTO customer_spend VALUES ('00331de1659c7f4fb660c8810e6de3f5', 500);
INSERT INTO customer_spend VALUES ('003e45472805afa1ee701d83284fa22b', NULL);
INSERT INTO customer_spend VALUES ('0054556ea954a76ad6f9c4ba79d34a98', 1500);
INSERT INTO customer_spend VALUES ('005b65c9a6485aa1b7ac382dd87b018f', 250);
INSERT INTO customer_spend VALUES ('006496598c918064dc19eef95e5e47f8', 50);

CREATE TABLE spend_band (
    band  VARCHAR2(5) PRIMARY KEY,
    lo     NUMBER,
    hi      NUMBER
);
INSERT INTO spend_band VALUES ('B1', 0, 300);
INSERT INTO spend_band VALUES ('B2', 301, 1000);
INSERT INTO spend_band VALUES ('B3', 1001, 2000);

COMMIT;

-- =====================================================================
-- 기대 결과표 적재 (../../_common/expected_results.csv topic=JOIN_NULL dbms=ORACLE 과 동일)
-- =====================================================================
INSERT INTO sql_example_expectation VALUES ('JN01','JOIN_NULL','등가조인 키에 NULL이 있으면 매칭 안 됨',1,4,NULL,'ORACLE','SALES_REGION이 NULL인 고객은 INNER JOIN에서 제외되어 4행');
INSERT INTO sql_example_expectation VALUES ('JN02','JOIN_NULL','LEFT OUTER JOIN이 만드는 NULL',1,6,NULL,'ORACLE','고객5명 x 주문매칭수: 2+1+1+1+1=6행');
INSERT INTO sql_example_expectation VALUES ('JN03','JOIN_NULL','COUNT(*) vs COUNT(우측열)',6,4,NULL,'ORACLE','COUNT(*)=6(row_count), COUNT(order_id)=4(고아주문 O5는 매칭 안돼 제외)');
INSERT INTO sql_example_expectation VALUES ('JN04','JOIN_NULL','OUTER JOIN 후 WHERE로 보존행 제거 함정',1,2,NULL,'ORACLE','amount>100 조건이 NULL/미매칭 행을 모두 제거, 2행만 남음');
INSERT INTO sql_example_expectation VALUES ('JN05','JOIN_NULL','LEFT JOIN+IS NULL 안티조인(정상)',1,2,NULL,'ORACLE','주문 없는 고객 2명 정확히 탐지');
INSERT INTO sql_example_expectation VALUES ('JN06','JOIN_NULL','NOT IN 서브쿼리 함정(고아주문 NULL 때문에 깨짐)',1,0,NULL,'ORACLE','서브쿼리에 NULL(O5) 있어 0행 - JN05의 2행과 대조되는 오답');
INSERT INTO sql_example_expectation VALUES ('JN07','JOIN_NULL','COALESCE로 미매칭 집계값 기본값 치환',1,0,NULL,'ORACLE','주문 없는 고객의 SUM은 NULL, COALESCE로 0 치환');
INSERT INTO sql_example_expectation VALUES ('JN08','JOIN_NULL','JOIN 결과 집계에서 NULL 제외(AVG)',1,100,NULL,'ORACLE','고객1의 주문(100,NULL) 평균은 100(NULL 제외, 0 아님)');
INSERT INTO sql_example_expectation VALUES ('JN09','JOIN_NULL','LEFT JOIN + GROUP BY의 NULL 그룹',1,4,NULL,'ORACLE','고객1,2,4 그룹 + 미매칭 NULL 그룹 1개 = 4그룹');
INSERT INTO sql_example_expectation VALUES ('JN10','JOIN_NULL','FULL OUTER JOIN + COALESCE 키 병합',7,NULL,NULL,'ORACLE','공통2 + 왼쪽전용3 + 오른쪽전용2 = 7행, 병합키는 전부 NOT NULL');
INSERT INTO sql_example_expectation VALUES ('JN11','JOIN_NULL','USING과 NULL 키',1,4,NULL,'ORACLE','USING(SALES_REGION)도 JN01과 동일하게 NULL 키 제외');
INSERT INTO sql_example_expectation VALUES ('JN12','JOIN_NULL','비등가조인(BETWEEN) 경계값 NULL',1,4,NULL,'ORACLE','TOTAL_SPENT가 NULL인 고객은 어느 구간과도 매칭 안됨');
INSERT INTO sql_example_expectation VALUES ('JN13','JOIN_NULL','CROSS JOIN은 NULL과 무관하게 행수 유지',1,15,NULL,'ORACLE','5x3=15, JN01(4행)과 대조');
INSERT INTO sql_example_expectation VALUES ('JN14','JOIN_NULL','Oracle (+) 반대편 필터에 (+)누락시 무력화',1,2,NULL,'ORACLE','(+) 없는 AND 조건이 OUTER JOIN 효과를 지움, JN04와 동일 결과');

COMMIT;
