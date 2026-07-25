-- 연관규칙 결과 검산 (Oracle) — 실행 상태: 실제 Oracle 검증 필요

CREATE TABLE association_rules_simple (
    antecedents VARCHAR2(20), consequents VARCHAR2(20), support NUMBER, confidence NUMBER, lift NUMBER
);

SELECT * FROM association_rules_simple ORDER BY lift DESC FETCH FIRST 5 ROWS ONLY;

WITH base AS (SELECT COUNT(*) AS n_total FROM basket_onehot),
supp_a AS (SELECT SUM(기저귀) / (SELECT n_total FROM base) AS support_a FROM basket_onehot),
supp_b AS (SELECT SUM(맥주) / (SELECT n_total FROM base) AS support_b FROM basket_onehot),
supp_ab AS (
    SELECT SUM(CASE WHEN 기저귀=1 AND 맥주=1 THEN 1 ELSE 0 END) / (SELECT n_total FROM base) AS support_ab
    FROM basket_onehot
)
SELECT
    ROUND(supp_ab.support_ab, 4) AS support_from_sql,
    ROUND(supp_ab.support_ab / supp_a.support_a, 4) AS confidence_from_sql,
    ROUND((supp_ab.support_ab / supp_a.support_a) / supp_b.support_b, 4) AS lift_from_sql
FROM supp_a, supp_b, supp_ab;

SELECT * FROM association_rules_simple WHERE antecedents = '기저귀' AND consequents = '맥주';
