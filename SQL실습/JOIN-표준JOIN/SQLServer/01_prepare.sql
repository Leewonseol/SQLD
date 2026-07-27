-- JOIN·표준 JOIN 실습 데이터 준비 (SQL Server)
-- 대상: 깨우침/JOIN·표준 JOIN 문제 풀이표.md
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- Oracle/01_prepare.sql과 같은 데이터·같은 example_id·같은 기대값을 쓰되,
-- 문법만 SQL Server 방언으로 옮겼다. SQL Server는 IF OBJECT_ID(...) IS NOT NULL
-- DROP TABLE 관용구로 재실행 시에도 오류 없이 정리할 수 있다(Oracle과 달리
-- "테이블 없음" 에러 없이 조용히 넘어간다).

IF OBJECT_ID('sql_example_validation', 'U') IS NOT NULL DROP TABLE sql_example_validation;
IF OBJECT_ID('sql_example_result', 'U') IS NOT NULL DROP TABLE sql_example_result;
IF OBJECT_ID('sql_example_expectation', 'U') IS NOT NULL DROP TABLE sql_example_expectation;

IF OBJECT_ID('dept2', 'U') IS NOT NULL DROP TABLE dept2;
IF OBJECT_ID('dept', 'U') IS NOT NULL DROP TABLE dept;
IF OBJECT_ID('emp', 'U') IS NOT NULL DROP TABLE emp;
IF OBJECT_ID('salgrade', 'U') IS NOT NULL DROP TABLE salgrade;
IF OBJECT_ID('grade_band', 'U') IS NOT NULL DROP TABLE grade_band;
IF OBJECT_ID('small_a', 'U') IS NOT NULL DROP TABLE small_a;
IF OBJECT_ID('small_b', 'U') IS NOT NULL DROP TABLE small_b;
IF OBJECT_ID('dup_t1', 'U') IS NOT NULL DROP TABLE dup_t1;
IF OBJECT_ID('dup_t2', 'U') IS NOT NULL DROP TABLE dup_t2;
IF OBJECT_ID('student', 'U') IS NOT NULL DROP TABLE student;
IF OBJECT_ID('score', 'U') IS NOT NULL DROP TABLE score;
IF OBJECT_ID('full_a', 'U') IS NOT NULL DROP TABLE full_a;
IF OBJECT_ID('full_b', 'U') IS NOT NULL DROP TABLE full_b;
IF OBJECT_ID('member', 'U') IS NOT NULL DROP TABLE member;
IF OBJECT_ID('contact', 'U') IS NOT NULL DROP TABLE contact;
IF OBJECT_ID('branch', 'U') IS NOT NULL DROP TABLE branch;
IF OBJECT_ID('branch_sales', 'U') IS NOT NULL DROP TABLE branch_sales;

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
-- 예제 데이터 (Oracle/01_prepare.sql과 값 동일, 자료형만 SQL Server 방언)
-- =====================================================================

CREATE TABLE dept (
    deptno INT PRIMARY KEY,
    dname  VARCHAR(20)
);
INSERT INTO dept VALUES (10, 'ACCOUNTING');
INSERT INTO dept VALUES (20, 'RESEARCH');
INSERT INTO dept VALUES (30, 'SALES');
INSERT INTO dept VALUES (40, 'OPERATIONS'); -- 소속 직원 없음(J18 동등 예제에서 보존 대상)

CREATE TABLE emp (
    empno  INT PRIMARY KEY,
    ename  VARCHAR(20),
    deptno INT,
    salary INT
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
    grade  INT PRIMARY KEY,
    losal  INT,
    hisal  INT
);
INSERT INTO salgrade VALUES (1, 700, 1200);
INSERT INTO salgrade VALUES (2, 1201, 1400);
INSERT INTO salgrade VALUES (3, 1401, 2000);
INSERT INTO salgrade VALUES (4, 2001, 3000);
INSERT INTO salgrade VALUES (5, 3001, 9999);

-- DEPT2 : ON이 열 이름 달라도 동작함을 보여주는 J14 전용 테이블
CREATE TABLE dept2 (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(20)
);
INSERT INTO dept2 VALUES (10, 'ACCOUNTING');
INSERT INTO dept2 VALUES (20, 'RESEARCH');
INSERT INTO dept2 VALUES (30, 'SALES');
INSERT INTO dept2 VALUES (40, 'OPERATIONS');

-- GRADE_BAND : DEPT(4행) x GRADE_BAND(3행) = 12행 카티션 곱 예제(J04)
CREATE TABLE grade_band (
    bandid   VARCHAR(5) PRIMARY KEY,
    bandname VARCHAR(10)
);
INSERT INTO grade_band VALUES ('B1', 'LOW');
INSERT INTO grade_band VALUES ('B2', 'MID');
INSERT INTO grade_band VALUES ('B3', 'HIGH');

-- SMALL_A / SMALL_B : 첨부 표준 JOIN 문제 9번 유형 CROSS JOIN(2행x3행=6행, J05)
CREATE TABLE small_a (
    id INT PRIMARY KEY
);
INSERT INTO small_a VALUES (1);
INSERT INTO small_a VALUES (2);

CREATE TABLE small_b (
    id INT PRIMARY KEY
);
INSERT INTO small_b VALUES (10);
INSERT INTO small_b VALUES (20);
INSERT INTO small_b VALUES (30);

-- DUP_T1 / DUP_T2 : 첨부 JOIN 문제 5번 유형, 중복값에 따른 결과 행 수 증가(J09)
CREATE TABLE dup_t1 (
    rn   INT PRIMARY KEY,
    col1 INT
);
INSERT INTO dup_t1 VALUES (1, 1);
INSERT INTO dup_t1 VALUES (2, 2);
INSERT INTO dup_t1 VALUES (3, 3);

CREATE TABLE dup_t2 (
    rn   INT PRIMARY KEY,
    col1 INT
);
INSERT INTO dup_t2 VALUES (1, 2);
INSERT INTO dup_t2 VALUES (2, 2);
INSERT INTO dup_t2 VALUES (3, 3);

-- STUDENT / SCORE : INNER/LEFT/RIGHT JOIN 예제(J10~J13)
-- USING/NATURAL JOIN은 SQL Server가 지원하지 않으므로(J15,J16) 이 두 테이블은
-- ON 동등 구문으로만 조인한다. 공통 열 이름 STUNO는 개념 설명을 위해 그대로 둔다.
CREATE TABLE student (
    stuno   INT PRIMARY KEY,
    stuname VARCHAR(20)
);
INSERT INTO student VALUES (202301, 'KIM');
INSERT INTO student VALUES (202302, 'LEE');
INSERT INTO student VALUES (202303, 'PARK');

CREATE TABLE score (
    rn        INT PRIMARY KEY,
    stuno     INT,
    subject   VARCHAR(20),
    scoreval  INT
);
INSERT INTO score VALUES (1, 202301, 'MATH', 90);
INSERT INTO score VALUES (2, 202302, 'ENG', 85);
INSERT INTO score VALUES (3, 202304, 'MATH', 77); -- STUDENT에 없는 학번(RIGHT/FULL 미일치 유발)

-- FULL_A / FULL_B : 첨부 표준 JOIN 문제 8번 그대로(J13, FULL OUTER JOIN 3행)
CREATE TABLE full_a (
    id INT PRIMARY KEY
);
INSERT INTO full_a VALUES (1);
INSERT INTO full_a VALUES (2);

CREATE TABLE full_b (
    id INT PRIMARY KEY
);
INSERT INTO full_b VALUES (2);
INSERT INTO full_b VALUES (3);

-- MEMBER / CONTACT : OUTER JOIN 뒤 WHERE 제거, LEFT JOIN+IS NULL,
-- COUNT(*) vs COUNT(우측열) 예제(J19~J21). Oracle (+)는 J18에서 LEFT JOIN으로 대체.
CREATE TABLE member (
    memberid    VARCHAR(5) PRIMARY KEY,
    membername  VARCHAR(20)
);
INSERT INTO member VALUES ('M1', 'KIM');
INSERT INTO member VALUES ('M2', 'LEE');
INSERT INTO member VALUES ('M3', 'PARK'); -- 연락처 없음

CREATE TABLE contact (
    rn            INT PRIMARY KEY,
    memberid      VARCHAR(5),
    contact_type  VARCHAR(10),
    contact_no    VARCHAR(20)
);
INSERT INTO contact VALUES (1, 'M1', N'휴대폰', '010-1111-1111');
INSERT INTO contact VALUES (2, 'M1', N'이메일', 'kim@test.com');
INSERT INTO contact VALUES (3, 'M2', N'이메일', 'lee@test.com');

-- BRANCH / BRANCH_SALES : "첨부 문제 형태와 유사한 행 수 계산" 연습(J23)
CREATE TABLE branch (
    id INT PRIMARY KEY
);
INSERT INTO branch VALUES (1);
INSERT INTO branch VALUES (2);
INSERT INTO branch VALUES (3);

CREATE TABLE branch_sales (
    rn INT PRIMARY KEY,
    id INT
);
INSERT INTO branch_sales VALUES (1, 2);
INSERT INTO branch_sales VALUES (2, 2);
INSERT INTO branch_sales VALUES (3, 3);

-- =====================================================================
-- 기대 결과표 적재 (../../_common/expected_results.csv topic=JOIN dbms=SQLSERVER 과 동일)
-- =====================================================================
INSERT INTO sql_example_expectation VALUES ('J01','JOIN','테이블 수',1,8,NULL,'SQLSERVER','EMP 8행 단일 테이블 조회이므로 JOIN 아님');
INSERT INTO sql_example_expectation VALUES ('J02','JOIN','연결 조건 존재 여부(카티션 곱)',1,32,NULL,'SQLSERVER','EMP(8)xDEPT(4)=32');
INSERT INTO sql_example_expectation VALUES ('J03','JOIN','연결 조건 존재 여부(조건부 JOIN)',1,8,NULL,'SQLSERVER','전 직원 유효 부서 보유로 8행');
INSERT INTO sql_example_expectation VALUES ('J04','JOIN','카티션 곱 계산(행수/열수)',1,12,NULL,'SQLSERVER','DEPT(4)xGRADE_BAND(3)=12행');
INSERT INTO sql_example_expectation VALUES ('J05','JOIN','CROSS JOIN(2행x3행=6행)',1,6,NULL,'SQLSERVER','SMALL_A(2)xSMALL_B(3)=6행');
INSERT INTO sql_example_expectation VALUES ('J06','JOIN','등가 조인',1,8,NULL,'SQLSERVER','DEPTNO = 비교');
INSERT INTO sql_example_expectation VALUES ('J07','JOIN','비등가 조인',1,8,NULL,'SQLSERVER','SALARY BETWEEN LOSAL AND HISAL');
INSERT INTO sql_example_expectation VALUES ('J08','JOIN','조인 조건과 일반 필터 조건 구분',1,4,NULL,'SQLSERVER','SALARY>2000 필터 추가');
INSERT INTO sql_example_expectation VALUES ('J09','JOIN','중복값에 따른 결과 행 수 증가',1,3,NULL,'SQLSERVER','id1=0 id2=2 id3=1 합계3');
INSERT INTO sql_example_expectation VALUES ('J10','JOIN','INNER JOIN',1,2,NULL,'SQLSERVER','공통 학번 202301,202302');
INSERT INTO sql_example_expectation VALUES ('J11','JOIN','LEFT OUTER JOIN',1,3,NULL,'SQLSERVER','학생 3명 전원 보존');
INSERT INTO sql_example_expectation VALUES ('J12','JOIN','RIGHT OUTER JOIN',1,3,NULL,'SQLSERVER','성적 3건 보존');
INSERT INTO sql_example_expectation VALUES ('J13','JOIN','FULL OUTER JOIN',1,3,NULL,'SQLSERVER','FULL_A/FULL_B 1,2,3 총3행');
INSERT INTO sql_example_expectation VALUES ('J13B','JOIN','FULL OUTER JOIN(학생/성적)',1,4,NULL,'SQLSERVER','202301~202304 총4행');
INSERT INTO sql_example_expectation VALUES ('J14','JOIN','ON(열 이름이 달라도 가능)',1,8,NULL,'SQLSERVER','DEPT2.DEPT_ID로 ON 연결');
INSERT INTO sql_example_expectation VALUES ('J15','JOIN','USING',1,2,NULL,'SQLSERVER','USING 미지원, ON STUDENT.STUNO=SCORE.STUNO로 대체');
INSERT INTO sql_example_expectation VALUES ('J16','JOIN','NATURAL JOIN',1,2,NULL,'SQLSERVER','NATURAL JOIN 미지원, ON STUDENT.STUNO=SCORE.STUNO로 대체');
INSERT INTO sql_example_expectation VALUES ('J17','JOIN','구문형 JOIN',1,4,NULL,'SQLSERVER','FROM A,B WHERE 조인+필터');
INSERT INTO sql_example_expectation VALUES ('J18','JOIN','Oracle (+) 동등 표현',1,9,NULL,'SQLSERVER','(+) 미지원, DEPT LEFT JOIN EMP로 대체 9행');
INSERT INTO sql_example_expectation VALUES ('J19','JOIN','OUTER JOIN 이후 WHERE로 미일치 행 제거',1,1,NULL,'SQLSERVER','WHERE CONTACT_TYPE=휴대폰 -> M1만');
INSERT INTO sql_example_expectation VALUES ('J20','JOIN','LEFT JOIN + IS NULL',1,1,NULL,'SQLSERVER','연락처 없는 회원 M3');
INSERT INTO sql_example_expectation VALUES ('J21','JOIN','COUNT(*) vs COUNT(우측열) - COUNT(*)',4,NULL,NULL,'SQLSERVER','LEFT JOIN 원본 COUNT(*)=4');
INSERT INTO sql_example_expectation VALUES ('J21B','JOIN','COUNT(*) vs COUNT(우측열) - COUNT(우측열)',1,3,NULL,'SQLSERVER','COUNT(CONTACT.MEMBERID)=3');
INSERT INTO sql_example_expectation VALUES ('J22','JOIN','테이블 별칭',1,8,NULL,'SQLSERVER','별칭 a,b 사용');
INSERT INTO sql_example_expectation VALUES ('J23','JOIN','첨부 문제 형태와 유사한 행 수 계산',1,3,NULL,'SQLSERVER','BRANCH/BRANCH_SALES id2=2행 id3=1행 합계3행');
