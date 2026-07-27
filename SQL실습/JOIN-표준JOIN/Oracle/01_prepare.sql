-- JOIN·표준 JOIN 실습 데이터 준비 (Oracle)
-- 대상: 깨우침/JOIN·표준 JOIN 문제 풀이표.md
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- 이 스크립트는 몇 번을 다시 실행해도 같은 상태가 되도록, 먼저 모든 대상
-- 객체를 DROP한 뒤 다시 만든다. Oracle은 존재하지 않는 객체를 DROP하면
-- 오류가 나므로(이 저장소 다른 모듈과 동일한 관례), 최초 1회 실행 시에는
-- 아래 DROP 구문들이 ORA-00942(테이블 또는 뷰가 존재하지 않습니다)를 낼 수
-- 있다 — 이는 정상이며 무시하고 계속 진행하면 된다.

DROP TABLE sql_example_validation;
DROP TABLE sql_example_result;
DROP TABLE sql_example_expectation;

DROP TABLE dept2;
DROP TABLE dept;
DROP TABLE emp;
DROP TABLE salgrade;
DROP TABLE grade_band;
DROP TABLE small_a;
DROP TABLE small_b;
DROP TABLE dup_t1;
DROP TABLE dup_t2;
DROP TABLE student;
DROP TABLE score;
DROP TABLE full_a;
DROP TABLE full_b;
DROP TABLE member;
DROP TABLE contact;
DROP TABLE branch;
DROP TABLE branch_sales;

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
-- 예제 데이터 (고정 INSERT, 임의 생성 금지)
-- =====================================================================

-- DEPT / EMP / SALGRADE : 등가·비등가 조인, 카티션 곱, 조인 조건 vs 필터,
-- 구문형 JOIN, Oracle (+) 예제에서 재사용
CREATE TABLE dept (
    deptno NUMBER PRIMARY KEY,
    dname  VARCHAR2(20)
);
INSERT INTO dept VALUES (10, 'ACCOUNTING');
INSERT INTO dept VALUES (20, 'RESEARCH');
INSERT INTO dept VALUES (30, 'SALES');
INSERT INTO dept VALUES (40, 'OPERATIONS'); -- 소속 직원 없음(J18의 (+) 예제에서 보존 대상)

CREATE TABLE emp (
    empno  NUMBER PRIMARY KEY,
    ename  VARCHAR2(20),
    deptno NUMBER,
    salary NUMBER
);
INSERT INTO emp VALUES (7369, 'SMITH', 20, 800);
INSERT INTO emp VALUES (7499, 'ALLEN', 30, 1600);
INSERT INTO emp VALUES (7521, 'WARD', 30, 1250);
INSERT INTO emp VALUES (7566, 'JONES', 20, 2975);
INSERT INTO emp VALUES (7654, 'MARTIN', 30, 1250);
INSERT INTO emp VALUES (7698, 'BLAKE', 30, 2850);
INSERT INTO emp VALUES (7782, 'CLARK', 10, 2450);
INSERT INTO emp VALUES (7788, 'SCOTT', 20, 3000);

CREATE TABLE salgrade (
    grade  NUMBER PRIMARY KEY,
    losal  NUMBER,
    hisal  NUMBER
);
INSERT INTO salgrade VALUES (1, 700, 1200);
INSERT INTO salgrade VALUES (2, 1201, 1400);
INSERT INTO salgrade VALUES (3, 1401, 2000);
INSERT INTO salgrade VALUES (4, 2001, 3000);
INSERT INTO salgrade VALUES (5, 3001, 9999);

-- DEPT2 : DEPT와 값은 같지만 PK 열 이름이 다름 -> ON이 열 이름이 달라도
-- 동작함(USING/NATURAL은 불가능)을 보여주는 J14 전용 테이블
CREATE TABLE dept2 (
    dept_id   NUMBER PRIMARY KEY,
    dept_name VARCHAR2(20)
);
INSERT INTO dept2 VALUES (10, 'ACCOUNTING');
INSERT INTO dept2 VALUES (20, 'RESEARCH');
INSERT INTO dept2 VALUES (30, 'SALES');
INSERT INTO dept2 VALUES (40, 'OPERATIONS');

-- GRADE_BAND : DEPT(4행) x GRADE_BAND(3행) = 12행 카티션 곱 예제(J04)
CREATE TABLE grade_band (
    bandid   VARCHAR2(5) PRIMARY KEY,
    bandname VARCHAR2(10)
);
INSERT INTO grade_band VALUES ('B1', 'LOW');
INSERT INTO grade_band VALUES ('B2', 'MID');
INSERT INTO grade_band VALUES ('B3', 'HIGH');

-- SMALL_A / SMALL_B : 첨부 표준 JOIN 문제 9번 유형 CROSS JOIN(2행x3행=6행, J05)
CREATE TABLE small_a (
    id NUMBER PRIMARY KEY
);
INSERT INTO small_a VALUES (1);
INSERT INTO small_a VALUES (2);

CREATE TABLE small_b (
    id NUMBER PRIMARY KEY
);
INSERT INTO small_b VALUES (10);
INSERT INTO small_b VALUES (20);
INSERT INTO small_b VALUES (30);

-- DUP_T1 / DUP_T2 : 첨부 JOIN 문제 5번 유형, 중복값에 따른 결과 행 수 증가(J09)
CREATE TABLE dup_t1 (
    rn   NUMBER PRIMARY KEY,
    col1 NUMBER
);
INSERT INTO dup_t1 VALUES (1, 1);
INSERT INTO dup_t1 VALUES (2, 2);
INSERT INTO dup_t1 VALUES (3, 3);

CREATE TABLE dup_t2 (
    rn   NUMBER PRIMARY KEY,
    col1 NUMBER
);
INSERT INTO dup_t2 VALUES (1, 2);
INSERT INTO dup_t2 VALUES (2, 2);
INSERT INTO dup_t2 VALUES (3, 3);

-- STUDENT / SCORE : INNER/LEFT/RIGHT JOIN, USING, NATURAL JOIN 예제
-- (J10~J13, J15, J16). 공통 열 이름 STUNO를 그대로 공유해야 USING/NATURAL이
-- 성립하므로 두 테이블 모두 STUNO라는 이름을 그대로 쓴다.
CREATE TABLE student (
    stuno   NUMBER PRIMARY KEY,
    stuname VARCHAR2(20)
);
INSERT INTO student VALUES (202301, 'KIM');
INSERT INTO student VALUES (202302, 'LEE');
INSERT INTO student VALUES (202303, 'PARK');

CREATE TABLE score (
    rn        NUMBER PRIMARY KEY,
    stuno     NUMBER,
    subject   VARCHAR2(20),
    scoreval  NUMBER
);
INSERT INTO score VALUES (1, 202301, 'MATH', 90);
INSERT INTO score VALUES (2, 202302, 'ENG', 85);
INSERT INTO score VALUES (3, 202304, 'MATH', 77); -- STUDENT에 없는 학번(RIGHT/FULL 미일치 유발)

-- FULL_A / FULL_B : 첨부 표준 JOIN 문제 8번 그대로(J13, FULL OUTER JOIN 3행)
CREATE TABLE full_a (
    id NUMBER PRIMARY KEY
);
INSERT INTO full_a VALUES (1);
INSERT INTO full_a VALUES (2);

CREATE TABLE full_b (
    id NUMBER PRIMARY KEY
);
INSERT INTO full_b VALUES (2);
INSERT INTO full_b VALUES (3);

-- MEMBER / CONTACT : OUTER JOIN 뒤 WHERE 제거, LEFT JOIN+IS NULL,
-- COUNT(*) vs COUNT(우측열), Oracle (+) 예제(J18~J21)
CREATE TABLE member (
    memberid    VARCHAR2(5) PRIMARY KEY,
    membername  VARCHAR2(20)
);
INSERT INTO member VALUES ('M1', 'KIM');
INSERT INTO member VALUES ('M2', 'LEE');
INSERT INTO member VALUES ('M3', 'PARK'); -- 연락처 없음

CREATE TABLE contact (
    rn            NUMBER PRIMARY KEY,
    memberid      VARCHAR2(5),
    contact_type  VARCHAR2(10),
    contact_no    VARCHAR2(20)
);
INSERT INTO contact VALUES (1, 'M1', '휴대폰', '010-1111-1111');
INSERT INTO contact VALUES (2, 'M1', '이메일', 'kim@test.com');
INSERT INTO contact VALUES (3, 'M2', '이메일', 'lee@test.com');

-- BRANCH / BRANCH_SALES : "첨부 문제 형태와 유사한 행 수 계산" 연습(J23)
-- DUP_T1/DUP_T2와 수치 구조는 같지만(1,2,3 vs 2,2,3) 실무 이름으로 별도 연습.
CREATE TABLE branch (
    id NUMBER PRIMARY KEY
);
INSERT INTO branch VALUES (1);
INSERT INTO branch VALUES (2);
INSERT INTO branch VALUES (3);

CREATE TABLE branch_sales (
    rn NUMBER PRIMARY KEY,
    id NUMBER
);
INSERT INTO branch_sales VALUES (1, 2);
INSERT INTO branch_sales VALUES (2, 2);
INSERT INTO branch_sales VALUES (3, 3);

COMMIT;

-- =====================================================================
-- 기대 결과표 적재 (../../_common/expected_results.csv topic=JOIN dbms=ORACLE 과 동일)
-- =====================================================================
INSERT INTO sql_example_expectation VALUES ('J01','JOIN','테이블 수',1,8,NULL,'ORACLE','EMP 8행 단일 테이블 조회이므로 JOIN 아님');
INSERT INTO sql_example_expectation VALUES ('J02','JOIN','연결 조건 존재 여부(카티션 곱)',1,32,NULL,'ORACLE','EMP(8)xDEPT(4)=32');
INSERT INTO sql_example_expectation VALUES ('J03','JOIN','연결 조건 존재 여부(조건부 JOIN)',1,8,NULL,'ORACLE','전 직원 유효 부서 보유로 8행');
INSERT INTO sql_example_expectation VALUES ('J04','JOIN','카티션 곱 계산(행수/열수)',1,12,NULL,'ORACLE','DEPT(4)xGRADE_BAND(3)=12행');
INSERT INTO sql_example_expectation VALUES ('J05','JOIN','CROSS JOIN(2행x3행=6행)',1,6,NULL,'ORACLE','SMALL_A(2)xSMALL_B(3)=6행');
INSERT INTO sql_example_expectation VALUES ('J06','JOIN','등가 조인',1,8,NULL,'ORACLE','DEPTNO = 비교');
INSERT INTO sql_example_expectation VALUES ('J07','JOIN','비등가 조인',1,8,NULL,'ORACLE','SALARY BETWEEN LOSAL AND HISAL');
INSERT INTO sql_example_expectation VALUES ('J08','JOIN','조인 조건과 일반 필터 조건 구분',1,4,NULL,'ORACLE','SALARY>2000 필터 추가');
INSERT INTO sql_example_expectation VALUES ('J09','JOIN','중복값에 따른 결과 행 수 증가',1,3,NULL,'ORACLE','id1=0 id2=2 id3=1 합계3');
INSERT INTO sql_example_expectation VALUES ('J10','JOIN','INNER JOIN',1,2,NULL,'ORACLE','공통 학번 202301,202302');
INSERT INTO sql_example_expectation VALUES ('J11','JOIN','LEFT OUTER JOIN',1,3,NULL,'ORACLE','학생 3명 전원 보존');
INSERT INTO sql_example_expectation VALUES ('J12','JOIN','RIGHT OUTER JOIN',1,3,NULL,'ORACLE','성적 3건 보존');
INSERT INTO sql_example_expectation VALUES ('J13','JOIN','FULL OUTER JOIN',1,3,NULL,'ORACLE','FULL_A/FULL_B 1,2,3 총3행');
INSERT INTO sql_example_expectation VALUES ('J13B','JOIN','FULL OUTER JOIN(학생/성적)',1,4,NULL,'ORACLE','202301~202304 총4행');
INSERT INTO sql_example_expectation VALUES ('J14','JOIN','ON(열 이름이 달라도 가능)',1,8,NULL,'ORACLE','DEPT2.DEPT_ID로 ON 연결');
INSERT INTO sql_example_expectation VALUES ('J15','JOIN','USING',1,2,NULL,'ORACLE','USING(STUNO) 직접 사용');
INSERT INTO sql_example_expectation VALUES ('J16','JOIN','NATURAL JOIN',1,2,NULL,'ORACLE','공통열 STUNO 자동조건');
INSERT INTO sql_example_expectation VALUES ('J17','JOIN','구문형 JOIN',1,4,NULL,'ORACLE','FROM A,B WHERE 조인+필터');
INSERT INTO sql_example_expectation VALUES ('J18','JOIN','Oracle (+)',1,9,NULL,'ORACLE','DEPT a EMP b(+) dept40 보존 포함 9행');
INSERT INTO sql_example_expectation VALUES ('J19','JOIN','OUTER JOIN 이후 WHERE로 미일치 행 제거',1,1,NULL,'ORACLE','WHERE CONTACT_TYPE=휴대폰 -> M1만');
INSERT INTO sql_example_expectation VALUES ('J20','JOIN','LEFT JOIN + IS NULL',1,1,NULL,'ORACLE','연락처 없는 회원 M3');
INSERT INTO sql_example_expectation VALUES ('J21','JOIN','COUNT(*) vs COUNT(우측열) - COUNT(*)',4,NULL,NULL,'ORACLE','LEFT JOIN 원본 COUNT(*)=4');
INSERT INTO sql_example_expectation VALUES ('J21B','JOIN','COUNT(*) vs COUNT(우측열) - COUNT(우측열)',1,3,NULL,'ORACLE','COUNT(CONTACT.MEMBERID)=3');
INSERT INTO sql_example_expectation VALUES ('J22','JOIN','테이블 별칭',1,8,NULL,'ORACLE','별칭 a,b 사용');
INSERT INTO sql_example_expectation VALUES ('J23','JOIN','첨부 문제 형태와 유사한 행 수 계산',1,3,NULL,'ORACLE','BRANCH/BRANCH_SALES id2=2행 id3=1행 합계3행');

COMMIT;
