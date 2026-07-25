-- =====================================================================
-- 분석기법 실습 공통 스키마 (SQLite 기준)
-- =====================================================================
-- 이 파일은 build_db.py 가 생성하는 테이블의 DDL을 "읽는 용도"로 문서화한 것이다.
-- 실제 테이블 생성·적재는 build_db.py 가 pandas.to_sql()로 수행하며,
-- 여기 적힌 DDL과 동일한 구조를 갖는다.
--
-- DBMS 차이 메모
--   - SQLite   : AUTOINCREMENT, TEXT/REAL/INTEGER 동적 타입
--   - Oracle   : NUMBER, VARCHAR2(n), 날짜는 DATE + TO_DATE
--   - SQL Server: INT, NVARCHAR(n), 날짜는 DATE/DATETIME2, TOP 절 사용
-- 각 기법 폴더의 prepare.sql 상단 주석에 DBMS별 문법 차이를 별도로 표기한다.
-- =====================================================================

-- 고객 기본정보 (olist_customers_dataset.csv 표본 추출)
CREATE TABLE customers (
    customer_id            TEXT PRIMARY KEY,   -- Oracle: VARCHAR2(64)
    customer_unique_id     TEXT,
    zip_code_prefix        TEXT,
    city                    TEXT,
    state                   TEXT                -- 지역(시/도) 코드, MDS 실습에서 집계 단위로 사용
);

-- 고객 행동·인구통계 특성 (PCA/SVD/FA/MDS/군집/회귀/분류 공통 입력)
CREATE TABLE customer_features (
    customer_id             TEXT PRIMARY KEY,
    age                     INTEGER,
    annual_income_10k       REAL,   -- 연소득(단위: 만원)
    membership_years        REAL,
    order_count              INTEGER,
    avg_order_value          REAL,   -- 평균 주문 금액(단위: 만원)
    days_since_last_order    INTEGER,
    satisfaction_score       REAL    -- 1~5점
);

-- 지도학습 타깃 (회귀·분류 공통)
CREATE TABLE customer_labels (
    customer_id       TEXT PRIMARY KEY,
    next_month_spend   REAL,    -- 연속형 타깃 (선형/다중 회귀)
    churned            INTEGER  -- 이진 타깃 0/1 (로지스틱회귀·SVM·트리·KNN)
);

-- 고객 x 카테고리 구매금액 (SVD·NMF 행렬분해용 롱포맷)
CREATE TABLE customer_category_spend (
    customer_id  TEXT,
    category      TEXT,
    amount         REAL   -- 0 이상 (NMF 비음수 제약 충족)
);

-- 만족도 설문 6문항 (요인분석용, 2개 잠재요인에서 생성)
CREATE TABLE customer_survey (
    customer_id   TEXT PRIMARY KEY,
    q1_quality     REAL,  -- 품질 만족도
    q2_price       REAL,  -- 가격 만족도
    q3_delivery    REAL,  -- 배송 만족도
    q4_service     REAL,  -- 응대 만족도
    q5_repurchase  REAL,  -- 재구매 의향
    q6_recommend   REAL   -- 추천 의향
);

-- 월별 전국 매출 (이동평균·지수평활·ARIMA용 시계열)
CREATE TABLE monthly_sales (
    month_id    INTEGER PRIMARY KEY,  -- 1..48
    month_date  TEXT,                  -- 'YYYY-MM-01'
    sales        REAL                  -- 단위: 백만원
);

-- 장바구니 거래 내역 (연관규칙용 롱포맷: 거래 하나당 여러 행)
CREATE TABLE basket_transactions (
    transaction_id  INTEGER,
    item             TEXT
);

-- 매장(지점)별 만족도 표본 (분산분석/독립표본 t검정)
CREATE TABLE branch_scores (
    branch  TEXT,   -- 'A', 'B', 'C'
    score    REAL
);

-- 프로모션 전/후 대응표본 (대응표본 t검정)
CREATE TABLE paired_scores (
    customer_id   TEXT PRIMARY KEY,
    before_score   REAL,
    after_score    REAL
);

-- A/B 테스트 전환 여부 (카이제곱 독립성 검정)
CREATE TABLE ab_test (
    customer_id  TEXT PRIMARY KEY,
    variant       TEXT,    -- 'A' | 'B'
    converted     INTEGER  -- 0/1
);

-- 결측치·이상치·표기 불일치가 섞인 원본 데이터 (전처리·변수변환 실습용)
CREATE TABLE raw_customer_intake (
    customer_id   TEXT PRIMARY KEY,
    income_raw     REAL,   -- NULL, 음수, 극단값 포함
    age_raw         REAL,   -- NULL, 음수, 150세 등 이상치 포함
    gender_raw      TEXT,   -- 'M','F','male','Female','m', NULL 등 표기 불일치
    signup_date_raw TEXT     -- 'YYYY-MM-DD' 또는 형식이 다른 문자열
);
