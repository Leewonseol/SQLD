-- 로지스틱회귀 결과 검산 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요

CREATE TABLE logistic_coefficients (
    variable VARCHAR(30), coef FLOAT, odds_ratio FLOAT, std_err FLOAT, z_value FLOAT, p_value FLOAT
);
CREATE TABLE logistic_predictions (
    customer_id VARCHAR(32), actual INT, predicted_prob FLOAT, predicted_class INT
);

-- 1) SQL EXP()로 오즈비 재계산해 Python 결과와 대조
SELECT variable, ROUND(coef, 4) AS coef,
       ROUND(EXP(coef), 4) AS odds_ratio_from_sql,
       ROUND(odds_ratio, 4) AS odds_ratio_from_python,
       ROUND(p_value, 5) AS p_value
FROM logistic_coefficients
ORDER BY variable;

-- 2) 혼동행렬
SELECT
    SUM(CASE WHEN actual = 1 AND predicted_class = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted_class = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted_class = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted_class = 0 THEN 1 ELSE 0 END) AS FN
FROM logistic_predictions;

-- 3) 정확도: actual/predicted_class가 INT이므로 1.0*로 정수 나눗셈을 반드시 방지해야 한다
SELECT ROUND(1.0 * SUM(CASE WHEN actual = predicted_class THEN 1 ELSE 0 END) / COUNT(*), 4) AS accuracy
FROM logistic_predictions;

-- 4) 예측확률 구간별 실제 이탈률(calibration)
-- 주의: SQL Server는 Oracle과 마찬가지로 GROUP BY에 SELECT의 별칭(prob_bucket)을 쓸 수
-- 없다(표준 SQL 규칙: GROUP BY가 SELECT보다 논리적으로 먼저 실행되므로 별칭이 아직 없음).
-- SQLite/MySQL은 이를 허용하는 확장 기능이 있어 이 규칙이 눈에 띄지 않았을 뿐이다.
SELECT
    CASE
        WHEN predicted_prob < 0.1 THEN '0.0-0.1'
        WHEN predicted_prob < 0.3 THEN '0.1-0.3'
        WHEN predicted_prob < 0.5 THEN '0.3-0.5'
        ELSE '0.5+'
    END AS prob_bucket,
    COUNT(*) AS n,
    ROUND(AVG(1.0 * actual), 4) AS actual_churn_rate
FROM logistic_predictions
GROUP BY CASE
        WHEN predicted_prob < 0.1 THEN '0.0-0.1'
        WHEN predicted_prob < 0.3 THEN '0.1-0.3'
        WHEN predicted_prob < 0.5 THEN '0.3-0.5'
        ELSE '0.5+'
    END
ORDER BY prob_bucket;
