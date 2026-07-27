-- NULL 실습 데이터 준비 (Oracle)
-- 대상: 깨우침/NULL 정리.md
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- 데이터 원칙: 모든 customer_id 값은 저장소 루트의 olist_customers_dataset.csv
-- (99,441행)에서 실제로 뽑은 값이다. 다만 이 CSV는 5개 열 전체에서 결측치가
-- 0건이다(Olist-고객데이터/00-데이터사전에서 이미 확인됨, 이 세션에서도 전체
-- 스캔으로 재확인했다) - 즉 NULL 실습에 쓸 결측값이 원본에는 없다. 그래서
-- 아래 테이블들은 분석기법/22-KNN결측값대체 모듈과 같은 원칙으로: 실제
-- customer_id를 기본키로 그대로 쓰되, 그 위에 얹는 속성(total_spent, note_text,
-- region 등)은 이 실습을 위해 새로 만든 값이고 그 안에 의도적으로 NULL을
-- 넣는다. customer_id 자체는 지어낸 것이 아니라 실제 CSV의 값이다.
--
-- 최초 실행 시 아래 DROP 구문들이 ORA-00942(테이블/뷰 없음)를 낼 수 있다.
-- 이는 정상이며 무시하고 계속 진행하면 된다.

DROP TABLE sql_example_validation;
DROP TABLE sql_example_result;
DROP TABLE sql_example_expectation;

DROP TABLE customer_order_summary;
DROP TABLE customer_order_summary_zero;
DROP TABLE customer_order_summary_dup;
DROP TABLE customer_note;
DROP TABLE customer_left;
DROP TABLE customer_right_order;
DROP TABLE customer_region;
DROP TABLE customer_val;
DROP TABLE customer_orderval;
DROP TABLE customer_code;
DROP TABLE customer_meta;
DROP TABLE customer_membership;
DROP TABLE membership_tier;
DROP TABLE customer_flag_check;
DROP TABLE customer_flag_exclude;

-- =====================================================================
-- 검증 테이블 3종
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
-- 예제 데이터 (customer_id는 olist_customers_dataset.csv 실제 값,
-- total_spent/note_text 등 부가 속성은 NULL 실습을 위해 새로 부여한 값)
-- =====================================================================

-- CUSTOMER_ORDER_SUMMARY : 집계 함수 NULL 처리 기본 예제(N11~N17).
-- NULL 정리.md 12절의 예시 표(ID1=10, ID2=NULL, ID3=20)를 실제 고객 3명에게 옮겼다.
CREATE TABLE customer_order_summary (
    customer_id  VARCHAR2(32) PRIMARY KEY,
    total_spent   NUMBER
);
INSERT INTO customer_order_summary VALUES ('000598caf2ef4117407665ac33275130', 10);
INSERT INTO customer_order_summary VALUES ('00104a47c29da701ce41ee52077587d9', NULL);
INSERT INTO customer_order_summary VALUES ('002450e9ea44cb90b8a07ba0b197e149', 20);

-- CUSTOMER_ORDER_SUMMARY_ZERO : NULL과 0의 평균 차이 대조군(N18). NULL 정리.md 13절 예시.
CREATE TABLE customer_order_summary_zero (
    customer_id  VARCHAR2(32) PRIMARY KEY,
    total_spent   NUMBER
);
INSERT INTO customer_order_summary_zero VALUES ('002905287304e28c0218389269b4759b', 10);
INSERT INTO customer_order_summary_zero VALUES ('002ef7e55600d44ead53f7c1644e5222', 20);
INSERT INTO customer_order_summary_zero VALUES ('00411811e3b661e746a6e1ce1f0878ab', 0);

-- CUSTOMER_ORDER_SUMMARY_DUP : COUNT(DISTINCT 열) 전용(N13). 10이 두 번
-- 나오게 해 COUNT(열)과 COUNT(DISTINCT 열)이 실제로 다른 값을 내도록 설계.
CREATE TABLE customer_order_summary_dup (
    customer_id  VARCHAR2(32) PRIMARY KEY,
    total_spent   NUMBER
);
INSERT INTO customer_order_summary_dup VALUES ('0041d7b768cb115092fa0f5d55638d06', 10);
INSERT INTO customer_order_summary_dup VALUES ('00498d14e21c58ed2feb5d5feb4cd706', 10);
INSERT INTO customer_order_summary_dup VALUES ('0050b4dd994efa94b2cd3210e4cecf32', NULL);
INSERT INTO customer_order_summary_dup VALUES ('0058ebe2dc136d918dd001968cfa5903', 20);

-- CUSTOMER_NOTE : NULL/빈 문자열/공백 구분(N01~N03B, N09).
-- *** Oracle 고유 함정: 세 번째 행에 ''(빈 문자열)을 넣는 INSERT는 Oracle에서
-- 그 값을 NULL로 저장한다(Oracle은 ''와 NULL을 구분하지 않는다). 네 번째 행의
-- ' '(공백 1글자)는 실제 문자가 있으므로 NULL이 되지 않는다. ***
CREATE TABLE customer_note (
    customer_id  VARCHAR2(32) PRIMARY KEY,
    note_text     VARCHAR2(20)
);
INSERT INTO customer_note VALUES ('00072d033fe2e59061ae5c3aff1a2be5', 'VIP GOOD');
INSERT INTO customer_note VALUES ('002937abdae13680e17dccd3868b4825', NULL);
INSERT INTO customer_note VALUES ('003cb2c7ce25d8af8556fb456f903546', '');   -- Oracle: 저장되는 순간 NULL이 됨
INSERT INTO customer_note VALUES ('0055e9b290953716739bd94a256a4144', ' '); -- 공백 1글자, NULL 아님

-- CUSTOMER_LEFT / CUSTOMER_RIGHT_ORDER : OUTER JOIN이 만드는 NULL, COUNT(*)
-- vs COUNT(우측열) 차이(N28, N29). NULL 정리.md 16절 예시(A 3행, 매칭 2행,
-- 미매칭 1행) 그대로, 실제 고객 3명으로 재현.
CREATE TABLE customer_left (
    customer_id VARCHAR2(32) PRIMARY KEY
);
INSERT INTO customer_left VALUES ('0056a2580b5c68cfa6b43c6ef6adbc03');
INSERT INTO customer_left VALUES ('00581d55862aecc8cbc7d701a27bc285');
INSERT INTO customer_left VALUES ('007e99fec9d53dfa4e5d8be9c2b36ca7'); -- 주문 없음(미매칭)

CREATE TABLE customer_right_order (
    customer_id VARCHAR2(32) PRIMARY KEY
);
INSERT INTO customer_right_order VALUES ('0056a2580b5c68cfa6b43c6ef6adbc03');
INSERT INTO customer_right_order VALUES ('00581d55862aecc8cbc7d701a27bc285');

-- CUSTOMER_REGION : GROUP BY의 NULL(N30, N30B). NULL 정리.md 17절 예시
-- 그대로(지역 1건, NULL 2건) - 지역 미기재 고객 2명을 실제 값으로 재현.
CREATE TABLE customer_region (
    customer_id VARCHAR2(32) PRIMARY KEY,
    region       VARCHAR2(20)
);
INSERT INTO customer_region VALUES ('0086b541a59fa554e7953e2d3c285285', 'Nordeste');
INSERT INTO customer_region VALUES ('009c99241ad4ac86427982c474c18771', NULL);
INSERT INTO customer_region VALUES ('00c6436d2afd5923cba3f19f9542b140', NULL);

-- CUSTOMER_VAL : DISTINCT의 NULL(N31). NULL 정리.md 18절 예시 그대로(1,1,NULL,NULL).
CREATE TABLE customer_val (
    customer_id VARCHAR2(32) PRIMARY KEY,
    val          NUMBER
);
INSERT INTO customer_val VALUES ('00f83de98e791c2a4b779f7e61a4cf28', 1);
INSERT INTO customer_val VALUES ('012e0c27bbc549e7c249ee9042d58f7b', 1);
INSERT INTO customer_val VALUES ('0017a0b4c1f1bdb9c395fa0ac517109c', NULL);
INSERT INTO customer_val VALUES ('002f067b028a3643ad3a0969c7a0f3dc', NULL);

-- CUSTOMER_ORDERVAL : ORDER BY의 NULL 위치(N32, N32B).
CREATE TABLE customer_orderval (
    customer_id VARCHAR2(32) PRIMARY KEY,
    val          NUMBER
);
INSERT INTO customer_orderval VALUES ('002ff70a5285669011090c077ef929af', 10);
INSERT INTO customer_orderval VALUES ('0031abfb953b66e998f67b09e7b11375', NULL);
INSERT INTO customer_orderval VALUES ('00380c010de38d578d02117f6d0b88e7', 5);

-- CUSTOMER_CODE : UNIQUE 제약과 NULL(N35).
-- Oracle은 UNIQUE 컬럼에 NULL을 여러 개 허용한다(NULL<>NULL이므로 유일성
-- 위반이 아니다) - 그래서 NULL 2개를 넣어도 성공하며 3행이 남는다.
CREATE TABLE customer_code (
    customer_id VARCHAR2(32) PRIMARY KEY,
    code         VARCHAR2(10) UNIQUE
);
INSERT INTO customer_code VALUES ('003a75d228dc67cb2918e40c2aacc4bf', 'A');
INSERT INTO customer_code VALUES ('0042d04ee8231b36dcb29aac213f5db4', NULL);
INSERT INTO customer_code VALUES ('00447b6bd39c4a0f6366b05948f9e2e3', NULL); -- Oracle에서는 성공(SQL Server라면 위반)

-- CUSTOMER_META : PRIMARY KEY / NOT NULL 제약 메타데이터 확인용(N33, N34).
CREATE TABLE customer_meta (
    customer_id VARCHAR2(32) PRIMARY KEY,
    req_val      NUMBER NOT NULL
);
INSERT INTO customer_meta VALUES ('00474d2582fd72663036795b7ab8cfc1', 100);
INSERT INTO customer_meta VALUES ('0063bdf3bf91260f76973a4af6f9199e', 200);

-- MEMBERSHIP_TIER / CUSTOMER_MEMBERSHIP : FOREIGN KEY와 NULL(N36) - 선택적
-- 관계는 NULL 허용. 등급을 아직 배정받지 못한 실제 고객은 tier_id가 NULL이다.
CREATE TABLE membership_tier (
    tier_id NUMBER PRIMARY KEY
);
INSERT INTO membership_tier VALUES (1);
INSERT INTO membership_tier VALUES (2);

CREATE TABLE customer_membership (
    customer_id  VARCHAR2(32) PRIMARY KEY,
    tier_id       NUMBER REFERENCES membership_tier(tier_id)
);
INSERT INTO customer_membership VALUES ('00652f7a6e012d58f58fefd69d1a1ea4', 1);
INSERT INTO customer_membership VALUES ('006e35001c6c8c65ad4b20a8925d2b9f', NULL); -- 등급 미배정(선택적 관계)

-- CUSTOMER_FLAG_CHECK / CUSTOMER_FLAG_EXCLUDE : 서브쿼리 NOT IN과 NULL의 함정(N22).
CREATE TABLE customer_flag_check (
    customer_id VARCHAR2(32) PRIMARY KEY,
    flag_val     NUMBER
);
INSERT INTO customer_flag_check VALUES ('00066ccbe787a588c52bd5ff404590e3', 1);
INSERT INTO customer_flag_check VALUES ('000e943451fc2788ca6ac98a682f2f49', 2);
INSERT INTO customer_flag_check VALUES ('000f17e290c26b28549908a04cfe36c1', 3);

CREATE TABLE customer_flag_exclude (
    customer_id VARCHAR2(32) PRIMARY KEY,
    flag_val     NUMBER
);
INSERT INTO customer_flag_exclude VALUES ('00066ccbe787a588c52bd5ff404590e3', 1);
INSERT INTO customer_flag_exclude VALUES ('000f17e290c26b28549908a04cfe36c1', 3);
INSERT INTO customer_flag_exclude VALUES ('001226b2341ef620415ce7bbafcfac28', NULL);

COMMIT;

-- =====================================================================
-- 기대 결과표 적재 (../../_common/expected_results.csv topic=NULL dbms=ORACLE 과 동일)
-- =====================================================================
INSERT INTO sql_example_expectation VALUES ('N01','NULL','NULL/0/공백/빈 문자열',1,2,NULL,'ORACLE','CUSTOMER_NOTE IS NULL count: Oracle은 2,3행 합쳐 2건');
INSERT INTO sql_example_expectation VALUES ('N02','NULL','Oracle 빈 문자열과 NULL',1,0,NULL,'ORACLE','NOTE_TEXT='''' 비교: 컬럼이 이미 NULL이라 0건');
INSERT INTO sql_example_expectation VALUES ('N03','NULL','공백 문자열 길이(LENGTH)',1,1,NULL,'ORACLE','LENGTH('' '')=1');
INSERT INTO sql_example_expectation VALUES ('N03B','NULL','공백 문자열 길이(Oracle 구분없음)',1,1,NULL,'ORACLE','DATALENGTH 개념 없음, LENGTH로 통일');
INSERT INTO sql_example_expectation VALUES ('N04','NULL','= NULL',1,0,NULL,'ORACLE','항상 UNKNOWN이라 0건');
INSERT INTO sql_example_expectation VALUES ('N05','NULL','<> NULL',1,0,NULL,'ORACLE','항상 UNKNOWN이라 0건');
INSERT INTO sql_example_expectation VALUES ('N06','NULL','IS NULL',1,1,NULL,'ORACLE','2행만 해당');
INSERT INTO sql_example_expectation VALUES ('N07','NULL','IS NOT NULL',1,2,NULL,'ORACLE','1,3행 해당');
INSERT INTO sql_example_expectation VALUES ('N08','NULL','TRUE/FALSE/UNKNOWN(TRUE)',1,1,NULL,'ORACLE','1=1 TRUE');
INSERT INTO sql_example_expectation VALUES ('N08B','NULL','TRUE/FALSE/UNKNOWN(FALSE)',1,0,NULL,'ORACLE','1=2 FALSE');
INSERT INTO sql_example_expectation VALUES ('N08C','NULL','TRUE/FALSE/UNKNOWN(UNKNOWN)',1,0,NULL,'ORACLE','NULL=NULL UNKNOWN');
INSERT INTO sql_example_expectation VALUES ('N09','NULL','LIKE와 NULL',1,1,NULL,'ORACLE','''VIP GOOD'' 1건만 매칭');
INSERT INTO sql_example_expectation VALUES ('N10','NULL','산술 연산 NULL 전파',1,1,NULL,'ORACLE','TOTAL_SPENT+10 WHERE 2행 -> NULL 플래그');
INSERT INTO sql_example_expectation VALUES ('N11','NULL','COUNT(*)',1,3,NULL,'ORACLE','행 3개 전부');
INSERT INTO sql_example_expectation VALUES ('N12','NULL','COUNT(열)',1,2,NULL,'ORACLE','NULL 제외 2건');
INSERT INTO sql_example_expectation VALUES ('N13','NULL','COUNT(DISTINCT 열)',1,2,NULL,'ORACLE','10,20 고유값');
INSERT INTO sql_example_expectation VALUES ('N14','NULL','SUM',1,30,NULL,'ORACLE','10+20');
INSERT INTO sql_example_expectation VALUES ('N15','NULL','AVG',1,15,NULL,'ORACLE','30/2');
INSERT INTO sql_example_expectation VALUES ('N16','NULL','MIN',1,10,NULL,'ORACLE','최솟값');
INSERT INTO sql_example_expectation VALUES ('N17','NULL','MAX',1,20,NULL,'ORACLE','최댓값');
INSERT INTO sql_example_expectation VALUES ('N18','NULL','NULL과 0의 평균 차이',1,10,NULL,'ORACLE','CUSTOMER_ORDER_SUMMARY_ZERO AVG=10, N15(15)와 대조');
INSERT INTO sql_example_expectation VALUES ('N19','NULL','0행 집계 결과',1,0,NULL,'ORACLE','조건 0행이지만 집계는 1행 반환');
INSERT INTO sql_example_expectation VALUES ('N20','NULL','IN과 NULL(TRUE)',1,1,NULL,'ORACLE','1 IN (1,NULL) TRUE');
INSERT INTO sql_example_expectation VALUES ('N20B','NULL','IN과 NULL(FALSE)',1,0,NULL,'ORACLE','2 IN (1,3) FALSE');
INSERT INTO sql_example_expectation VALUES ('N20C','NULL','IN과 NULL(UNKNOWN)',1,0,NULL,'ORACLE','2 IN (1,NULL) UNKNOWN');
INSERT INTO sql_example_expectation VALUES ('N21','NULL','NOT IN과 NULL(FALSE)',1,0,NULL,'ORACLE','1 NOT IN (1,NULL) FALSE');
INSERT INTO sql_example_expectation VALUES ('N21B','NULL','NOT IN과 NULL(UNKNOWN)',1,0,NULL,'ORACLE','2 NOT IN (1,NULL) UNKNOWN');
INSERT INTO sql_example_expectation VALUES ('N21C','NULL','NOT IN과 NULL(TRUE)',1,1,NULL,'ORACLE','2 NOT IN (1,3) TRUE');
INSERT INTO sql_example_expectation VALUES ('N22','NULL','서브쿼리 NOT IN과 NULL',0,NULL,NULL,'ORACLE','서브쿼리에 NULL 있어 전체 0행');
INSERT INTO sql_example_expectation VALUES ('N23','NULL','COALESCE',1,-1,NULL,'ORACLE','COALESCE(TOTAL_SPENT,-1) WHERE 2행 -> -1');
INSERT INTO sql_example_expectation VALUES ('N24','NULL','NVL',1,-1,NULL,'ORACLE','NVL(TOTAL_SPENT,-1)=-1');
INSERT INTO sql_example_expectation VALUES ('N25','NULL','ISNULL 대응(NVL)',1,-1,NULL,'ORACLE','Oracle에는 ISNULL 없음, NVL로 대체');
INSERT INTO sql_example_expectation VALUES ('N26','NULL','NULLIF(같은 값)',1,1,NULL,'ORACLE','NULLIF(10,10) IS NULL 플래그');
INSERT INTO sql_example_expectation VALUES ('N26B','NULL','NULLIF(다른 값)',1,10,NULL,'ORACLE','NULLIF(10,20)=10');
INSERT INTO sql_example_expectation VALUES ('N27','NULL','0 나누기 방지(분모 0)',1,1,NULL,'ORACLE','100/NULLIF(0,0) IS NULL 플래그');
INSERT INTO sql_example_expectation VALUES ('N27B','NULL','0 나누기 방지(분모 정상)',1,20,NULL,'ORACLE','100/NULLIF(5,0)=20');
INSERT INTO sql_example_expectation VALUES ('N28','NULL','OUTER JOIN으로 생성된 NULL',1,1,NULL,'ORACLE','WHERE r.customer_id IS NULL -> 미매칭 고객 1건');
INSERT INTO sql_example_expectation VALUES ('N29','NULL','OUTER JOIN 이후 COUNT 차이',3,2,NULL,'ORACLE','COUNT(*)=3, COUNT(r.customer_id)=2');
INSERT INTO sql_example_expectation VALUES ('N30','NULL','GROUP BY의 NULL(그룹 수)',1,2,NULL,'ORACLE','Nordeste,NULL 2그룹');
INSERT INTO sql_example_expectation VALUES ('N30B','NULL','GROUP BY의 NULL(NULL 그룹 크기)',1,2,NULL,'ORACLE','REGION IS NULL 2건');
INSERT INTO sql_example_expectation VALUES ('N31','NULL','DISTINCT의 NULL',1,2,NULL,'ORACLE','{1,NULL} 2건');
INSERT INTO sql_example_expectation VALUES ('N32','NULL','ORDER BY의 NULL 위치(ASC)',1,3,NULL,'ORACLE','ASC 기본 NULL 마지막 -> 3번째');
INSERT INTO sql_example_expectation VALUES ('N32B','NULL','ORDER BY의 NULL 위치(DESC)',1,1,NULL,'ORACLE','DESC 기본 NULL 처음 -> 1번째');
INSERT INTO sql_example_expectation VALUES ('N33','NULL','PRIMARY KEY',1,1,NULL,'ORACLE','PK 제약 존재 확인 1건');
INSERT INTO sql_example_expectation VALUES ('N34','NULL','NOT NULL',1,1,NULL,'ORACLE','NOT NULL 제약 존재 확인 1건');
INSERT INTO sql_example_expectation VALUES ('N35','NULL','UNIQUE',3,NULL,NULL,'ORACLE','NULL 2개 모두 허용되어 3행');
INSERT INTO sql_example_expectation VALUES ('N36','NULL','FOREIGN KEY와 NULL',1,1,NULL,'ORACLE','FK NULL 자식행 1건');

COMMIT;
