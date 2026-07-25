-- PCA 결과 검산 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요 (이 세션에는 SQL Server 실행 환경이 없음)
--
-- 02_analyze.py가 Python(sklearn)에서 만든 결과를 저장할 테이블 DDL.
-- 실제로 SQL Server에 연결하려면 02_analyze.py의 dbutil.get_conn()을 pyodbc
-- 커넥션으로 교체하고 pandas.to_sql(...)로 아래와 같은 스키마에 맞춰 적재한다.

CREATE TABLE pca_variance (
    component                 VARCHAR(10),
    eigenvalue                FLOAT,
    explained_variance_ratio  FLOAT,
    cumulative_ratio          FLOAT
);

CREATE TABLE pca_loadings (
    component  VARCHAR(10),
    feature    VARCHAR(30),
    loading    FLOAT
);

CREATE TABLE pca_scores (
    customer_id VARCHAR(32),
    PC1 FLOAT, PC2 FLOAT, PC3 FLOAT, PC4 FLOAT, PC5 FLOAT, PC6 FLOAT, PC7 FLOAT
);

-- 1) 성분별 고유값·기여율·누적기여율 (Kaiser 기준: eigenvalue > 1)
SELECT component, ROUND(eigenvalue, 4) AS eigenvalue,
       ROUND(explained_variance_ratio, 4) AS ratio,
       ROUND(cumulative_ratio, 4) AS cum_ratio,
       CASE WHEN eigenvalue > 1 THEN 'Y' ELSE 'N' END AS kaiser_keep
FROM pca_variance
ORDER BY component;

-- 2) PC1에 가장 큰 적재량을 가진 변수
SELECT feature, ROUND(loading, 4) AS loading
FROM pca_loadings
WHERE component = 'PC1'
ORDER BY ABS(loading) DESC;

-- 3) 원본 고객 수와 성분점수 테이블 행 수 일치 검산
SELECT
    (SELECT COUNT(*) FROM customer_features) AS n_customers,
    (SELECT COUNT(*) FROM pca_scores)        AS n_scores;

-- 4) PC1 점수 상위 5명 (SQL Server: TOP)
SELECT TOP 5 s.customer_id, ROUND(s.PC1, 3) AS pc1, f.annual_income_10k, f.avg_order_value
FROM pca_scores s
JOIN customer_features f ON f.customer_id = s.customer_id
ORDER BY s.PC1 DESC;
