-- 계층적 군집분석 결과 검산

-- 1) 마지막 5번의 병합 거리 (병합이 진행될수록 거리가 커져야 정상 - 덴드로그램 상단부)
SELECT step, ROUND(distance, 3) AS distance, n_items
FROM hier_merges
ORDER BY step DESC
LIMIT 5;

-- 2) 최종 군집(k=4)별 고객 수와 원 특성 평균
SELECT
    a.cluster,
    COUNT(*) AS n_customers,
    ROUND(AVG(f.annual_income_10k), 1)  AS avg_income,
    ROUND(AVG(f.avg_order_value), 1)    AS avg_aov,
    ROUND(AVG(f.satisfaction_score), 2) AS avg_satisfaction
FROM hier_assignments a
JOIN customer_features f ON f.customer_id = a.customer_id
GROUP BY a.cluster
ORDER BY a.cluster;

-- 3) 병합 거리가 크게 튀는 지점 확인 (직전 병합과의 거리 차이) -> 적절한 절단 지점 판단 근거
SELECT step, ROUND(distance, 3) AS distance,
       ROUND(distance - LAG(distance) OVER (ORDER BY step), 3) AS distance_jump
FROM hier_merges
ORDER BY step DESC
LIMIT 8;
