-- 연관규칙 결과 검산

-- 1) 단일 품목 규칙 상위 5개 (Python 결과)
SELECT * FROM association_rules_simple ORDER BY lift DESC LIMIT 5;

-- 2) '기저귀 -> 맥주' 규칙의 지지도·신뢰도·향상도를 SQL COUNT로 직접 재계산해 대조
WITH base AS (
    SELECT COUNT(*) AS n_total FROM basket_onehot
),
supp_a AS (
    SELECT 1.0 * SUM(기저귀) / (SELECT n_total FROM base) AS support_a FROM basket_onehot
),
supp_b AS (
    SELECT 1.0 * SUM(맥주) / (SELECT n_total FROM base) AS support_b FROM basket_onehot
),
supp_ab AS (
    SELECT 1.0 * SUM(CASE WHEN 기저귀=1 AND 맥주=1 THEN 1 ELSE 0 END) / (SELECT n_total FROM base) AS support_ab
    FROM basket_onehot
)
SELECT
    ROUND(supp_ab.support_ab, 4) AS support_from_sql,
    ROUND(supp_ab.support_ab / supp_a.support_a, 4) AS confidence_from_sql,
    ROUND((supp_ab.support_ab / supp_a.support_a) / supp_b.support_b, 4) AS lift_from_sql
FROM supp_a, supp_b, supp_ab;

-- 3) Python이 계산한 같은 규칙의 값 (위 SQL 결과와 일치해야 함)
SELECT * FROM association_rules_simple WHERE antecedents = '기저귀' AND consequents = '맥주';
