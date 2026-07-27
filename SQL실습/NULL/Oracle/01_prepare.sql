-- NULL 실습 데이터 준비 (Oracle)
-- 대상: 깨우침/NULL 정리.md
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- 최초 실행 시 아래 DROP 구문들이 ORA-00942(테이블/뷰 없음)를 낼 수 있다.
-- 이는 정상이며 무시하고 계속 진행하면 된다(이 저장소의 다른 모듈과 동일 관례).

DROP TABLE sql_example_validation;
DROP TABLE sql_example_result;
DROP TABLE sql_example_expectation;

DROP TABLE score_t;
DROP TABLE score_zero;
DROP TABLE score_dup;
DROP TABLE str_t;
DROP TABLE null_left;
DROP TABLE null_right;
DROP TABLE region_t;
DROP TABLE distinct_t;
DROP TABLE order_t;
DROP TABLE unique_test;
DROP TABLE notnull_test;
DROP TABLE fk_child;
DROP TABLE fk_parent;
DROP TABLE base_vals;
DROP TABLE exclude_list;

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
-- 예제 데이터 (고정 INSERT, 임의 생성 금지)
-- =====================================================================

-- SCORE_T : 집계 함수 NULL 처리 기본 예제(N11~N17). NULL 정리.md 12절의
-- 예시 표(ID1=10, ID2=NULL, ID3=20)를 그대로 옮겼다.
CREATE TABLE score_t (
    id    NUMBER PRIMARY KEY,
    score NUMBER
);
INSERT INTO score_t VALUES (1, 10);
INSERT INTO score_t VALUES (2, NULL);
INSERT INTO score_t VALUES (3, 20);

-- SCORE_ZERO : NULL과 0의 평균 차이 대조군(N18). NULL 정리.md 13절 예시.
CREATE TABLE score_zero (
    id    NUMBER PRIMARY KEY,
    score NUMBER
);
INSERT INTO score_zero VALUES (1, 10);
INSERT INTO score_zero VALUES (2, 20);
INSERT INTO score_zero VALUES (3, 0);

-- SCORE_DUP : COUNT(DISTINCT 열) 전용(N13). 10이 두 번 나오게 해 COUNT(열)과
-- COUNT(DISTINCT 열)이 실제로 다른 값을 내도록 설계했다.
CREATE TABLE score_dup (
    id    NUMBER PRIMARY KEY,
    score NUMBER
);
INSERT INTO score_dup VALUES (1, 10);
INSERT INTO score_dup VALUES (2, 10);
INSERT INTO score_dup VALUES (3, NULL);
INSERT INTO score_dup VALUES (4, 20);

-- STR_T : NULL/빈 문자열/공백 구분(N01~N03B, N09).
-- *** Oracle 고유 함정: id=3에 ''(빈 문자열)을 넣는 INSERT는 Oracle에서
-- 그 값을 NULL로 저장한다(Oracle은 ''와 NULL을 구분하지 않는다). id=4의
-- ' '(공백 1글자)는 실제 문자가 있으므로 NULL이 되지 않는다. ***
CREATE TABLE str_t (
    id  NUMBER PRIMARY KEY,
    txt VARCHAR2(20)
);
INSERT INTO str_t VALUES (1, 'APPLE');
INSERT INTO str_t VALUES (2, NULL);
INSERT INTO str_t VALUES (3, '');   -- Oracle: 저장되는 순간 NULL이 됨
INSERT INTO str_t VALUES (4, ' ');  -- 공백 1글자, NULL 아님

-- NULL_LEFT / NULL_RIGHT : OUTER JOIN이 만드는 NULL, COUNT(*) vs COUNT(우측열)
-- 차이(N28, N29). NULL 정리.md 16절 예시(A 3행, 매칭 2행, 미매칭 1행) 그대로.
CREATE TABLE null_left (
    id NUMBER PRIMARY KEY
);
INSERT INTO null_left VALUES (1);
INSERT INTO null_left VALUES (2);
INSERT INTO null_left VALUES (3);

CREATE TABLE null_right (
    id NUMBER PRIMARY KEY
);
INSERT INTO null_right VALUES (1);
INSERT INTO null_right VALUES (2);

-- REGION_T : GROUP BY의 NULL(N30, N30B). NULL 정리.md 17절 예시 그대로
-- (서울 1건, NULL 2건).
CREATE TABLE region_t (
    id     NUMBER PRIMARY KEY,
    region VARCHAR2(10)
);
INSERT INTO region_t VALUES (1, '서울');
INSERT INTO region_t VALUES (2, NULL);
INSERT INTO region_t VALUES (3, NULL);

-- DISTINCT_T : DISTINCT의 NULL(N31). NULL 정리.md 18절 예시 그대로(1,1,NULL,NULL).
CREATE TABLE distinct_t (
    id  NUMBER PRIMARY KEY,
    val NUMBER
);
INSERT INTO distinct_t VALUES (1, 1);
INSERT INTO distinct_t VALUES (2, 1);
INSERT INTO distinct_t VALUES (3, NULL);
INSERT INTO distinct_t VALUES (4, NULL);

-- ORDER_T : ORDER BY의 NULL 위치(N32, N32B).
CREATE TABLE order_t (
    id  NUMBER PRIMARY KEY,
    val NUMBER
);
INSERT INTO order_t VALUES (1, 10);
INSERT INTO order_t VALUES (2, NULL);
INSERT INTO order_t VALUES (3, 5);

-- UNIQUE_TEST : UNIQUE 제약과 NULL(N35).
-- Oracle은 UNIQUE 컬럼에 NULL을 여러 개 허용한다(NULL<>NULL이므로 유일성
-- 위반이 아니다) - 그래서 NULL 2개를 넣어도 성공하며 3행이 남는다.
CREATE TABLE unique_test (
    id   NUMBER PRIMARY KEY,
    code VARCHAR2(10) UNIQUE
);
INSERT INTO unique_test VALUES (1, 'A');
INSERT INTO unique_test VALUES (2, NULL);
INSERT INTO unique_test VALUES (3, NULL); -- Oracle에서는 성공(SQL Server라면 위반)

-- NOTNULL_TEST : PRIMARY KEY / NOT NULL 제약 메타데이터 확인용(N33, N34).
CREATE TABLE notnull_test (
    id      NUMBER PRIMARY KEY,
    req_col NUMBER NOT NULL
);
INSERT INTO notnull_test VALUES (1, 100);
INSERT INTO notnull_test VALUES (2, 200);

-- FK_PARENT / FK_CHILD : FOREIGN KEY와 NULL(N36) - 선택적 관계는 NULL 허용.
CREATE TABLE fk_parent (
    id NUMBER PRIMARY KEY
);
INSERT INTO fk_parent VALUES (1);
INSERT INTO fk_parent VALUES (2);

CREATE TABLE fk_child (
    id        NUMBER PRIMARY KEY,
    parent_id NUMBER REFERENCES fk_parent(id)
);
INSERT INTO fk_child VALUES (1, 1);
INSERT INTO fk_child VALUES (2, NULL); -- 부모 없음(선택적 관계), FK는 NULL 허용

-- BASE_VALS / EXCLUDE_LIST : 서브쿼리 NOT IN과 NULL의 함정(N22).
CREATE TABLE base_vals (
    id  NUMBER PRIMARY KEY,
    val NUMBER
);
INSERT INTO base_vals VALUES (1, 1);
INSERT INTO base_vals VALUES (2, 2);
INSERT INTO base_vals VALUES (3, 3);

CREATE TABLE exclude_list (
    id  NUMBER PRIMARY KEY,
    val NUMBER
);
INSERT INTO exclude_list VALUES (1, 1);
INSERT INTO exclude_list VALUES (2, 3);
INSERT INTO exclude_list VALUES (3, NULL);

COMMIT;

-- =====================================================================
-- 기대 결과표 적재 (../../_common/expected_results.csv topic=NULL dbms=ORACLE 과 동일)
-- =====================================================================
INSERT INTO sql_example_expectation VALUES ('N01','NULL','NULL/0/공백/빈 문자열',1,2,NULL,'ORACLE','STR_T IS NULL count: Oracle은 id2,id3 합쳐 2건');
INSERT INTO sql_example_expectation VALUES ('N02','NULL','Oracle 빈 문자열과 NULL',1,0,NULL,'ORACLE','TXT='''' 비교: 컬럼이 이미 NULL이라 0건');
INSERT INTO sql_example_expectation VALUES ('N03','NULL','공백 문자열 길이(LENGTH)',1,1,NULL,'ORACLE','LENGTH('' '')=1');
INSERT INTO sql_example_expectation VALUES ('N03B','NULL','공백 문자열 길이(Oracle 구분없음)',1,1,NULL,'ORACLE','DATALENGTH 개념 없음, LENGTH로 통일');
INSERT INTO sql_example_expectation VALUES ('N04','NULL','= NULL',1,0,NULL,'ORACLE','항상 UNKNOWN이라 0건');
INSERT INTO sql_example_expectation VALUES ('N05','NULL','<> NULL',1,0,NULL,'ORACLE','항상 UNKNOWN이라 0건');
INSERT INTO sql_example_expectation VALUES ('N06','NULL','IS NULL',1,1,NULL,'ORACLE','ID=2만 해당');
INSERT INTO sql_example_expectation VALUES ('N07','NULL','IS NOT NULL',1,2,NULL,'ORACLE','ID=1,3 해당');
INSERT INTO sql_example_expectation VALUES ('N08','NULL','TRUE/FALSE/UNKNOWN(TRUE)',1,1,NULL,'ORACLE','1=1 TRUE');
INSERT INTO sql_example_expectation VALUES ('N08B','NULL','TRUE/FALSE/UNKNOWN(FALSE)',1,0,NULL,'ORACLE','1=2 FALSE');
INSERT INTO sql_example_expectation VALUES ('N08C','NULL','TRUE/FALSE/UNKNOWN(UNKNOWN)',1,0,NULL,'ORACLE','NULL=NULL UNKNOWN');
INSERT INTO sql_example_expectation VALUES ('N09','NULL','LIKE와 NULL',1,1,NULL,'ORACLE','APPLE 1건만 매칭');
INSERT INTO sql_example_expectation VALUES ('N10','NULL','산술 연산 NULL 전파',1,1,NULL,'ORACLE','SCORE+10 WHERE ID=2 -> NULL 플래그');
INSERT INTO sql_example_expectation VALUES ('N11','NULL','COUNT(*)',1,3,NULL,'ORACLE','행 3개 전부');
INSERT INTO sql_example_expectation VALUES ('N12','NULL','COUNT(열)',1,2,NULL,'ORACLE','NULL 제외 2건');
INSERT INTO sql_example_expectation VALUES ('N13','NULL','COUNT(DISTINCT 열)',1,2,NULL,'ORACLE','10,20 고유값');
INSERT INTO sql_example_expectation VALUES ('N14','NULL','SUM',1,30,NULL,'ORACLE','10+20');
INSERT INTO sql_example_expectation VALUES ('N15','NULL','AVG',1,15,NULL,'ORACLE','30/2');
INSERT INTO sql_example_expectation VALUES ('N16','NULL','MIN',1,10,NULL,'ORACLE','최솟값');
INSERT INTO sql_example_expectation VALUES ('N17','NULL','MAX',1,20,NULL,'ORACLE','최댓값');
INSERT INTO sql_example_expectation VALUES ('N18','NULL','NULL과 0의 평균 차이',1,10,NULL,'ORACLE','SCORE_ZERO AVG=10, N15(15)와 대조');
INSERT INTO sql_example_expectation VALUES ('N19','NULL','0행 집계 결과',1,0,NULL,'ORACLE','조건 0행이지만 집계는 1행 반환');
INSERT INTO sql_example_expectation VALUES ('N20','NULL','IN과 NULL(TRUE)',1,1,NULL,'ORACLE','1 IN (1,NULL) TRUE');
INSERT INTO sql_example_expectation VALUES ('N20B','NULL','IN과 NULL(FALSE)',1,0,NULL,'ORACLE','2 IN (1,3) FALSE');
INSERT INTO sql_example_expectation VALUES ('N20C','NULL','IN과 NULL(UNKNOWN)',1,0,NULL,'ORACLE','2 IN (1,NULL) UNKNOWN');
INSERT INTO sql_example_expectation VALUES ('N21','NULL','NOT IN과 NULL(FALSE)',1,0,NULL,'ORACLE','1 NOT IN (1,NULL) FALSE');
INSERT INTO sql_example_expectation VALUES ('N21B','NULL','NOT IN과 NULL(UNKNOWN)',1,0,NULL,'ORACLE','2 NOT IN (1,NULL) UNKNOWN');
INSERT INTO sql_example_expectation VALUES ('N21C','NULL','NOT IN과 NULL(TRUE)',1,1,NULL,'ORACLE','2 NOT IN (1,3) TRUE');
INSERT INTO sql_example_expectation VALUES ('N22','NULL','서브쿼리 NOT IN과 NULL',0,NULL,NULL,'ORACLE','서브쿼리에 NULL 있어 전체 0행');
INSERT INTO sql_example_expectation VALUES ('N23','NULL','COALESCE',1,-1,NULL,'ORACLE','COALESCE(SCORE,-1) WHERE ID=2');
INSERT INTO sql_example_expectation VALUES ('N24','NULL','NVL',1,-1,NULL,'ORACLE','NVL(SCORE,-1)=-1');
INSERT INTO sql_example_expectation VALUES ('N25','NULL','ISNULL 대응(NVL)',1,-1,NULL,'ORACLE','Oracle에는 ISNULL 없음, NVL로 대체');
INSERT INTO sql_example_expectation VALUES ('N26','NULL','NULLIF(같은 값)',1,1,NULL,'ORACLE','NULLIF(10,10) IS NULL 플래그');
INSERT INTO sql_example_expectation VALUES ('N26B','NULL','NULLIF(다른 값)',1,10,NULL,'ORACLE','NULLIF(10,20)=10');
INSERT INTO sql_example_expectation VALUES ('N27','NULL','0 나누기 방지(분모 0)',1,1,NULL,'ORACLE','100/NULLIF(0,0) IS NULL 플래그');
INSERT INTO sql_example_expectation VALUES ('N27B','NULL','0 나누기 방지(분모 정상)',1,20,NULL,'ORACLE','100/NULLIF(5,0)=20');
INSERT INTO sql_example_expectation VALUES ('N28','NULL','OUTER JOIN으로 생성된 NULL',1,1,NULL,'ORACLE','WHERE r.ID IS NULL -> ID=3');
INSERT INTO sql_example_expectation VALUES ('N29','NULL','OUTER JOIN 이후 COUNT 차이',3,2,NULL,'ORACLE','COUNT(*)=3, COUNT(r.ID)=2');
INSERT INTO sql_example_expectation VALUES ('N30','NULL','GROUP BY의 NULL(그룹 수)',1,2,NULL,'ORACLE','서울,NULL 2그룹');
INSERT INTO sql_example_expectation VALUES ('N30B','NULL','GROUP BY의 NULL(NULL 그룹 크기)',1,2,NULL,'ORACLE','REGION IS NULL 2건');
INSERT INTO sql_example_expectation VALUES ('N31','NULL','DISTINCT의 NULL',1,2,NULL,'ORACLE','{1,NULL} 2건');
INSERT INTO sql_example_expectation VALUES ('N32','NULL','ORDER BY의 NULL 위치(ASC)',1,3,NULL,'ORACLE','ASC 기본 NULL 마지막 -> 3번째');
INSERT INTO sql_example_expectation VALUES ('N32B','NULL','ORDER BY의 NULL 위치(DESC)',1,1,NULL,'ORACLE','DESC 기본 NULL 처음 -> 1번째');
INSERT INTO sql_example_expectation VALUES ('N33','NULL','PRIMARY KEY',1,1,NULL,'ORACLE','PK 제약 존재 확인 1건');
INSERT INTO sql_example_expectation VALUES ('N34','NULL','NOT NULL',1,1,NULL,'ORACLE','NOT NULL 제약 존재 확인 1건');
INSERT INTO sql_example_expectation VALUES ('N35','NULL','UNIQUE',3,NULL,NULL,'ORACLE','NULL 2개 모두 허용되어 3행');
INSERT INTO sql_example_expectation VALUES ('N36','NULL','FOREIGN KEY와 NULL',1,1,NULL,'ORACLE','FK NULL 자식행 1건');

COMMIT;
