-- 로지스틱회귀 입력 준비: state 더미변수 (기준범주 = '기타')

DROP TABLE IF EXISTS logit_input;
CREATE TABLE logit_input AS
SELECT
    customer_unique_id,
    is_repeat_customer,
    CASE WHEN state = 'SP' THEN 1 ELSE 0 END AS state_SP,
    CASE WHEN state = 'RJ' THEN 1 ELSE 0 END AS state_RJ,
    CASE WHEN state = 'MG' THEN 1 ELSE 0 END AS state_MG,
    CASE WHEN state = 'RS' THEN 1 ELSE 0 END AS state_RS,
    CASE WHEN state = 'PR' THEN 1 ELSE 0 END AS state_PR,
    CASE WHEN state = 'SC' THEN 1 ELSE 0 END AS state_SC
FROM customer_repeat_features;

SELECT COUNT(*) AS n, SUM(is_repeat_customer) AS n_repeat FROM logit_input;
