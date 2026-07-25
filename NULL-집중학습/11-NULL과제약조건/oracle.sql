-- 11-NULL과제약조건: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
-- =====================================================================
-- NULL-집중학습 공통 테스트 데이터 (Oracle)
-- null_lab_customer / null_lab_dept / null_lab_excluded_codes
--
-- Olist 원자료(olist_customers_dataset.csv)와 무관한, 이 학습 모듈 전용의
-- 작은 합성(synthetic) 데이터다. Olist 원자료에는 실제 결측이 없다
-- (Olist-고객데이터/00-데이터사전/profile.py로 확인됨) — 혼동 금지.
--
-- *** Oracle 고유 함정: nickname에 ''(빈 문자열)를 넣는 INSERT는 Oracle에서
-- 그 값을 NULL로 저장한다(Oracle은 ''와 NULL을 구분하지 않는다). 그래서
-- customer_id=3(설계 의도: 빈 문자열)은 Oracle에 적재되는 순간부터
-- nickname이 NULL이 되어, customer_id=2/8(원래부터 NULL)과 구분이 불가능
-- 해진다. 이는 버그가 아니라 이 모듈이 보여주려는 핵심 차이다 — SQL Server
-- 버전(sqlserver.sql)에서는 ''가 그대로 ''로 남아 NULL과 구분된다. ***
-- =====================================================================

DROP TABLE null_lab_customer;

CREATE TABLE null_lab_customer (
    customer_id      NUMBER        PRIMARY KEY,
    customer_name    VARCHAR2(20)  NOT NULL,
    nickname         VARCHAR2(20),
    age              NUMBER,
    membership_code  VARCHAR2(5),
    score             NUMBER,
    purchase_amt     NUMBER(10,2),
    order_qty        NUMBER,
    discount_qty     NUMBER,
    dept_code        VARCHAR2(5),
    join_date        DATE
);

INSERT INTO null_lab_customer VALUES (1, '김민준', '민준', 28,   'A001', 85,  120000, 10, 2,    'D01', DATE '2024-01-10');
INSERT INTO null_lab_customer VALUES (2, '이서연', NULL,  34,   'A002', 92,  98000,  5,  0,    'D02', DATE '2024-02-15');
INSERT INTO null_lab_customer VALUES (3, '박지훈', '',    41,   'A003', NULL,150000, 8,  4,    'D03', NULL);
INSERT INTO null_lab_customer VALUES (4, '최유진', ' ',   0,    'A004', 77,  0,      3,  1,    NULL,  DATE '2024-03-05');
INSERT INTO null_lab_customer VALUES (5, '정하은', '하은',NULL, '0',   60,  NULL,   6,  2,    'D01', DATE '2024-01-22');
INSERT INTO null_lab_customer VALUES (6, '강도현', '도현',29,   'A006', 0,   45000,  0,  3,    'D02', DATE '2024-04-11');
INSERT INTO null_lab_customer VALUES (7, '윤서준', '서준',33,   'A007', 88,  76000,  4,  NULL, 'D03', DATE '2024-05-02');
INSERT INTO null_lab_customer VALUES (8, '임수아', NULL,  45,   'A008', 95,  210000, 12, 5,    'D99', DATE '2024-06-19');
INSERT INTO null_lab_customer VALUES (9, '한지민', '지민',26,   'A009', NULL,89000,  7,  2,    'D01', DATE '2024-07-08');
INSERT INTO null_lab_customer VALUES (10,'오세훈', '세훈',38,   'A010', 70,  132000, 9,  3,    NULL,  DATE '2024-08-14');
INSERT INTO null_lab_customer VALUES (11,'배수지', '수지',31,   'A011', 82,  NULL,   5,  2,    'D02', NULL);
INSERT INTO null_lab_customer VALUES (12,'조현우', '현우',50,   'A012', 99,  300000, 15, 5,    'D03', DATE '2024-09-30');

COMMIT;

DROP TABLE null_lab_dept;

CREATE TABLE null_lab_dept (
    dept_code  VARCHAR2(5) PRIMARY KEY,
    dept_name  VARCHAR2(20)
);

INSERT INTO null_lab_dept VALUES ('D01', '총무팀');
INSERT INTO null_lab_dept VALUES ('D02', '영업팀');
INSERT INTO null_lab_dept VALUES ('D03', '개발팀');

COMMIT;
-- customer_id=8(dept_code='D99'), 4·10(dept_code=NULL)은 null_lab_dept에
-- 대응하는 부서가 없다 — JOIN 키 NULL/불일치 실습용(07 폴더), 이 폴더(11)
-- STEP 4의 FK 논의에서도 참고용으로 다시 언급한다.

DROP TABLE null_lab_excluded_codes;

CREATE TABLE null_lab_excluded_codes (
    dept_code VARCHAR2(5)
);

INSERT INTO null_lab_excluded_codes VALUES ('D02');
INSERT INTO null_lab_excluded_codes VALUES ('D03');
INSERT INTO null_lab_excluded_codes VALUES (NULL);

COMMIT;
-- NOT IN (SELECT dept_code FROM null_lab_excluded_codes)는 NULL이 섞여
-- 있어 예상과 다르게 0행이 된다 — 08 폴더 핵심 실습(이 폴더에서는 쓰지 않음).

-- =====================================================================
-- 이 폴더 전용 데모 테이블 — CHECK/UNIQUE/PRIMARY KEY/FOREIGN KEY와
-- NULL의 상호작용을 보여주기 위한 작은 테스트 테이블 3개.
-- =====================================================================

-- ---------------------------------------------------------------------
-- STEP 1. CHECK 제약조건과 NULL — UNKNOWN이면 제약을 "통과"한다.
--   WHERE는 UNKNOWN인 행을 버리지만(00, 06 폴더), CHECK 제약조건은
--   반대로 UNKNOWN인 행을 허용(위반으로 보지 않음)한다는 것이 이 STEP의
--   핵심 함정이다.
-- ---------------------------------------------------------------------
DROP TABLE null_lab_check_demo;

CREATE TABLE null_lab_check_demo (
    demo_id  NUMBER PRIMARY KEY,
    score    NUMBER,
    CONSTRAINT ck_check_demo_score CHECK (score >= 0)
);

INSERT INTO null_lab_check_demo VALUES (1, 50);
-- 예상: 성공. score=50 → 50>=0은 TRUE → CHECK 통과.

INSERT INTO null_lab_check_demo VALUES (2, NULL);
-- 예상: **성공**(직관과 다름). score=NULL → NULL>=0은 UNKNOWN → CHECK
-- 제약조건은 "FALSE가 아니면(즉 TRUE거나 UNKNOWN이면) 통과"시킨다.
-- WHERE와 정반대 동작이라는 것이 핵심.

-- INSERT INTO null_lab_check_demo VALUES (3, -10);
-- 예상: 실행하면 에러 발생(의도된 대조, 주석 처리). score=-10 → -10>=0은
-- FALSE → CHECK 위반으로 INSERT가 거부된다. "값이 실제로 조건에 위반될
-- 때만" 에러가 나고, "값을 몰라서(NULL)" UNKNOWN이 되는 경우는 에러가
-- 나지 않는다는 대조가 이 STEP의 결론이다.

COMMIT;

SELECT demo_id, score FROM null_lab_check_demo ORDER BY demo_id;
-- 예상: 2행(1, 50) / (2, NULL) 모두 존재 — score가 NULL인 행도 CHECK
-- (score >= 0)를 통과해서 정상적으로 저장되어 있다.

-- ---------------------------------------------------------------------
-- STEP 2. UNIQUE 제약조건과 NULL — Oracle은 여러 번 허용한다.
--   표준 SQL/Oracle은 UNIQUE 컬럼에 NULL을 여러 번 허용한다. NULL은
--   서로 "같다"고 비교되지 않으므로(3값 논리, 00/01 폴더) 유일성 위반으로
--   보지 않기 때문이다.
-- ---------------------------------------------------------------------
DROP TABLE null_lab_unique_demo;

CREATE TABLE null_lab_unique_demo (
    demo_id  NUMBER PRIMARY KEY,
    email    VARCHAR2(30) UNIQUE
);

INSERT INTO null_lab_unique_demo VALUES (1, 'a@test.com');
-- 예상: 성공.

INSERT INTO null_lab_unique_demo VALUES (2, NULL);
-- 예상: 성공(첫 번째 NULL).

INSERT INTO null_lab_unique_demo VALUES (3, NULL);
-- 예상: **성공**(Oracle 고유 동작 — 두 번째 NULL도 유일성 위반이 아니다).
-- SQL Server 버전(sqlserver.sql)에서는 이 두 번째 INSERT가 실패한다 —
-- 이 폴더에서 가장 크게 갈리는 지점.

COMMIT;

SELECT demo_id, email FROM null_lab_unique_demo ORDER BY demo_id;
-- 예상: 3행 모두 존재 — email이 NULL인 행이 두 개(demo_id=2, 3) 있어도
-- UNIQUE 제약조건 위반이 아니다.

-- ---------------------------------------------------------------------
-- STEP 3. PRIMARY KEY와 NULL — 두 DBMS 모두 절대 허용하지 않는다(공통).
-- ---------------------------------------------------------------------
-- INSERT INTO null_lab_check_demo (demo_id, score) VALUES (NULL, 10);
-- 예상: 실행하면 에러 발생(의도된 데모, 주석 처리).
-- Oracle 예상 에러: ORA-01400: cannot insert NULL into
-- ("...","NULL_LAB_CHECK_DEMO","DEMO_ID")
-- PRIMARY KEY 컬럼은 내부적으로 NOT NULL + UNIQUE가 합쳐진 제약이라
-- NULL을 절대 허용하지 않는다 — CHECK/FK와 달리 예외가 없다.

-- ---------------------------------------------------------------------
-- STEP 4. FOREIGN KEY와 NULL — FK 컬럼에 NULL은 허용된다(부모 테이블과
--   매칭할 필요가 없기 때문). 이는 null_lab_customer.dept_code가 NULL인
--   행(4, 10)이 null_lab_dept를 참조하는 FK를 걸어도 위반이 아니라는
--   것과 같은 원리다. 반면 실제로 존재하는 값이지만 부모 테이블에 없는
--   값(예: 'D99', customer_id=8)은 FK 위반이다 — "NULL은 봐주지만 잘못된
--   값은 안 봐준다"는 점이 CHECK 제약조건(STEP 1)과 같은 결의 원리다.
--
--   null_lab_customer 자체에는 이미 dept_code='D99'인 행(8)이 있어 그
--   테이블에 직접 FK를 걸면 기존 데이터 때문에 ALTER TABLE 자체가 즉시
--   실패한다(이는 NULL과 무관한, 실제 불일치 값 때문이다). 그 상황과
--   NULL 허용을 깔끔하게 분리해서 보여주기 위해 전용 데모 테이블을
--   따로 둔다.
-- ---------------------------------------------------------------------
DROP TABLE null_lab_fk_demo;

CREATE TABLE null_lab_fk_demo (
    demo_id    NUMBER PRIMARY KEY,
    dept_code  VARCHAR2(5),
    CONSTRAINT fk_fk_demo_dept FOREIGN KEY (dept_code) REFERENCES null_lab_dept (dept_code)
);

INSERT INTO null_lab_fk_demo VALUES (1, 'D01');
-- 예상: 성공. 부모 테이블(null_lab_dept)에 'D01'이 존재.

INSERT INTO null_lab_fk_demo VALUES (2, NULL);
-- 예상: 성공. FK 컬럼은 NULL을 허용한다 — "부모와 매칭할 필요가 없는
-- 상태"로 취급되기 때문이다.

-- INSERT INTO null_lab_fk_demo VALUES (3, 'D99');
-- 예상: 실행하면 에러 발생(의도된 대조, 주석 처리). 'D99'는 실제 값이지만
-- null_lab_dept에 대응하는 행이 없어 FK 위반이다.
-- Oracle 예상 에러: ORA-02291: integrity constraint violated - parent
-- key not found

COMMIT;

SELECT demo_id, dept_code FROM null_lab_fk_demo ORDER BY demo_id;
-- 예상: 2행(1,'D01') / (2, NULL) 모두 존재.

-- 참고(실행하지 않는 참고용 예시) — null_lab_customer.dept_code에 직접
-- FK를 걸고 싶다면, 기존 데이터에 D99(불일치 값, customer_id=8)가 있어
-- 일반적인 ALTER TABLE ... ADD CONSTRAINT는 즉시 실패한다. 검증을
-- 건너뛰고 "지금부터의 변경만" 강제하려면 ENABLE NOVALIDATE를 쓴다.
--
-- ALTER TABLE null_lab_customer
--     ADD CONSTRAINT fk_customer_dept FOREIGN KEY (dept_code)
--     REFERENCES null_lab_dept (dept_code) ENABLE NOVALIDATE;
--
-- 이 문장을 쓰더라도 customer_id=8(D99)이라는 "기존" 위반 행은 그대로
-- 남아있고(NOVALIDATE는 과거 데이터를 검증하지 않는다), NULL인 4, 10행은
-- 애초에 문제였던 적이 없다 — NULL은 FK 위반 검사 대상 자체가 아니다.
