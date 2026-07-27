-- NULL 실습 데이터 준비 (SQL Server)
-- 대상: 깨우침/NULL 정리.md
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- Oracle/01_prepare.sql과 같은 example_id·같은 기대값을 쓰되, 문법은 SQL
-- Server 방언으로 옮겼다. customer_id 값은 모두 저장소 루트
-- olist_customers_dataset.csv에서 실제로 뽑은 값이다(자세한 설명은
-- Oracle/01_prepare.sql 상단 주석과 README 참고). 예외는 딱 하나 -
-- CUSTOMER_CODE: SQL Server는 UNIQUE 컬럼에 NULL을 1개만 허용하므로(Oracle은
-- 여러 개 허용) 이 테이블만 행 구성이 다르다(N35 참고, DBMS 차이 그 자체가
-- 학습 대상).

IF OBJECT_ID('sql_example_validation', 'U') IS NOT NULL DROP TABLE sql_example_validation;
IF OBJECT_ID('sql_example_result', 'U') IS NOT NULL DROP TABLE sql_example_result;
IF OBJECT_ID('sql_example_expectation', 'U') IS NOT NULL DROP TABLE sql_example_expectation;

IF OBJECT_ID('customer_order_summary', 'U') IS NOT NULL DROP TABLE customer_order_summary;
IF OBJECT_ID('customer_order_summary_zero', 'U') IS NOT NULL DROP TABLE customer_order_summary_zero;
IF OBJECT_ID('customer_order_summary_dup', 'U') IS NOT NULL DROP TABLE customer_order_summary_dup;
IF OBJECT_ID('customer_note', 'U') IS NOT NULL DROP TABLE customer_note;
IF OBJECT_ID('customer_left', 'U') IS NOT NULL DROP TABLE customer_left;
IF OBJECT_ID('customer_right_order', 'U') IS NOT NULL DROP TABLE customer_right_order;
IF OBJECT_ID('customer_region', 'U') IS NOT NULL DROP TABLE customer_region;
IF OBJECT_ID('customer_val', 'U') IS NOT NULL DROP TABLE customer_val;
IF OBJECT_ID('customer_orderval', 'U') IS NOT NULL DROP TABLE customer_orderval;
IF OBJECT_ID('customer_code', 'U') IS NOT NULL DROP TABLE customer_code;
IF OBJECT_ID('customer_meta', 'U') IS NOT NULL DROP TABLE customer_meta;
IF OBJECT_ID('customer_membership', 'U') IS NOT NULL DROP TABLE customer_membership;
IF OBJECT_ID('membership_tier', 'U') IS NOT NULL DROP TABLE membership_tier;
IF OBJECT_ID('customer_flag_check', 'U') IS NOT NULL DROP TABLE customer_flag_check;
IF OBJECT_ID('customer_flag_exclude', 'U') IS NOT NULL DROP TABLE customer_flag_exclude;

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
-- 예제 데이터 (Oracle/01_prepare.sql과 값 동일, CUSTOMER_CODE만 예외)
-- =====================================================================

CREATE TABLE customer_order_summary (
    customer_id  VARCHAR(32) PRIMARY KEY,
    total_spent   INT
);
INSERT INTO customer_order_summary VALUES ('000598caf2ef4117407665ac33275130', 10);
INSERT INTO customer_order_summary VALUES ('00104a47c29da701ce41ee52077587d9', NULL);
INSERT INTO customer_order_summary VALUES ('002450e9ea44cb90b8a07ba0b197e149', 20);

CREATE TABLE customer_order_summary_zero (
    customer_id  VARCHAR(32) PRIMARY KEY,
    total_spent   INT
);
INSERT INTO customer_order_summary_zero VALUES ('002905287304e28c0218389269b4759b', 10);
INSERT INTO customer_order_summary_zero VALUES ('002ef7e55600d44ead53f7c1644e5222', 20);
INSERT INTO customer_order_summary_zero VALUES ('00411811e3b661e746a6e1ce1f0878ab', 0);

CREATE TABLE customer_order_summary_dup (
    customer_id  VARCHAR(32) PRIMARY KEY,
    total_spent   INT
);
INSERT INTO customer_order_summary_dup VALUES ('0041d7b768cb115092fa0f5d55638d06', 10);
INSERT INTO customer_order_summary_dup VALUES ('00498d14e21c58ed2feb5d5feb4cd706', 10);
INSERT INTO customer_order_summary_dup VALUES ('0050b4dd994efa94b2cd3210e4cecf32', NULL);
INSERT INTO customer_order_summary_dup VALUES ('0058ebe2dc136d918dd001968cfa5903', 20);

-- CUSTOMER_NOTE : SQL Server는 ''와 NULL을 구분한다(Oracle과의 핵심 차이, N01,N02).
CREATE TABLE customer_note (
    customer_id  VARCHAR(32) PRIMARY KEY,
    note_text     VARCHAR(20)
);
INSERT INTO customer_note VALUES ('00072d033fe2e59061ae5c3aff1a2be5', 'VIP GOOD');
INSERT INTO customer_note VALUES ('002937abdae13680e17dccd3868b4825', NULL);
INSERT INTO customer_note VALUES ('003cb2c7ce25d8af8556fb456f903546', '');   -- SQL Server: 진짜 빈 문자열, NULL 아님
INSERT INTO customer_note VALUES ('0055e9b290953716739bd94a256a4144', ' '); -- 공백 1글자

CREATE TABLE customer_left (
    customer_id VARCHAR(32) PRIMARY KEY
);
INSERT INTO customer_left VALUES ('0056a2580b5c68cfa6b43c6ef6adbc03');
INSERT INTO customer_left VALUES ('00581d55862aecc8cbc7d701a27bc285');
INSERT INTO customer_left VALUES ('007e99fec9d53dfa4e5d8be9c2b36ca7'); -- 주문 없음(미매칭)

CREATE TABLE customer_right_order (
    customer_id VARCHAR(32) PRIMARY KEY
);
INSERT INTO customer_right_order VALUES ('0056a2580b5c68cfa6b43c6ef6adbc03');
INSERT INTO customer_right_order VALUES ('00581d55862aecc8cbc7d701a27bc285');

CREATE TABLE customer_region (
    customer_id VARCHAR(32) PRIMARY KEY,
    region       VARCHAR(20)
);
INSERT INTO customer_region VALUES ('0086b541a59fa554e7953e2d3c285285', N'Nordeste');
INSERT INTO customer_region VALUES ('009c99241ad4ac86427982c474c18771', NULL);
INSERT INTO customer_region VALUES ('00c6436d2afd5923cba3f19f9542b140', NULL);

CREATE TABLE customer_val (
    customer_id VARCHAR(32) PRIMARY KEY,
    val          INT
);
INSERT INTO customer_val VALUES ('00f83de98e791c2a4b779f7e61a4cf28', 1);
INSERT INTO customer_val VALUES ('012e0c27bbc549e7c249ee9042d58f7b', 1);
INSERT INTO customer_val VALUES ('0017a0b4c1f1bdb9c395fa0ac517109c', NULL);
INSERT INTO customer_val VALUES ('002f067b028a3643ad3a0969c7a0f3dc', NULL);

CREATE TABLE customer_orderval (
    customer_id VARCHAR(32) PRIMARY KEY,
    val          INT
);
INSERT INTO customer_orderval VALUES ('002ff70a5285669011090c077ef929af', 10);
INSERT INTO customer_orderval VALUES ('0031abfb953b66e998f67b09e7b11375', NULL);
INSERT INTO customer_orderval VALUES ('00380c010de38d578d02117f6d0b88e7', 5);

-- CUSTOMER_CODE : SQL Server는 UNIQUE 컬럼에 NULL을 1개만 허용한다.
-- *** DBMS 차이(N35): 아래에서 두 번째 NULL 행을 추가로 INSERT하면
--   "Cannot insert duplicate key row..." 오류가 난다(Oracle이라면 성공했을
--   삽입). 스크립트가 항상 오류 없이 재실행되도록 SQL Server 버전은 NULL을
--   1개만 넣어 2행으로 마친다 - Oracle 버전(3행)과의 행 수 차이 자체가
--   "UNIQUE는 Oracle에서 NULL을 허용한다"는 필기 개념의 실제 증거다. ***
CREATE TABLE customer_code (
    customer_id VARCHAR(32) PRIMARY KEY,
    code         VARCHAR(10) UNIQUE
);
INSERT INTO customer_code VALUES ('003a75d228dc67cb2918e40c2aacc4bf', 'A');
INSERT INTO customer_code VALUES ('0042d04ee8231b36dcb29aac213f5db4', NULL);
-- INSERT INTO customer_code VALUES ('00447b6bd39c4a0f6366b05948f9e2e3', NULL); -- 실행하지 않음: 2번째 NULL은 UNIQUE 위반

CREATE TABLE customer_meta (
    customer_id VARCHAR(32) PRIMARY KEY,
    req_val      INT NOT NULL
);
INSERT INTO customer_meta VALUES ('00474d2582fd72663036795b7ab8cfc1', 100);
INSERT INTO customer_meta VALUES ('0063bdf3bf91260f76973a4af6f9199e', 200);

CREATE TABLE membership_tier (
    tier_id INT PRIMARY KEY
);
INSERT INTO membership_tier VALUES (1);
INSERT INTO membership_tier VALUES (2);

CREATE TABLE customer_membership (
    customer_id  VARCHAR(32) PRIMARY KEY,
    tier_id       INT REFERENCES membership_tier(tier_id)
);
INSERT INTO customer_membership VALUES ('00652f7a6e012d58f58fefd69d1a1ea4', 1);
INSERT INTO customer_membership VALUES ('006e35001c6c8c65ad4b20a8925d2b9f', NULL); -- 등급 미배정(선택적 관계)

CREATE TABLE customer_flag_check (
    customer_id VARCHAR(32) PRIMARY KEY,
    flag_val     INT
);
INSERT INTO customer_flag_check VALUES ('00066ccbe787a588c52bd5ff404590e3', 1);
INSERT INTO customer_flag_check VALUES ('000e943451fc2788ca6ac98a682f2f49', 2);
INSERT INTO customer_flag_check VALUES ('000f17e290c26b28549908a04cfe36c1', 3);

CREATE TABLE customer_flag_exclude (
    customer_id VARCHAR(32) PRIMARY KEY,
    flag_val     INT
);
INSERT INTO customer_flag_exclude VALUES ('00066ccbe787a588c52bd5ff404590e3', 1);
INSERT INTO customer_flag_exclude VALUES ('000f17e290c26b28549908a04cfe36c1', 3);
INSERT INTO customer_flag_exclude VALUES ('001226b2341ef620415ce7bbafcfac28', NULL);

-- =====================================================================
-- 기대 결과표 적재 (../../_common/expected_results.csv topic=NULL dbms=SQLSERVER 과 동일)
-- =====================================================================
INSERT INTO sql_example_expectation VALUES ('N01','NULL','NULL/0/공백/빈 문자열',1,1,NULL,'SQLSERVER','CUSTOMER_NOTE IS NULL count: SQL Server는 NULL만 세어 1건');
INSERT INTO sql_example_expectation VALUES ('N02','NULL','SQL Server 빈 문자열과 NULL',1,1,NULL,'SQLSERVER','NOTE_TEXT='''' 비교: 진짜 빈 문자열이라 1건');
INSERT INTO sql_example_expectation VALUES ('N03','NULL','공백 문자열 길이(LEN)',1,0,NULL,'SQLSERVER','LEN('' '')=0 뒤쪽 공백 제거');
INSERT INTO sql_example_expectation VALUES ('N03B','NULL','공백 문자열 길이(DATALENGTH)',1,1,NULL,'SQLSERVER','DATALENGTH('' '')=1 실제 바이트 유지');
INSERT INTO sql_example_expectation VALUES ('N04','NULL','= NULL',1,0,NULL,'SQLSERVER','항상 UNKNOWN이라 0건');
INSERT INTO sql_example_expectation VALUES ('N05','NULL','<> NULL',1,0,NULL,'SQLSERVER','항상 UNKNOWN이라 0건');
INSERT INTO sql_example_expectation VALUES ('N06','NULL','IS NULL',1,1,NULL,'SQLSERVER','2행만 해당');
INSERT INTO sql_example_expectation VALUES ('N07','NULL','IS NOT NULL',1,2,NULL,'SQLSERVER','1,3행 해당');
INSERT INTO sql_example_expectation VALUES ('N08','NULL','TRUE/FALSE/UNKNOWN(TRUE)',1,1,NULL,'SQLSERVER','1=1 TRUE');
INSERT INTO sql_example_expectation VALUES ('N08B','NULL','TRUE/FALSE/UNKNOWN(FALSE)',1,0,NULL,'SQLSERVER','1=2 FALSE');
INSERT INTO sql_example_expectation VALUES ('N08C','NULL','TRUE/FALSE/UNKNOWN(UNKNOWN)',1,0,NULL,'SQLSERVER','NULL=NULL UNKNOWN');
INSERT INTO sql_example_expectation VALUES ('N09','NULL','LIKE와 NULL',1,1,NULL,'SQLSERVER','''VIP GOOD'' 1건만 매칭');
INSERT INTO sql_example_expectation VALUES ('N10','NULL','산술 연산 NULL 전파',1,1,NULL,'SQLSERVER','TOTAL_SPENT+10 WHERE 2행 -> NULL 플래그');
INSERT INTO sql_example_expectation VALUES ('N11','NULL','COUNT(*)',1,3,NULL,'SQLSERVER','행 3개 전부');
INSERT INTO sql_example_expectation VALUES ('N12','NULL','COUNT(열)',1,2,NULL,'SQLSERVER','NULL 제외 2건');
INSERT INTO sql_example_expectation VALUES ('N13','NULL','COUNT(DISTINCT 열)',1,2,NULL,'SQLSERVER','10,20 고유값');
INSERT INTO sql_example_expectation VALUES ('N14','NULL','SUM',1,30,NULL,'SQLSERVER','10+20');
INSERT INTO sql_example_expectation VALUES ('N15','NULL','AVG',1,15,NULL,'SQLSERVER','30/2');
INSERT INTO sql_example_expectation VALUES ('N16','NULL','MIN',1,10,NULL,'SQLSERVER','최솟값');
INSERT INTO sql_example_expectation VALUES ('N17','NULL','MAX',1,20,NULL,'SQLSERVER','최댓값');
INSERT INTO sql_example_expectation VALUES ('N18','NULL','NULL과 0의 평균 차이',1,10,NULL,'SQLSERVER','CUSTOMER_ORDER_SUMMARY_ZERO AVG=10, N15(15)와 대조');
INSERT INTO sql_example_expectation VALUES ('N19','NULL','0행 집계 결과',1,0,NULL,'SQLSERVER','조건 0행이지만 집계는 1행 반환');
INSERT INTO sql_example_expectation VALUES ('N20','NULL','IN과 NULL(TRUE)',1,1,NULL,'SQLSERVER','1 IN (1,NULL) TRUE');
INSERT INTO sql_example_expectation VALUES ('N20B','NULL','IN과 NULL(FALSE)',1,0,NULL,'SQLSERVER','2 IN (1,3) FALSE');
INSERT INTO sql_example_expectation VALUES ('N20C','NULL','IN과 NULL(UNKNOWN)',1,0,NULL,'SQLSERVER','2 IN (1,NULL) UNKNOWN');
INSERT INTO sql_example_expectation VALUES ('N21','NULL','NOT IN과 NULL(FALSE)',1,0,NULL,'SQLSERVER','1 NOT IN (1,NULL) FALSE');
INSERT INTO sql_example_expectation VALUES ('N21B','NULL','NOT IN과 NULL(UNKNOWN)',1,0,NULL,'SQLSERVER','2 NOT IN (1,NULL) UNKNOWN');
INSERT INTO sql_example_expectation VALUES ('N21C','NULL','NOT IN과 NULL(TRUE)',1,1,NULL,'SQLSERVER','2 NOT IN (1,3) TRUE');
INSERT INTO sql_example_expectation VALUES ('N22','NULL','서브쿼리 NOT IN과 NULL',0,NULL,NULL,'SQLSERVER','서브쿼리에 NULL 있어 전체 0행');
INSERT INTO sql_example_expectation VALUES ('N23','NULL','COALESCE',1,-1,NULL,'SQLSERVER','COALESCE(TOTAL_SPENT,-1) WHERE 2행 -> -1');
INSERT INTO sql_example_expectation VALUES ('N24','NULL','NVL 대응(ISNULL)',1,-1,NULL,'SQLSERVER','NVL 없음, ISNULL(TOTAL_SPENT,-1)로 대체');
INSERT INTO sql_example_expectation VALUES ('N25','NULL','ISNULL',1,-1,NULL,'SQLSERVER','ISNULL(TOTAL_SPENT,-1)=-1');
INSERT INTO sql_example_expectation VALUES ('N26','NULL','NULLIF(같은 값)',1,1,NULL,'SQLSERVER','NULLIF(10,10) IS NULL 플래그');
INSERT INTO sql_example_expectation VALUES ('N26B','NULL','NULLIF(다른 값)',1,10,NULL,'SQLSERVER','NULLIF(10,20)=10');
INSERT INTO sql_example_expectation VALUES ('N27','NULL','0 나누기 방지(분모 0)',1,1,NULL,'SQLSERVER','100/NULLIF(0,0) IS NULL 플래그');
INSERT INTO sql_example_expectation VALUES ('N27B','NULL','0 나누기 방지(분모 정상)',1,20,NULL,'SQLSERVER','100/NULLIF(5,0)=20');
INSERT INTO sql_example_expectation VALUES ('N28','NULL','OUTER JOIN으로 생성된 NULL',1,1,NULL,'SQLSERVER','WHERE r.customer_id IS NULL -> 미매칭 고객 1건');
INSERT INTO sql_example_expectation VALUES ('N29','NULL','OUTER JOIN 이후 COUNT 차이',3,2,NULL,'SQLSERVER','COUNT(*)=3, COUNT(r.customer_id)=2');
INSERT INTO sql_example_expectation VALUES ('N30','NULL','GROUP BY의 NULL(그룹 수)',1,2,NULL,'SQLSERVER','Nordeste,NULL 2그룹');
INSERT INTO sql_example_expectation VALUES ('N30B','NULL','GROUP BY의 NULL(NULL 그룹 크기)',1,2,NULL,'SQLSERVER','REGION IS NULL 2건');
INSERT INTO sql_example_expectation VALUES ('N31','NULL','DISTINCT의 NULL',1,2,NULL,'SQLSERVER','{1,NULL} 2건');
INSERT INTO sql_example_expectation VALUES ('N32','NULL','ORDER BY의 NULL 위치(ASC)',1,1,NULL,'SQLSERVER','ASC 기본 NULL 처음 -> 1번째');
INSERT INTO sql_example_expectation VALUES ('N32B','NULL','ORDER BY의 NULL 위치(DESC)',1,3,NULL,'SQLSERVER','DESC 기본 NULL 마지막 -> 3번째');
INSERT INTO sql_example_expectation VALUES ('N33','NULL','PRIMARY KEY',1,1,NULL,'SQLSERVER','PK 제약 존재 확인 1건');
INSERT INTO sql_example_expectation VALUES ('N34','NULL','NOT NULL',1,1,NULL,'SQLSERVER','NOT NULL 제약 존재 확인 1건');
INSERT INTO sql_example_expectation VALUES ('N35','NULL','UNIQUE',2,NULL,NULL,'SQLSERVER','NULL 1개만 허용되어 2행');
INSERT INTO sql_example_expectation VALUES ('N36','NULL','FOREIGN KEY와 NULL',1,1,NULL,'SQLSERVER','FK NULL 자식행 1건');
