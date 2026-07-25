-- 분류 입력 준비: state 더미 + customer_fold(01-기본탐색에서 생성) 결합

DROP TABLE IF EXISTS clf_input;
CREATE TABLE clf_input AS
SELECT
    r.customer_unique_id,
    r.is_repeat_customer,
    CASE WHEN r.state = 'SP' THEN 1 ELSE 0 END AS state_SP,
    CASE WHEN r.state = 'RJ' THEN 1 ELSE 0 END AS state_RJ,
    CASE WHEN r.state = 'MG' THEN 1 ELSE 0 END AS state_MG,
    CASE WHEN r.state = 'RS' THEN 1 ELSE 0 END AS state_RS,
    CASE WHEN r.state = 'PR' THEN 1 ELSE 0 END AS state_PR,
    CASE WHEN r.state = 'SC' THEN 1 ELSE 0 END AS state_SC,
    f.fold
FROM customer_repeat_features r
JOIN customer_fold f ON f.customer_unique_id = r.customer_unique_id;

SELECT fold, COUNT(*) AS n, SUM(is_repeat_customer) AS n_repeat
FROM clf_input
GROUP BY fold
ORDER BY fold;
