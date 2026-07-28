-- JOIN×NULL 통합 실습 데이터 준비 (SQL Server)
-- 대상: 교차 개념 A~N. Oracle/01_prepare.sql과 example_id·기대값이 전부
-- 동일하다(단 JN10=USING 대응 ON, JN14=Oracle (+) 대응 ANSI LEFT JOIN+WHERE
-- 두 곳만 문법이 다르다). customer_id 값과 데이터 출처 설명은
-- Oracle/01_prepare.sql 상단 주석 및 README를 그대로 따른다.
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).

IF OBJECT_ID('sql_example_validation', 'U') IS NOT NULL DROP TABLE sql_example_validation;
IF OBJECT_ID('sql_example_result', 'U') IS NOT NULL DROP TABLE sql_example_result;
IF OBJECT_ID('sql_example_expectation', 'U') IS NOT NULL DROP TABLE sql_example_expectation;

IF OBJECT_ID('order_events', 'U') IS NOT NULL DROP TABLE order_events;
IF OBJECT_ID('orders', 'U') IS NOT NULL DROP TABLE orders;
IF OBJECT_ID('customer_spend', 'U') IS NOT NULL DROP TABLE customer_spend;
IF OBJECT_ID('spend_band', 'U') IS NOT NULL DROP TABLE spend_band;
IF OBJECT_ID('regions', 'U') IS NOT NULL DROP TABLE regions;
IF OBJECT_ID('customers', 'U') IS NOT NULL DROP TABLE customers;

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
    note                    VARCHAR(300)
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
INSERT INTO customers VALUES ('00331de1659c7f4fb660c8810e6de3f5', 'SUL');       -- C1
INSERT INTO customers VALUES ('003e45472805afa1ee701d83284fa22b', 'SUL');       -- C2
INSERT INTO customers VALUES ('0054556ea954a76ad6f9c4ba79d34a98', 'SUDESTE');   -- C3
INSERT INTO customers VALUES ('005b65c9a6485aa1b7ac382dd87b018f', 'SUDESTE');   -- C4
INSERT INTO customers VALUES ('006496598c918064dc19eef95e5e47f8', NULL);       -- C5
INSERT INTO customers VALUES ('0069f43bfc018147f03b7a0f64fa00bd', NULL);       -- C6
INSERT INTO customers VALUES ('006b5498d9494c061f8c2f80a6c2f343', 'SUDESTE');  -- C7

CREATE TABLE regions (
    region_id     VARCHAR(5) PRIMARY KEY,
    sales_region   VARCHAR(10),
    manager_name   VARCHAR(20)
);
INSERT INTO regions VALUES ('R1', 'SUL', 'Manager A');
INSERT INTO regions VALUES ('R2', 'SUDESTE', 'Manager B');
INSERT INTO regions VALUES ('R3', 'NORDESTE', 'Manager C');
INSERT INTO regions VALUES ('R4', NULL, 'Unassigned Desk');

CREATE TABLE orders (
    order_id     VARCHAR(5) PRIMARY KEY,
    customer_id  VARCHAR(32),
    order_date   DATE,
    amount        INT
);
INSERT INTO orders VALUES ('O1', '00331de1659c7f4fb660c8810e6de3f5', '2024-01-05', 100);
INSERT INTO orders VALUES ('O2', '00331de1659c7f4fb660c8810e6de3f5', '2024-01-08', NULL);
INSERT INTO orders VALUES ('O3', '003e45472805afa1ee701d83284fa22b', '2024-01-10', 200);
INSERT INTO orders VALUES ('O4', '005b65c9a6485aa1b7ac382dd87b018f', '2024-02-01', 150);
INSERT INTO orders VALUES ('O5', NULL, '2024-02-02', 999);
INSERT INTO orders VALUES ('O6', '0054556ea954a76ad6f9c4ba79d34a98', '2024-02-10', 0);
INSERT INTO orders VALUES ('O7', '0069f43bfc018147f03b7a0f64fa00bd', '2024-02-15', NULL);
INSERT INTO orders VALUES ('O8', NULL, NULL, 500);

CREATE TABLE order_events (
    event_id     VARCHAR(5) PRIMARY KEY,
    customer_id  VARCHAR(32),
    event_date   DATE,
    event_type   VARCHAR(20)
);
INSERT INTO order_events VALUES ('E1', '00331de1659c7f4fb660c8810e6de3f5', '2024-01-05', 'VIEWED');
INSERT INTO order_events VALUES ('E2', '003e45472805afa1ee701d83284fa22b', NULL, 'CART');
INSERT INTO order_events VALUES ('E3', NULL, '2024-01-08', 'CART');
INSERT INTO order_events VALUES ('E4', NULL, NULL, 'UNKNOWN_EVENT');

CREATE TABLE customer_spend (
    customer_id  VARCHAR(32) PRIMARY KEY,
    total_spent   INT
);
INSERT INTO customer_spend VALUES ('00331de1659c7f4fb660c8810e6de3f5', 0);
INSERT INTO customer_spend VALUES ('003e45472805afa1ee701d83284fa22b', 300);
INSERT INTO customer_spend VALUES ('0054556ea954a76ad6f9c4ba79d34a98', 301);
INSERT INTO customer_spend VALUES ('005b65c9a6485aa1b7ac382dd87b018f', 2500);
INSERT INTO customer_spend VALUES ('006496598c918064dc19eef95e5e47f8', NULL);
INSERT INTO customer_spend VALUES ('0069f43bfc018147f03b7a0f64fa00bd', 1000);
INSERT INTO customer_spend VALUES ('006b5498d9494c061f8c2f80a6c2f343', 1001);

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
INSERT INTO sql_example_expectation VALUES ('JN01A','JOIN_NULL','A.등가조인 키 NULL - INNER JOIN 매칭 제외',1,5,NULL,'SQLSERVER','SUL 2명+SUDESTE 3명=5행, 권역미배정 C5/C6 제외');
INSERT INTO sql_example_expectation VALUES ('JN01B','JOIN_NULL','A.등가조인 키 NULL - LEFT OUTER JOIN 보존(양쪽 NULL도 매칭안됨)',1,7,NULL,'SQLSERVER','매칭5행+C5/C6 미매칭보존2행=7행, R4(NULL)와도 매칭안됨');
INSERT INTO sql_example_expectation VALUES ('JN02A','JOIN_NULL','B.OUTER JOIN이 만든 패딩 NULL(주문 자체가 없음)',1,2,NULL,'SQLSERVER','C5,C7 주문없음: order_id IS NULL로 식별되는 미매칭 보존행 2건');
INSERT INTO sql_example_expectation VALUES ('JN02B','JOIN_NULL','B.원본에 저장된 NULL(주문은 있으나 금액 NULL)',1,2,NULL,'SQLSERVER','O2(C1),O7(C6): order_id NOT NULL인데 amount만 NULL인 실제 저장 NULL 2건');
INSERT INTO sql_example_expectation VALUES ('JN03A','JOIN_NULL','C.ON 필터 - 매칭 후보만 제한',1,7,NULL,'SQLSERVER','7명 전원 보존(ON 안의 amount>100은 매칭후보만 줄일 뿐 행을 지우지 않음)');
INSERT INTO sql_example_expectation VALUES ('JN03B','JOIN_NULL','C.WHERE 필터 - 보존행까지 제거(null-rejecting)',1,2,NULL,'SQLSERVER','O3,O4만 남음(WHERE의 amount>100이 NULL패딩 행까지 UNKNOWN으로 제거)');
INSERT INTO sql_example_expectation VALUES ('JN04A','JOIN_NULL','D.COUNT(*) - 미매칭 패딩행도 포함',1,8,NULL,'SQLSERVER','LEFT JOIN 결과 총 8행');
INSERT INTO sql_example_expectation VALUES ('JN04B','JOIN_NULL','D.COUNT(NOT NULL 보장 키) - 미매칭 제외',1,6,NULL,'SQLSERVER','COUNT(o.order_id)=6, C5/C7 패딩 2건 제외');
INSERT INTO sql_example_expectation VALUES ('JN04C','JOIN_NULL','D.COUNT(nullable 일반열) - 원본 NULL도 추가 제외',1,4,NULL,'SQLSERVER','COUNT(o.amount)=4, 패딩2건+원본NULL(O2,O7)2건 제외');
INSERT INTO sql_example_expectation VALUES ('JN05A','JOIN_NULL','E.안티조인 - LEFT JOIN+IS NULL(정상)',1,2,NULL,'SQLSERVER','주문 없는 고객 C5,C7 정확히 탐지');
INSERT INTO sql_example_expectation VALUES ('JN05B','JOIN_NULL','E.안티조인 - NOT EXISTS(정상)',1,2,NULL,'SQLSERVER','상관 서브쿼리라 NULL 영향 없음, JN05A와 동일 2행');
INSERT INTO sql_example_expectation VALUES ('JN05C','JOIN_NULL','E.안티조인 - NOT IN(고아주문 NULL 때문에 깨짐)',1,0,NULL,'SQLSERVER','서브쿼리에 O5/O8의 NULL customer_id 있어 0행(오답)');
INSERT INTO sql_example_expectation VALUES ('JN05D','JOIN_NULL','E.안티조인 - NOT IN 안전 대안(서브쿼리 NULL 제거)',1,2,NULL,'SQLSERVER','WHERE customer_id IS NOT NULL 추가하면 다시 2행(정상)');
INSERT INTO sql_example_expectation VALUES ('JN06A','JOIN_NULL','F.안티조인 검사열 - order_id IS NULL(올바름)',1,2,NULL,'SQLSERVER','JN02A/JN05A와 동일 2행, NOT NULL 보장 키 검사');
INSERT INTO sql_example_expectation VALUES ('JN06B','JOIN_NULL','F.안티조인 검사열 - amount IS NULL(오답, 상태 혼합)',1,4,NULL,'SQLSERVER','C1,C5,C6,C7 4행 - 주문없음(C5,C7)과 금액NULL(C1,C6)이 뒤섞임');
INSERT INTO sql_example_expectation VALUES ('JN07A','JOIN_NULL','G.집계+OUTER JOIN - 실제 합계 0(C3)',1,0,'RAW_ZERO','SQLSERVER','C3 SUM(0)=0, 원본부터 NULL이 아닌 진짜 0원');
INSERT INTO sql_example_expectation VALUES ('JN07B','JOIN_NULL','G.집계+OUTER JOIN - 주문없어 합계 NULL(C5)',1,0,'RAW_NULL','SQLSERVER','C5 SUM은 원본이 NULL, ISNULL로 0 치환한 값이 우연히 C3와 같을 뿐');
INSERT INTO sql_example_expectation VALUES ('JN08A','JOIN_NULL','H.GROUP BY c.customer_id(왼쪽 고객별 그룹)',1,7,NULL,'SQLSERVER','고객 7명 각자 그룹 - 미매칭 고객도 자기 그룹 유지');
INSERT INTO sql_example_expectation VALUES ('JN08B','JOIN_NULL','H.GROUP BY o.customer_id(우측 조인키별, NULL그룹 병합)',1,6,NULL,'SQLSERVER','실제고객5그룹+미매칭 NULL 병합그룹1개=6그룹(C5,C7이 하나로 합쳐짐)');
INSERT INTO sql_example_expectation VALUES ('JN08C','JOIN_NULL','H.병합된 NULL 그룹의 실제 크기',1,2,NULL,'SQLSERVER','o.customer_id IS NULL 그룹에 C5,C7 2행이 들어있음');
INSERT INTO sql_example_expectation VALUES ('JN09','JOIN_NULL','I.FULL OUTER JOIN 행수(왼쪽전용+공통+오른쪽전용)',1,9,NULL,'SQLSERVER','매칭5+왼쪽전용(C5,C6)2+오른쪽전용(R3,R4)2=9행');
INSERT INTO sql_example_expectation VALUES ('JN09B','JOIN_NULL','I.COALESCE 통합키가 NULL인 행(양쪽 다 NULL이라 안 합쳐짐)',1,3,NULL,'SQLSERVER','C5,C6,R4 3행 - 서로 매칭 안되고 별도 행으로 남아 통합키도 NULL');
INSERT INTO sql_example_expectation VALUES ('JN10','JOIN_NULL','J.USING 동등 표현과 NULL 키',1,5,NULL,'SQLSERVER','USING 미지원, ON으로도 JN01A와 동일하게 5행');
INSERT INTO sql_example_expectation VALUES ('JN11A','JOIN_NULL','K.비등가조인(BETWEEN) INNER - 경계값 포함',1,5,NULL,'SQLSERVER','C1(0),C2(300),C3(301),C6(1000),C7(1001) 매칭, C4(범위밖)/C5(NULL) 제외');
INSERT INTO sql_example_expectation VALUES ('JN11B','JOIN_NULL','K.비등가조인(BETWEEN) LEFT - 미매칭 보존',1,7,NULL,'SQLSERVER','7명 전원 보존, C4/C5는 band 열이 NULL로 채워짐');
INSERT INTO sql_example_expectation VALUES ('JN12','JOIN_NULL','L.복합 조인키 일부/양쪽 NULL - INNER',1,1,NULL,'SQLSERVER','O1-E1만 두 열 모두 일치, 나머지는 한쪽 또는 양쪽 NULL이라 매칭안됨');
INSERT INTO sql_example_expectation VALUES ('JN12B','JOIN_NULL','L.복합 조인키 - LEFT 보존',1,8,NULL,'SQLSERVER','주문 8건 전부 보존, O1만 이벤트와 매칭되고 나머지 7건은 이벤트열 NULL');
INSERT INTO sql_example_expectation VALUES ('JN13','JOIN_NULL','M.CROSS JOIN 대조(등가조인과 달리 NULL과 무관)',1,28,NULL,'SQLSERVER','7x4=28, JN01A(5행)와 대조 - 등가조인만 NULL 키를 제외한다');
INSERT INTO sql_example_expectation VALUES ('JN14','JOIN_NULL','N.Oracle (+) 동등 표현 - ANSI LEFT JOIN+WHERE 함정',1,2,NULL,'SQLSERVER','JN03B와 완전히 동일한 SQL·동일한 메커니즘·동일 결과(2행)');
