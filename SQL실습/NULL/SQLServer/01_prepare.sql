-- NULL 실습 데이터 준비 (SQL Server)
-- 대상: 깨우침/NULL 정리.md
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- Oracle/01_prepare.sql과 같은 example_id·같은 기대값을 쓰되, 문법은 SQL
-- Server 방언으로 옮겼다. 예외는 딱 하나 - UNIQUE_TEST: SQL Server는 UNIQUE
-- 컬럼에 NULL을 1개만 허용하므로(Oracle은 여러 개 허용) 이 테이블만 행
-- 구성이 다르다(N35 참고, DBMS 차이 그 자체가 학습 대상).

IF OBJECT_ID('sql_example_validation', 'U') IS NOT NULL DROP TABLE sql_example_validation;
IF OBJECT_ID('sql_example_result', 'U') IS NOT NULL DROP TABLE sql_example_result;
IF OBJECT_ID('sql_example_expectation', 'U') IS NOT NULL DROP TABLE sql_example_expectation;

IF OBJECT_ID('score_t', 'U') IS NOT NULL DROP TABLE score_t;
IF OBJECT_ID('score_zero', 'U') IS NOT NULL DROP TABLE score_zero;
IF OBJECT_ID('score_dup', 'U') IS NOT NULL DROP TABLE score_dup;
IF OBJECT_ID('str_t', 'U') IS NOT NULL DROP TABLE str_t;
IF OBJECT_ID('null_left', 'U') IS NOT NULL DROP TABLE null_left;
IF OBJECT_ID('null_right', 'U') IS NOT NULL DROP TABLE null_right;
IF OBJECT_ID('region_t', 'U') IS NOT NULL DROP TABLE region_t;
IF OBJECT_ID('distinct_t', 'U') IS NOT NULL DROP TABLE distinct_t;
IF OBJECT_ID('order_t', 'U') IS NOT NULL DROP TABLE order_t;
IF OBJECT_ID('unique_test', 'U') IS NOT NULL DROP TABLE unique_test;
IF OBJECT_ID('notnull_test', 'U') IS NOT NULL DROP TABLE notnull_test;
IF OBJECT_ID('fk_child', 'U') IS NOT NULL DROP TABLE fk_child;
IF OBJECT_ID('fk_parent', 'U') IS NOT NULL DROP TABLE fk_parent;
IF OBJECT_ID('base_vals', 'U') IS NOT NULL DROP TABLE base_vals;
IF OBJECT_ID('exclude_list', 'U') IS NOT NULL DROP TABLE exclude_list;

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
-- 예제 데이터 (Oracle/01_prepare.sql과 값 동일, UNIQUE_TEST만 예외)
-- =====================================================================

CREATE TABLE score_t (
    id    INT PRIMARY KEY,
    score INT
);
INSERT INTO score_t VALUES (1, 10);
INSERT INTO score_t VALUES (2, NULL);
INSERT INTO score_t VALUES (3, 20);

CREATE TABLE score_zero (
    id    INT PRIMARY KEY,
    score INT
);
INSERT INTO score_zero VALUES (1, 10);
INSERT INTO score_zero VALUES (2, 20);
INSERT INTO score_zero VALUES (3, 0);

CREATE TABLE score_dup (
    id    INT PRIMARY KEY,
    score INT
);
INSERT INTO score_dup VALUES (1, 10);
INSERT INTO score_dup VALUES (2, 10);
INSERT INTO score_dup VALUES (3, NULL);
INSERT INTO score_dup VALUES (4, 20);

-- STR_T : SQL Server는 ''와 NULL을 구분한다(Oracle과의 핵심 차이, N01,N02).
CREATE TABLE str_t (
    id  INT PRIMARY KEY,
    txt VARCHAR(20)
);
INSERT INTO str_t VALUES (1, 'APPLE');
INSERT INTO str_t VALUES (2, NULL);
INSERT INTO str_t VALUES (3, '');   -- SQL Server: 진짜 빈 문자열, NULL 아님
INSERT INTO str_t VALUES (4, ' ');  -- 공백 1글자

CREATE TABLE null_left (
    id INT PRIMARY KEY
);
INSERT INTO null_left VALUES (1);
INSERT INTO null_left VALUES (2);
INSERT INTO null_left VALUES (3);

CREATE TABLE null_right (
    id INT PRIMARY KEY
);
INSERT INTO null_right VALUES (1);
INSERT INTO null_right VALUES (2);

CREATE TABLE region_t (
    id     INT PRIMARY KEY,
    region VARCHAR(10)
);
INSERT INTO region_t VALUES (1, N'서울');
INSERT INTO region_t VALUES (2, NULL);
INSERT INTO region_t VALUES (3, NULL);

CREATE TABLE distinct_t (
    id  INT PRIMARY KEY,
    val INT
);
INSERT INTO distinct_t VALUES (1, 1);
INSERT INTO distinct_t VALUES (2, 1);
INSERT INTO distinct_t VALUES (3, NULL);
INSERT INTO distinct_t VALUES (4, NULL);

CREATE TABLE order_t (
    id  INT PRIMARY KEY,
    val INT
);
INSERT INTO order_t VALUES (1, 10);
INSERT INTO order_t VALUES (2, NULL);
INSERT INTO order_t VALUES (3, 5);

-- UNIQUE_TEST : SQL Server는 UNIQUE 컬럼에 NULL을 1개만 허용한다.
-- *** DBMS 차이(N35): 아래에서 두 번째 NULL 행(id=3)을 추가로 INSERT하면
--   "Cannot insert duplicate key row..." 오류가 난다(Oracle이라면 성공했을
--   삽입). 스크립트가 항상 오류 없이 재실행되도록 SQL Server 버전은 NULL을
--   1개만 넣어 2행으로 마친다 - Oracle 버전(3행)과의 행 수 차이 자체가
--   "UNIQUE는 Oracle에서 NULL을 허용한다"는 필기 개념의 실제 증거다. ***
CREATE TABLE unique_test (
    id   INT PRIMARY KEY,
    code VARCHAR(10) UNIQUE
);
INSERT INTO unique_test VALUES (1, 'A');
INSERT INTO unique_test VALUES (2, NULL);
-- INSERT INTO unique_test VALUES (3, NULL); -- 실행하지 않음: 2번째 NULL은 UNIQUE 위반

CREATE TABLE notnull_test (
    id      INT PRIMARY KEY,
    req_col INT NOT NULL
);
INSERT INTO notnull_test VALUES (1, 100);
INSERT INTO notnull_test VALUES (2, 200);

CREATE TABLE fk_parent (
    id INT PRIMARY KEY
);
INSERT INTO fk_parent VALUES (1);
INSERT INTO fk_parent VALUES (2);

CREATE TABLE fk_child (
    id        INT PRIMARY KEY,
    parent_id INT REFERENCES fk_parent(id)
);
INSERT INTO fk_child VALUES (1, 1);
INSERT INTO fk_child VALUES (2, NULL); -- 부모 없음(선택적 관계), FK는 NULL 허용

CREATE TABLE base_vals (
    id  INT PRIMARY KEY,
    val INT
);
INSERT INTO base_vals VALUES (1, 1);
INSERT INTO base_vals VALUES (2, 2);
INSERT INTO base_vals VALUES (3, 3);

CREATE TABLE exclude_list (
    id  INT PRIMARY KEY,
    val INT
);
INSERT INTO exclude_list VALUES (1, 1);
INSERT INTO exclude_list VALUES (2, 3);
INSERT INTO exclude_list VALUES (3, NULL);

-- =====================================================================
-- 기대 결과표 적재 (../../_common/expected_results.csv topic=NULL dbms=SQLSERVER 과 동일)
-- =====================================================================
INSERT INTO sql_example_expectation VALUES ('N01','NULL','NULL/0/공백/빈 문자열',1,1,NULL,'SQLSERVER','STR_T IS NULL count: SQL Server는 NULL만 세어 1건');
INSERT INTO sql_example_expectation VALUES ('N02','NULL','SQL Server 빈 문자열과 NULL',1,1,NULL,'SQLSERVER','TXT='''' 비교: 진짜 빈 문자열이라 1건');
INSERT INTO sql_example_expectation VALUES ('N03','NULL','공백 문자열 길이(LEN)',1,0,NULL,'SQLSERVER','LEN('' '')=0 뒤쪽 공백 제거');
INSERT INTO sql_example_expectation VALUES ('N03B','NULL','공백 문자열 길이(DATALENGTH)',1,1,NULL,'SQLSERVER','DATALENGTH('' '')=1 실제 바이트 유지');
INSERT INTO sql_example_expectation VALUES ('N04','NULL','= NULL',1,0,NULL,'SQLSERVER','항상 UNKNOWN이라 0건');
INSERT INTO sql_example_expectation VALUES ('N05','NULL','<> NULL',1,0,NULL,'SQLSERVER','항상 UNKNOWN이라 0건');
INSERT INTO sql_example_expectation VALUES ('N06','NULL','IS NULL',1,1,NULL,'SQLSERVER','ID=2만 해당');
INSERT INTO sql_example_expectation VALUES ('N07','NULL','IS NOT NULL',1,2,NULL,'SQLSERVER','ID=1,3 해당');
INSERT INTO sql_example_expectation VALUES ('N08','NULL','TRUE/FALSE/UNKNOWN(TRUE)',1,1,NULL,'SQLSERVER','1=1 TRUE');
INSERT INTO sql_example_expectation VALUES ('N08B','NULL','TRUE/FALSE/UNKNOWN(FALSE)',1,0,NULL,'SQLSERVER','1=2 FALSE');
INSERT INTO sql_example_expectation VALUES ('N08C','NULL','TRUE/FALSE/UNKNOWN(UNKNOWN)',1,0,NULL,'SQLSERVER','NULL=NULL UNKNOWN');
INSERT INTO sql_example_expectation VALUES ('N09','NULL','LIKE와 NULL',1,1,NULL,'SQLSERVER','APPLE 1건만 매칭');
INSERT INTO sql_example_expectation VALUES ('N10','NULL','산술 연산 NULL 전파',1,1,NULL,'SQLSERVER','SCORE+10 WHERE ID=2 -> NULL 플래그');
INSERT INTO sql_example_expectation VALUES ('N11','NULL','COUNT(*)',1,3,NULL,'SQLSERVER','행 3개 전부');
INSERT INTO sql_example_expectation VALUES ('N12','NULL','COUNT(열)',1,2,NULL,'SQLSERVER','NULL 제외 2건');
INSERT INTO sql_example_expectation VALUES ('N13','NULL','COUNT(DISTINCT 열)',1,2,NULL,'SQLSERVER','10,20 고유값');
INSERT INTO sql_example_expectation VALUES ('N14','NULL','SUM',1,30,NULL,'SQLSERVER','10+20');
INSERT INTO sql_example_expectation VALUES ('N15','NULL','AVG',1,15,NULL,'SQLSERVER','30/2');
INSERT INTO sql_example_expectation VALUES ('N16','NULL','MIN',1,10,NULL,'SQLSERVER','최솟값');
INSERT INTO sql_example_expectation VALUES ('N17','NULL','MAX',1,20,NULL,'SQLSERVER','최댓값');
INSERT INTO sql_example_expectation VALUES ('N18','NULL','NULL과 0의 평균 차이',1,10,NULL,'SQLSERVER','SCORE_ZERO AVG=10, N15(15)와 대조');
INSERT INTO sql_example_expectation VALUES ('N19','NULL','0행 집계 결과',1,0,NULL,'SQLSERVER','조건 0행이지만 집계는 1행 반환');
INSERT INTO sql_example_expectation VALUES ('N20','NULL','IN과 NULL(TRUE)',1,1,NULL,'SQLSERVER','1 IN (1,NULL) TRUE');
INSERT INTO sql_example_expectation VALUES ('N20B','NULL','IN과 NULL(FALSE)',1,0,NULL,'SQLSERVER','2 IN (1,3) FALSE');
INSERT INTO sql_example_expectation VALUES ('N20C','NULL','IN과 NULL(UNKNOWN)',1,0,NULL,'SQLSERVER','2 IN (1,NULL) UNKNOWN');
INSERT INTO sql_example_expectation VALUES ('N21','NULL','NOT IN과 NULL(FALSE)',1,0,NULL,'SQLSERVER','1 NOT IN (1,NULL) FALSE');
INSERT INTO sql_example_expectation VALUES ('N21B','NULL','NOT IN과 NULL(UNKNOWN)',1,0,NULL,'SQLSERVER','2 NOT IN (1,NULL) UNKNOWN');
INSERT INTO sql_example_expectation VALUES ('N21C','NULL','NOT IN과 NULL(TRUE)',1,1,NULL,'SQLSERVER','2 NOT IN (1,3) TRUE');
INSERT INTO sql_example_expectation VALUES ('N22','NULL','서브쿼리 NOT IN과 NULL',0,NULL,NULL,'SQLSERVER','서브쿼리에 NULL 있어 전체 0행');
INSERT INTO sql_example_expectation VALUES ('N23','NULL','COALESCE',1,-1,NULL,'SQLSERVER','COALESCE(SCORE,-1) WHERE ID=2');
INSERT INTO sql_example_expectation VALUES ('N24','NULL','NVL 대응(ISNULL)',1,-1,NULL,'SQLSERVER','NVL 없음, ISNULL(SCORE,-1)로 대체');
INSERT INTO sql_example_expectation VALUES ('N25','NULL','ISNULL',1,-1,NULL,'SQLSERVER','ISNULL(SCORE,-1)=-1');
INSERT INTO sql_example_expectation VALUES ('N26','NULL','NULLIF(같은 값)',1,1,NULL,'SQLSERVER','NULLIF(10,10) IS NULL 플래그');
INSERT INTO sql_example_expectation VALUES ('N26B','NULL','NULLIF(다른 값)',1,10,NULL,'SQLSERVER','NULLIF(10,20)=10');
INSERT INTO sql_example_expectation VALUES ('N27','NULL','0 나누기 방지(분모 0)',1,1,NULL,'SQLSERVER','100/NULLIF(0,0) IS NULL 플래그');
INSERT INTO sql_example_expectation VALUES ('N27B','NULL','0 나누기 방지(분모 정상)',1,20,NULL,'SQLSERVER','100/NULLIF(5,0)=20');
INSERT INTO sql_example_expectation VALUES ('N28','NULL','OUTER JOIN으로 생성된 NULL',1,1,NULL,'SQLSERVER','WHERE r.ID IS NULL -> ID=3');
INSERT INTO sql_example_expectation VALUES ('N29','NULL','OUTER JOIN 이후 COUNT 차이',3,2,NULL,'SQLSERVER','COUNT(*)=3, COUNT(r.ID)=2');
INSERT INTO sql_example_expectation VALUES ('N30','NULL','GROUP BY의 NULL(그룹 수)',1,2,NULL,'SQLSERVER','서울,NULL 2그룹');
INSERT INTO sql_example_expectation VALUES ('N30B','NULL','GROUP BY의 NULL(NULL 그룹 크기)',1,2,NULL,'SQLSERVER','REGION IS NULL 2건');
INSERT INTO sql_example_expectation VALUES ('N31','NULL','DISTINCT의 NULL',1,2,NULL,'SQLSERVER','{1,NULL} 2건');
INSERT INTO sql_example_expectation VALUES ('N32','NULL','ORDER BY의 NULL 위치(ASC)',1,1,NULL,'SQLSERVER','ASC 기본 NULL 처음 -> 1번째');
INSERT INTO sql_example_expectation VALUES ('N32B','NULL','ORDER BY의 NULL 위치(DESC)',1,3,NULL,'SQLSERVER','DESC 기본 NULL 마지막 -> 3번째');
INSERT INTO sql_example_expectation VALUES ('N33','NULL','PRIMARY KEY',1,1,NULL,'SQLSERVER','PK 제약 존재 확인 1건');
INSERT INTO sql_example_expectation VALUES ('N34','NULL','NOT NULL',1,1,NULL,'SQLSERVER','NOT NULL 제약 존재 확인 1건');
INSERT INTO sql_example_expectation VALUES ('N35','NULL','UNIQUE',2,NULL,NULL,'SQLSERVER','NULL 1개만 허용되어 2행');
INSERT INTO sql_example_expectation VALUES ('N36','NULL','FOREIGN KEY와 NULL',1,1,NULL,'SQLSERVER','FK NULL 자식행 1건');
