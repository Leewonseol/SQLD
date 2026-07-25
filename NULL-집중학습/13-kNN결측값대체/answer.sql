-- 13. kNN 결측값 대체 — 정답 및 해설

-- Q1 정답: ②
-- 해설: k = round(sqrt(donor_pool_count)) = round(sqrt(15)) = round(3.873) = 4.

-- Q2 정답: ②
-- 해설: 거리 계산은 "공통으로 관측된 변수만" 사용한다. C017은 recency,
-- delivery_days가 NULL이므로 frequency, monetary, review_score 3개
-- 변수만으로 제곱합을 구하고, sqrt(제곱합/3)로 정규화한다. 변수 개수가
-- 다른 쌍끼리도 공정하게 비교하기 위해 정규화가 반드시 필요하다(①처럼
-- 0으로 채우면 "거리가 0인 방향"으로 인위적인 편향이 생긴다).

-- Q3 정답
SELECT customer_id, error_knn_strict,
       ROUND(mean_imputed - true_value_for_check, 2) AS error_mean,
       ABS(error_knn_strict) AS abs_error_knn,
       ABS(ROUND(mean_imputed - true_value_for_check, 2)) AS abs_error_mean
FROM knn_vs_baseline_result
WHERE ABS(error_knn_strict) < ABS(mean_imputed - true_value_for_check)
ORDER BY customer_id;
-- 결과: C016, C017, C018, C019, C020 전부(5행 모두) — kNN(strict)이 이
-- 데이터셋에서는 모든 대체 대상 행에서 평균 대체보다 오차가 작다.
-- C019조차 kNN 오차(70123.75)가 평균 대체 오차(87584.2)보다는 작지만,
-- 12 폴더 Q4에서 확인했듯 중앙값 대체 오차(93904)보다도 작다 — 그래도
-- C019는 세 방법 모두에서 오차 자체가 매우 크다는 것이 핵심(Q4 참고).

-- Q4 정답 예시
-- C019의 실제로 가까운 이웃은 C012(monetary=98000, 거리상 유일하게
-- 근접) 단 하나뿐이다. 하지만 k=4가 고정되어 있어, 실제로는 전혀
-- 가깝지 않은 나머지 3개 이웃(C012와의 거리보다 수백 배 먼 행들)이
-- 강제로 평균에 섞인다. 그 결과 대체값(23876.25)이 C012 하나만 썼을
-- 때 나왔을 값(95000에 가까운 값)보다 정답(94000)에서 훨씬 멀어진다.
-- 이는 "이웃이 근본적으로 부족한 특이 관측치에서는 고정 k가 오히려
-- 대체 결과를 왜곡할 수 있다"는 kNN 대체의 알려진 한계다.
