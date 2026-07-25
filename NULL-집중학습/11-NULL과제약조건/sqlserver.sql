-- 11-NULL과제약조건: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
-- =====================================================================
-- NULL-집중학습 공통 테스트 데이터 (SQL Server)
-- null_lab_customer / null_lab_dept / null_lab_excluded_codes
--
-- Olist 원자료(olist_customers_dataset.csv)와 무관한, 이 학습 모듈 전용의
-- 작은 합성(synthetic) 데이터다. Olist 원자료에는 실제 결측이 없다.
--
-- *** SQL Server 대조 포인트: nickname에 넣은 ''(빈 문자열)는 SQL Server에서
-- NULL로 바뀌지 않고 그대로 ''로 저장된다(Oracle과 정반대). ***
-- =====================================================================

IF OBJECT_ID('null_lab_customer', 'U') IS NOT NULL DROP TABLE null_lab_customer;

CREATE TABLE null_lab_customer (
    customer_id      INT           PRIMARY KEY,
    customer_name    VARCHAR(20)   NOT NULL,
    nickname         VARCHAR(20)   NULL,
    age              INT           NULL,
    membership_code  VARCHAR(5)    NULL,
    score            INT           NULL,
    purchase_amt     DECIMAL(10,2) NULL,
    order_qty        INT           NULL,
    discount_qty     INT           NULL,
    dept_code        VARCHAR(5)    NULL,
    join_date        DATE          NULL
);

INSERT INTO null_lab_customer VALUES (1, '김민준', '민준', 28,   'A001', 85,  120000, 10, 2,    'D01', '2024-01-10');
INSERT INTO null_lab_customer VALUES (2, '이서연', NULL,  34,   'A002', 92,  98000,  5,  0,    'D02', '2024-02-15');
INSERT INTO null_lab_customer VALUES (3, '박지훈', '',    41,   'A003', NULL,150000, 8,  4,    'D03', NULL);
INSERT INTO null_lab_customer VALUES (4, '최유진', ' ',   0,    'A004', 77,  0,      3,  1,    NULL,  '2024-03-05');
INSERT INTO null_lab_customer VALUES (5, '정하은', '하은',NULL, '0',   60,  NULL,   6,  2,    'D01', '2024-01-22');
INSERT INTO null_lab_customer VALUES (6, '강도현', '도현',29,   'A006', 0,   45000,  0,  3,    'D02', '2024-04-11');
INSERT INTO null_lab_customer VALUES (7, '윤서준', '서준',33,   'A007', 88,  76000,  4,  NULL, 'D03', '2024-05-02');
INSERT INTO null_lab_customer VALUES (8, '임수아', NULL,  45,   'A008', 95,  210000, 12, 5,    'D99', '2024-06-19');
INSERT INTO null_lab_customer VALUES (9, '한지민', '지민',26,   'A009', NULL,89000,  7,  2,    'D01', '2024-07-08');
INSERT INTO null_lab_customer VALUES (10,'오세훈', '세훈',38,   'A010', 70,  132000, 9,  3,    NULL,  '2024-08-14');
INSERT INTO null_lab_customer VALUES (11,'배수지', '수지',31,   'A011', 82,  NULL,   5,  2,    'D02', NULL);
INSERT INTO null_lab_customer VALUES (12,'조현우', '현우',50,   'A012', 99,  300000, 15, 5,    'D03', '2024-09-30');

IF OBJECT_ID('null_lab_dept', 'U') IS NOT NULL DROP TABLE null_lab_dept;

CREATE TABLE null_lab_dept (
    dept_code  VARCHAR(5) PRIMARY KEY,
    dept_name  VARCHAR(20)
);

INSERT INTO null_lab_dept VALUES ('D01', '총무팀');
INSERT INTO null_lab_dept VALUES ('D02', '영업팀');
INSERT INTO null_lab_dept VALUES ('D03', '개발팀');
-- customer_id=8(dept_code='D99'), 4·10(dept_code=NULL)은 null_lab_dept에
-- 대응하는 부서가 없다 — JOIN 키 NULL/불일치 실습용(07 폴더), 이 폴더(11)
-- STEP 4의 FK 논의에서도 참고용으로 다시 언급한다.

IF OBJECT_ID('null_lab_excluded_codes', 'U') IS NOT NULL DROP TABLE null_lab_excluded_codes;

CREATE TABLE null_lab_excluded_codes (
    dept_code VARCHAR(5)
);

INSERT INTO null_lab_excluded_codes VALUES ('D02');
INSERT INTO null_lab_excluded_codes VALUES ('D03');
INSERT INTO null_lab_excluded_codes VALUES (NULL);
-- NOT IN (SELECT dept_code FROM null_lab_excluded_codes)는 NULL이 섞여
-- 있어 예상과 다르게 0행이 된다 — 08 폴더 핵심 실습(이 폴더에서는 쓰지 않음).

-- =====================================================================
-- 이 폴더 전용 데모 테이블 — CHECK/UNIQUE/PRIMARY KEY/FOREIGN KEY와
-- NULL의 상호작용을 보여주기 위한 작은 테스트 테이블 3개.
-- =====================================================================

-- ---------------------------------------------------------------------
-- STEP 1. CHECK 제약조건과 NULL — UNKNOWN이면 제약을 "통과"한다.
--   Oracle과 완전히 같은 원리(ANSI SQL 표준 공통) — WHERE는 UNKNOWN인
--   행을 버리지만, CHECK 제약조건은 UNKNOWN인 행을 허용한다.
-- ---------------------------------------------------------------------
IF OBJECT_ID('null_lab_check_demo', 'U') IS NOT NULL DROP TABLE null_lab_check_demo;

CREATE TABLE null_lab_check_demo (
    demo_id  INT PRIMARY KEY,
    score    INT,
    CONSTRAINT ck_check_demo_score CHECK (score >= 0)
);

INSERT INTO null_lab_check_demo VALUES (1, 50);
-- 예상: 성공. score=50 → 50>=0은 TRUE → CHECK 통과.

INSERT INTO null_lab_check_demo VALUES (2, NULL);
-- 예상: **성공**(직관과 다름). score=NULL → NULL>=0은 UNKNOWN → CHECK
-- 제약조건은 "FALSE가 아니면(즉 TRUE거나 UNKNOWN이면) 통과"시킨다.

-- INSERT INTO null_lab_check_demo VALUES (3, -10);
-- 예상: 실행하면 에러 발생(의도된 대조, 주석 처리). score=-10 → FALSE →
-- CHECK 위반으로 INSERT가 거부된다.
-- SQL Server 예상 에러: "The INSERT statement conflicted with the CHECK
-- constraint "ck_check_demo_score"."

SELECT demo_id, score FROM null_lab_check_demo ORDER BY demo_id;
-- 예상: 2행(1, 50) / (2, NULL) 모두 존재.

-- ---------------------------------------------------------------------
-- STEP 2. UNIQUE 제약조건과 NULL — SQL Server는 딱 한 번만 허용한다.
--   *** 이 STEP이 Oracle과 가장 크게 갈리는 지점 ***
--   표준 SQL/Oracle은 UNIQUE 컬럼에 NULL을 여러 번 허용하지만, SQL
--   Server의 일반 UNIQUE 제약조건/인덱스는 NULL을 딱 한 번만 허용한다.
--   두 번째 NULL을 넣으면 유일성 위반 에러가 발생한다 — 이는 Microsoft
--   공식 문서에 명시된, ANSI 표준과 다른 SQL Server 고유의 동작이다.
-- ---------------------------------------------------------------------
IF OBJECT_ID('null_lab_unique_demo', 'U') IS NOT NULL DROP TABLE null_lab_unique_demo;

CREATE TABLE null_lab_unique_demo (
    demo_id  INT PRIMARY KEY,
    email    VARCHAR(30) UNIQUE
);

INSERT INTO null_lab_unique_demo VALUES (1, 'a@test.com');
-- 예상: 성공.

INSERT INTO null_lab_unique_demo VALUES (2, NULL);
-- 예상: 성공(첫 번째 NULL — 여기까지는 Oracle과 같다).

-- INSERT INTO null_lab_unique_demo VALUES (3, NULL);
-- 예상: 실행하면 **실패**한다(Oracle과 정반대, 의도된 대조, 주석 처리).
-- SQL Server 예상 에러: "Violation of UNIQUE KEY constraint
-- 'UQ__null_lab...'. Cannot insert duplicate key in object
-- 'dbo.null_lab_unique_demo'. The duplicate key value is (<NULL>)."
-- SQL Server는 일반 UNIQUE 제약조건에서 NULL도 "값"으로 취급해 유일성
-- 검사 대상에 포함시킨다 — Oracle이 NULL을 "비교 불가능하므로 무제한
-- 허용"으로 보는 것과 다른, SQL Server 고유의 설계 선택이다.

SELECT demo_id, email FROM null_lab_unique_demo ORDER BY demo_id;
-- 예상: 2행만 존재(1, 'a@test.com') / (2, NULL) — 세 번째 INSERT가
-- 실패했으므로 demo_id=3 행은 없다. Oracle 버전(oracle.sql)에서는 3행이
-- 모두 존재하는 것과 대조된다.

-- ---------------------------------------------------------------------
-- STEP 3. PRIMARY KEY와 NULL — 두 DBMS 모두 절대 허용하지 않는다(공통).
-- ---------------------------------------------------------------------
-- INSERT INTO null_lab_check_demo (demo_id, score) VALUES (NULL, 10);
-- 예상: 실행하면 에러 발생(의도된 데모, 주석 처리).
-- SQL Server 예상 에러: "Cannot insert the value NULL into column
-- 'demo_id', table '...null_lab_check_demo'; column does not allow
-- nulls. INSERT fails."
-- PRIMARY KEY 컬럼은 내부적으로 NOT NULL + UNIQUE가 합쳐진 제약이라
-- NULL을 절대 허용하지 않는다 — CHECK/FK와 달리 예외가 없고, STEP 2의
-- "일반 UNIQUE는 NULL 1개 허용"과도 다르다(PK는 NULL을 0개만 허용).

-- ---------------------------------------------------------------------
-- STEP 4. FOREIGN KEY와 NULL — FK 컬럼에 NULL은 허용된다(부모 테이블과
--   매칭할 필요가 없기 때문). null_lab_customer.dept_code가 NULL인 행
--   (4, 10)이 null_lab_dept를 참조하는 FK를 걸어도 위반이 아니라는 것과
--   같은 원리다. 반면 실제로 존재하는 값이지만 부모 테이블에 없는 값
--   (예: 'D99', customer_id=8)은 FK 위반이다.
-- ---------------------------------------------------------------------
IF OBJECT_ID('null_lab_fk_demo', 'U') IS NOT NULL DROP TABLE null_lab_fk_demo;

CREATE TABLE null_lab_fk_demo (
    demo_id    INT PRIMARY KEY,
    dept_code  VARCHAR(5),
    CONSTRAINT fk_fk_demo_dept FOREIGN KEY (dept_code) REFERENCES null_lab_dept (dept_code)
);

INSERT INTO null_lab_fk_demo VALUES (1, 'D01');
-- 예상: 성공. 부모 테이블(null_lab_dept)에 'D01'이 존재.

INSERT INTO null_lab_fk_demo VALUES (2, NULL);
-- 예상: 성공. FK 컬럼은 NULL을 허용한다.

-- INSERT INTO null_lab_fk_demo VALUES (3, 'D99');
-- 예상: 실행하면 에러 발생(의도된 대조, 주석 처리). 'D99'는 실제 값이지만
-- null_lab_dept에 대응하는 행이 없어 FK 위반이다.
-- SQL Server 예상 에러: "The INSERT statement conflicted with the
-- FOREIGN KEY constraint "fk_fk_demo_dept"."

SELECT demo_id, dept_code FROM null_lab_fk_demo ORDER BY demo_id;
-- 예상: 2행(1,'D01') / (2, NULL) 모두 존재.

-- 참고(실행하지 않는 참고용 예시) — null_lab_customer.dept_code에 직접
-- FK를 걸고 싶다면, 기존 데이터에 D99(불일치 값, customer_id=8)가 있어
-- 일반적인 ALTER TABLE ... ADD CONSTRAINT는 즉시 실패한다. 검증을
-- 건너뛰고 "지금부터의 변경만" 강제하려면 WITH NOCHECK를 쓴다
-- (Oracle의 ENABLE NOVALIDATE에 대응).
--
-- ALTER TABLE null_lab_customer WITH NOCHECK
--     ADD CONSTRAINT fk_customer_dept FOREIGN KEY (dept_code)
--     REFERENCES null_lab_dept (dept_code);
--
-- 이 문장을 쓰더라도 customer_id=8(D99)이라는 "기존" 위반 행은 그대로
-- 남아있고(WITH NOCHECK는 과거 데이터를 검증하지 않는다), NULL인 4, 10행은
-- 애초에 문제였던 적이 없다 — NULL은 FK 위반 검사 대상 자체가 아니다.
