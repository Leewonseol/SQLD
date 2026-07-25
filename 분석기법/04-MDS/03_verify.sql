-- MDS 결과 검산

-- 1) stress 값 확인
SELECT * FROM mds_stress;

-- 2) 2차원 좌표와 원 프로파일을 함께 조회 (x축이 소득/구매액과 관련 있는지 육안 확인)
SELECT m.state, ROUND(m.x, 3) AS x, ROUND(m.y, 3) AS y,
       ROUND(r.avg_income, 1) AS avg_income, ROUND(r.avg_aov, 1) AS avg_aov,
       r.n_customers
FROM mds_coords m
JOIN region_profile r ON r.state = m.state
ORDER BY m.x;

-- 3) 원 거리행렬에서 가장 가깝고 먼 지역 쌍 (2차원 좌표가 이 구조를 보존하는지 비교용)
SELECT state1, state2, ROUND(distance, 3) AS distance
FROM region_distance
WHERE state1 < state2
ORDER BY distance ASC
LIMIT 3;

SELECT state1, state2, ROUND(distance, 3) AS distance
FROM region_distance
WHERE state1 < state2
ORDER BY distance DESC
LIMIT 3;
