-- 가설검정 입력 준비: 상위 6개 주 + 기타로 그룹핑

DROP TABLE IF EXISTS hyp_input;
CREATE TABLE hyp_input AS
SELECT
    customer_unique_id,
    n_orders,
    is_repeat_customer,
    CASE WHEN state IN ('SP','RJ','MG','RS','PR','SC') THEN state ELSE '기타' END AS state_group
FROM customer_repeat_features;

SELECT state_group, COUNT(*) AS n, ROUND(AVG(n_orders), 4) AS avg_n_orders,
       SUM(is_repeat_customer) AS n_repeat
FROM hyp_input
GROUP BY state_group
ORDER BY n DESC;
