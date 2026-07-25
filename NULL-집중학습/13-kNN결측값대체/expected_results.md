# 13. 예상 결과

`impute_practice_raw`와 이 kNN 로직은 `분석기법/22-KNN결측값대체`에서
SQLite로 실제 실행·검증됐다. 아래 수치는 그 검증 결과를 인용한 것이며,
Oracle/SQL Server 자체의 실제 실행은 미검증이다(12절 참고).

## STEP 2. k값

| donor_pool_count | sqrt_n | k |
|---|---|---|
| 15 | 3.873 | 4 |

## STEP 6. 최종 비교 테이블 (`knn_vs_baseline_result`)

| customer_id | scenario_type | true_value_for_check | knn_imputed_strict | error_knn_strict | knn_imputed_with_ties | mean_imputed | median_imputed |
|---|---|---|---|---|---|---|---|
| C016 | single_null | 132 | 121.25 | -10.75 | 116.2 | 6415.8 | 96 |
| C017 | multi_null | 56 | 59.0 | 3.0 | 59.0 | 6415.8 | 96 |
| C018 | distance_tie | 133 | 136.25 | 3.25 | 123.5 | 6415.8 | 96 |
| C019 | near_extreme | 94000 | 23876.25 | -70123.75 | 23876.25 | 6415.8 | 96 |
| C020 | single_null | 17 | 22.0 | 5.0 | 22.0 | 6415.8 | 96 |

C018만 `knn_imputed_strict`(136.25)와 `knn_imputed_with_ties`(123.5)가
다르다 — 4번째 근접이웃 자리에서 C008/C010/C014가 동률이라(`RANK` 기준
6명이 뽑힘, `ROW_NUMBER` 기준은 정확히 4명) 두 방식의 평균이 갈린다.

## STEP 7. RMSE 비교

| rmse_knn_strict | rmse_mean | rmse_median |
|---|---|---|
| 31360.29 | 39576.11 | 41995.17 |

kNN(strict)이 세 방법 중 RMSE가 가장 낮지만, C019(near_extreme) 한 행의
오차(-70123.75)가 이 수치를 크게 좌우한다. `분석기법/22-KNN결측값대체/README.md`
"실행 결과" 절에 따르면 C019를 제외했을 때 kNN(strict) RMSE는 **6.33**,
전체평균 대체 RMSE는 **6331.5**로 kNN의 우위가 훨씬 뚜렷해진다 — "이웃이
실제로 가까운 일반적인 조건"에서는 kNN이 압도적으로 낫지만, 이웃이 근본적으로
부족한 특이 관측치(C019)에서는 고정 k가 오히려 왜곡을 만든다는 것이 이
비교의 결론이다.

## 12. 실제 실행 검증 여부

`impute_practice_raw`와 kNN 대체 로직 자체는 SQLite로 실제 실행·검증됨
(`분석기법/22-KNN결측값대체/optional/`). Oracle/SQL Server 문법은 이
세션에서 실행하지 않았으므로 미검증이다.
