-- JOIN×NULL 통합 실습 데이터 준비 (Oracle)
-- 대상: 교차 개념 A~N(조인 키 NULL, OUTER JOIN 패딩 NULL, ON/WHERE, COUNT 차이,
-- 안티조인 3종, 안티조인 검사열 오선택, 집계+OUTER JOIN, GROUP BY NULL,
-- FULL OUTER JOIN 통합키, USING, 비등가조인 경계값, 복합키 NULL, CROSS JOIN 대조,
-- Oracle (+) 함정)
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- 이 폴더는 ../JOIN-표준JOIN, ../NULL 두 실습을 대체하지 않는다. JOIN 문법
-- 전체나 NULL 일반 개념은 그 두 폴더에서 이미 다룬다. 여기서는 "JOIN과 NULL이
-- 동시에 등장했을 때만 생기는" 현상만 다룬다 - 예를 들어 조인 키 자체가
-- NULL이면 등가조인이 결코 매칭되지 않는다는 것, OUTER JOIN이 "새로 만든" NULL과
-- 원본에 저장돼 있던 NULL을 구분해야 한다는 것, ON에 넣은 조건과 WHERE에 넣은
-- 조건이 같은 비교식이라도 결과 행 수가 달라진다는 것 등이다.
--
-- 데이터 원칙(README "데이터 출처와 합성 범위" 참고):
--   - customers.customer_id 7명은 모두 저장소 루트 olist_customers_dataset.csv에서
--     실제로 뽑은 값이다(../NULL/Oracle/01_prepare.sql, ../JOIN-표준JOIN/Oracle/01_prepare.sql과
--     동일 CSV, 그 중 이 폴더 전용으로 6명은 기존 JOIN×NULL 구예제에서 쓰던 값을
--     그대로 재사용했고 1명(customer_id 끝자리 ...6b5498...)은 ../NULL 폴더의
--     customer_loyalty에서 이미 검증된 실제 값을 재사용했다.
--   - regions/orders/order_events/customer_spend/spend_band의 PK 문자열(R1,O1,E1...),
--     날짜, 금액, 구간 경계값은 모두 이 실습을 위한 합성값이다. Olist 원본에는
--     주문 테이블도, 결측치도 없다(결측 0건, ../NULL/README 참고).
--   - orders의 O5, O8은 "고아 주문"이다 - customer_id가 NULL인 주문은 실제
--     원자료에는 존재하지 않으며, NOT IN 함정(E)과 복합키 양쪽 NULL(L)을
--     재현하기 위해 의도적으로 삽입한 합성 행이다.
--
-- 최초 실행 시 아래 DROP 구문들이 ORA-00942(테이블/뷰 없음)를 낼 수 있다.
-- 이는 정상이며 무시하고 계속 진행하면 된다.

DROP TABLE sql_example_validation;
DROP TABLE sql_example_result;
DROP TABLE sql_example_expectation;

DROP TABLE order_events;
DROP TABLE orders;
DROP TABLE customer_spend;
DROP TABLE spend_band;
DROP TABLE regions;
DROP TABLE customers;

-- =====================================================================
-- 검증 테이블 3종 (공통 스키마는 ../../_common/validation_schema.sql 참고)
-- actual_row_count는 항상 "이 예제의 INSERT SELECT가 sql_example_result에
-- 남기는 물리적 행 수"(=1)를 뜻하고, 실제로 검증하려는 COUNT/그룹수/합계 같은
-- 핵심 수치는 항상 actual_numeric_value에 담는다(섹션 7 규칙, 02_examples.sql
-- 전체에서 예외 없이 지킨다).
-- =====================================================================
CREATE TABLE sql_example_expectation (
    example_id             VARCHAR2(10) PRIMARY KEY,
    topic                   VARCHAR2(15),
    concept                 VARCHAR2(100),
    expected_row_count      NUMBER,
    expected_numeric_value  NUMBER,
    expected_text_value     VARCHAR2(100),
    dbms_name               VARCHAR2(20),
    note                    VARCHAR2(300)
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
-- CUSTOMERS : 7명. C1,C2=SUL / C3,C4,C7=SUDESTE / C5,C6=권역 미배정(NULL).
-- C5,C6은 각각 A(등가조인 키 NULL)와 E/F(주문 없음/주문은 있으나 금액 NULL)의
-- 재료로 동시에 쓰인다 - 이 폴더는 "테이블마다 새 개념"이 아니라 "같은 데이터를
-- 여러 각도에서" 보는 것이 목적이기 때문이다.
-- =====================================================================
CREATE TABLE customers (
    customer_id   VARCHAR2(32) PRIMARY KEY,
    sales_region   VARCHAR2(10)
);
INSERT INTO customers VALUES ('00331de1659c7f4fb660c8810e6de3f5', 'SUL');       -- C1
INSERT INTO customers VALUES ('003e45472805afa1ee701d83284fa22b', 'SUL');       -- C2
INSERT INTO customers VALUES ('0054556ea954a76ad6f9c4ba79d34a98', 'SUDESTE');   -- C3
INSERT INTO customers VALUES ('005b65c9a6485aa1b7ac382dd87b018f', 'SUDESTE');   -- C4
INSERT INTO customers VALUES ('006496598c918064dc19eef95e5e47f8', NULL);       -- C5 권역 미배정, 주문 없음
INSERT INTO customers VALUES ('0069f43bfc018147f03b7a0f64fa00bd', NULL);       -- C6 권역 미배정, 주문은 있으나 금액 NULL
INSERT INTO customers VALUES ('006b5498d9494c061f8c2f80a6c2f343', 'SUDESTE');  -- C7 주문 없음

-- REGIONS : sales_region 열 이름을 CUSTOMERS와 똑같이 맞춰 USING(sales_region)이
-- 가능하게 했다(J). R4는 sales_region 자체가 NULL인 "미배정 데스크" - C5/C6와
-- 마찬가지로 NULL이지만, NULL은 NULL과도 매칭되지 않으므로 서로 연결되지 않는다(A).
CREATE TABLE regions (
    region_id     VARCHAR2(5) PRIMARY KEY,
    sales_region   VARCHAR2(10),
    manager_name   VARCHAR2(20)
);
INSERT INTO regions VALUES ('R1', 'SUL', 'Manager A');
INSERT INTO regions VALUES ('R2', 'SUDESTE', 'Manager B');
INSERT INTO regions VALUES ('R3', 'NORDESTE', 'Manager C'); -- 어떤 고객도 이 권역이 아님(오른쪽 전용)
INSERT INTO regions VALUES ('R4', NULL, 'Unassigned Desk'); -- sales_region 자체가 NULL

-- ORDERS : O1~O8. O2/O7은 "주문은 있지만 금액이 아직 확정되지 않은" 원본 NULL,
-- O5/O8은 고객 식별이 안 된 고아 주문(O8은 날짜까지 NULL이라 복합키 둘 다 NULL).
CREATE TABLE orders (
    order_id     VARCHAR2(5) PRIMARY KEY,
    customer_id  VARCHAR2(32),
    order_date   DATE,
    amount        NUMBER
);
INSERT INTO orders VALUES ('O1', '00331de1659c7f4fb660c8810e6de3f5', DATE '2024-01-05', 100);  -- C1, 정상
INSERT INTO orders VALUES ('O2', '00331de1659c7f4fb660c8810e6de3f5', DATE '2024-01-08', NULL);  -- C1, 금액 미확정(원본 NULL)
INSERT INTO orders VALUES ('O3', '003e45472805afa1ee701d83284fa22b', DATE '2024-01-10', 200);  -- C2, 정상(amount>100)
INSERT INTO orders VALUES ('O4', '005b65c9a6485aa1b7ac382dd87b018f', DATE '2024-02-01', 150);  -- C4, 정상(amount>100)
INSERT INTO orders VALUES ('O5', NULL, DATE '2024-02-02', 999);                                  -- 고아 주문(고객 미상)
INSERT INTO orders VALUES ('O6', '0054556ea954a76ad6f9c4ba79d34a98', DATE '2024-02-10', 0);     -- C3, 실제로 0원(환불)
INSERT INTO orders VALUES ('O7', '0069f43bfc018147f03b7a0f64fa00bd', DATE '2024-02-15', NULL);  -- C6, 금액 미확정(원본 NULL)
INSERT INTO orders VALUES ('O8', NULL, NULL, 500);                                                -- 고아 주문(고객+날짜 모두 NULL)

-- ORDER_EVENTS : 복합키(customer_id, event_date) 예제(L) 전용. E1은 O1과 완전
-- 일치, E2/E3는 각각 한 열만 NULL이라 매칭 실패, E4는 O8과 "같은 위치가 둘 다
-- NULL"이지만 그래도 매칭되지 않는다는 것을 보여준다.
CREATE TABLE order_events (
    event_id     VARCHAR2(5) PRIMARY KEY,
    customer_id  VARCHAR2(32),
    event_date   DATE,
    event_type   VARCHAR2(20)
);
INSERT INTO order_events VALUES ('E1', '00331de1659c7f4fb660c8810e6de3f5', DATE '2024-01-05', 'VIEWED');       -- O1과 완전 일치
INSERT INTO order_events VALUES ('E2', '003e45472805afa1ee701d83284fa22b', NULL, 'CART');                      -- 고객은 O3와 일치, 날짜 NULL
INSERT INTO order_events VALUES ('E3', NULL, DATE '2024-01-08', 'CART');                                       -- 날짜는 O2와 일치, 고객 NULL
INSERT INTO order_events VALUES ('E4', NULL, NULL, 'UNKNOWN_EVENT');                                           -- 고객·날짜 모두 NULL(O8과 대응)

-- CUSTOMER_SPEND / SPEND_BAND : 비등가조인(BETWEEN) 경계값 예제(K) 전용.
-- 구간 최솟값(0)·최댓값(300)·다음 구간 시작값(301)·다음 구간 경계(1000/1001)·
-- 범위 밖(2500)·NULL을 모두 포함한다.
CREATE TABLE customer_spend (
    customer_id  VARCHAR2(32) PRIMARY KEY,
    total_spent   NUMBER
);
INSERT INTO customer_spend VALUES ('00331de1659c7f4fb660c8810e6de3f5', 0);     -- C1: B1 구간 최솟값
INSERT INTO customer_spend VALUES ('003e45472805afa1ee701d83284fa22b', 300);   -- C2: B1 구간 최댓값
INSERT INTO customer_spend VALUES ('0054556ea954a76ad6f9c4ba79d34a98', 301);   -- C3: B2 구간 시작값(다음 구간)
INSERT INTO customer_spend VALUES ('005b65c9a6485aa1b7ac382dd87b018f', 2500);  -- C4: 범위 밖(어느 구간도 아님)
INSERT INTO customer_spend VALUES ('006496598c918064dc19eef95e5e47f8', NULL); -- C5: NULL(집계 미완료)
INSERT INTO customer_spend VALUES ('0069f43bfc018147f03b7a0f64fa00bd', 1000); -- C6: B2 구간 최댓값(경계)
INSERT INTO customer_spend VALUES ('006b5498d9494c061f8c2f80a6c2f343', 1001); -- C7: B3 구간 시작값(경계)

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
INSERT INTO sql_example_expectation VALUES ('JN01A','JOIN_NULL','A.등가조인 키 NULL - INNER JOIN 매칭 제외',1,5,NULL,'ORACLE','SUL 2명+SUDESTE 3명=5행, 권역미배정 C5/C6 제외');
INSERT INTO sql_example_expectation VALUES ('JN01B','JOIN_NULL','A.등가조인 키 NULL - LEFT OUTER JOIN 보존(양쪽 NULL도 매칭안됨)',1,7,NULL,'ORACLE','매칭5행+C5/C6 미매칭보존2행=7행, R4(NULL)와도 매칭안됨');
INSERT INTO sql_example_expectation VALUES ('JN02A','JOIN_NULL','B.OUTER JOIN이 만든 패딩 NULL(주문 자체가 없음)',1,2,NULL,'ORACLE','C5,C7 주문없음: order_id IS NULL로 식별되는 미매칭 보존행 2건');
INSERT INTO sql_example_expectation VALUES ('JN02B','JOIN_NULL','B.원본에 저장된 NULL(주문은 있으나 금액 NULL)',1,2,NULL,'ORACLE','O2(C1),O7(C6): order_id NOT NULL인데 amount만 NULL인 실제 저장 NULL 2건');
INSERT INTO sql_example_expectation VALUES ('JN03A','JOIN_NULL','C.ON 필터 - 매칭 후보만 제한',1,7,NULL,'ORACLE','7명 전원 보존(ON 안의 amount>100은 매칭후보만 줄일 뿐 행을 지우지 않음)');
INSERT INTO sql_example_expectation VALUES ('JN03B','JOIN_NULL','C.WHERE 필터 - 보존행까지 제거(null-rejecting)',1,2,NULL,'ORACLE','O3,O4만 남음(WHERE의 amount>100이 NULL패딩 행까지 UNKNOWN으로 제거)');
INSERT INTO sql_example_expectation VALUES ('JN04A','JOIN_NULL','D.COUNT(*) - 미매칭 패딩행도 포함',1,8,NULL,'ORACLE','LEFT JOIN 결과 총 8행(2+1+1+1+1+1+1)');
INSERT INTO sql_example_expectation VALUES ('JN04B','JOIN_NULL','D.COUNT(NOT NULL 보장 키) - 미매칭 제외',1,6,NULL,'ORACLE','COUNT(o.order_id)=6, C5/C7 패딩 2건 제외');
INSERT INTO sql_example_expectation VALUES ('JN04C','JOIN_NULL','D.COUNT(nullable 일반열) - 원본 NULL도 추가 제외',1,4,NULL,'ORACLE','COUNT(o.amount)=4, 패딩2건+원본NULL(O2,O7)2건 제외');
INSERT INTO sql_example_expectation VALUES ('JN05A','JOIN_NULL','E.안티조인 - LEFT JOIN+IS NULL(정상)',1,2,NULL,'ORACLE','주문 없는 고객 C5,C7 정확히 탐지');
INSERT INTO sql_example_expectation VALUES ('JN05B','JOIN_NULL','E.안티조인 - NOT EXISTS(정상)',1,2,NULL,'ORACLE','상관 서브쿼리라 NULL 영향 없음, JN05A와 동일 2행');
INSERT INTO sql_example_expectation VALUES ('JN05C','JOIN_NULL','E.안티조인 - NOT IN(고아주문 NULL 때문에 깨짐)',1,0,NULL,'ORACLE','서브쿼리에 O5/O8의 NULL customer_id 있어 0행(오답)');
INSERT INTO sql_example_expectation VALUES ('JN05D','JOIN_NULL','E.안티조인 - NOT IN 안전 대안(서브쿼리 NULL 제거)',1,2,NULL,'ORACLE','WHERE customer_id IS NOT NULL 추가하면 다시 2행(정상)');
INSERT INTO sql_example_expectation VALUES ('JN06A','JOIN_NULL','F.안티조인 검사열 - order_id IS NULL(올바름)',1,2,NULL,'ORACLE','JN02A/JN05A와 동일 2행, NOT NULL 보장 키 검사');
INSERT INTO sql_example_expectation VALUES ('JN06B','JOIN_NULL','F.안티조인 검사열 - amount IS NULL(오답, 상태 혼합)',1,4,NULL,'ORACLE','C1,C5,C6,C7 4행 - 주문없음(C5,C7)과 금액NULL(C1,C6)이 뒤섞임');
INSERT INTO sql_example_expectation VALUES ('JN07A','JOIN_NULL','G.집계+OUTER JOIN - 실제 합계 0(C3)',1,0,'RAW_ZERO','ORACLE','C3 SUM(0)=0, 원본부터 NULL이 아닌 진짜 0원');
INSERT INTO sql_example_expectation VALUES ('JN07B','JOIN_NULL','G.집계+OUTER JOIN - 주문없어 합계 NULL(C5)',1,0,'RAW_NULL','ORACLE','C5 SUM은 원본이 NULL, NVL로 0 치환한 값이 우연히 C3와 같을 뿐');
INSERT INTO sql_example_expectation VALUES ('JN08A','JOIN_NULL','H.GROUP BY c.customer_id(왼쪽 고객별 그룹)',1,7,NULL,'ORACLE','고객 7명 각자 그룹 - 미매칭 고객도 자기 그룹 유지');
INSERT INTO sql_example_expectation VALUES ('JN08B','JOIN_NULL','H.GROUP BY o.customer_id(우측 조인키별, NULL그룹 병합)',1,6,NULL,'ORACLE','실제고객5그룹+미매칭 NULL 병합그룹1개=6그룹(C5,C7이 하나로 합쳐짐)');
INSERT INTO sql_example_expectation VALUES ('JN08C','JOIN_NULL','H.병합된 NULL 그룹의 실제 크기',1,2,NULL,'ORACLE','o.customer_id IS NULL 그룹에 C5,C7 2행이 들어있음');
INSERT INTO sql_example_expectation VALUES ('JN09','JOIN_NULL','I.FULL OUTER JOIN 행수(왼쪽전용+공통+오른쪽전용)',1,9,NULL,'ORACLE','매칭5+왼쪽전용(C5,C6)2+오른쪽전용(R3,R4)2=9행');
INSERT INTO sql_example_expectation VALUES ('JN09B','JOIN_NULL','I.COALESCE 통합키가 NULL인 행(양쪽 다 NULL이라 안 합쳐짐)',1,3,NULL,'ORACLE','C5,C6,R4 3행 - 서로 매칭 안되고 별도 행으로 남아 통합키도 NULL');
INSERT INTO sql_example_expectation VALUES ('JN10','JOIN_NULL','J.USING과 NULL 키',1,5,NULL,'ORACLE','USING(sales_region)도 JN01A와 동일 5행, NULL 키 배제는 동일');
INSERT INTO sql_example_expectation VALUES ('JN11A','JOIN_NULL','K.비등가조인(BETWEEN) INNER - 경계값 포함',1,5,NULL,'ORACLE','C1(0),C2(300),C3(301),C6(1000),C7(1001) 매칭, C4(범위밖)/C5(NULL) 제외');
INSERT INTO sql_example_expectation VALUES ('JN11B','JOIN_NULL','K.비등가조인(BETWEEN) LEFT - 미매칭 보존',1,7,NULL,'ORACLE','7명 전원 보존, C4/C5는 band 열이 NULL로 채워짐');
INSERT INTO sql_example_expectation VALUES ('JN12','JOIN_NULL','L.복합 조인키 일부/양쪽 NULL - INNER',1,1,NULL,'ORACLE','O1-E1만 두 열 모두 일치, 나머지는 한쪽 또는 양쪽 NULL이라 매칭안됨');
INSERT INTO sql_example_expectation VALUES ('JN12B','JOIN_NULL','L.복합 조인키 - LEFT 보존',1,8,NULL,'ORACLE','주문 8건 전부 보존, O1만 이벤트와 매칭되고 나머지 7건은 이벤트열 NULL');
INSERT INTO sql_example_expectation VALUES ('JN13','JOIN_NULL','M.CROSS JOIN 대조(등가조인과 달리 NULL과 무관)',1,28,NULL,'ORACLE','7x4=28, JN01A(5행)와 대조 - 등가조인만 NULL 키를 제외한다');
INSERT INTO sql_example_expectation VALUES ('JN14','JOIN_NULL','N.Oracle (+) - 반대편 필터에 (+) 누락시 무력화',1,2,NULL,'ORACLE','JN03B와 동일 메커니즘·동일 결과(2행), (+) 있어도 후속 AND조건이 UNKNOWN 행을 지움');

COMMIT;
