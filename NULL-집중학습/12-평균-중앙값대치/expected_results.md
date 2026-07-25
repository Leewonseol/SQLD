# 12. 예상 결과

`impute_practice_raw`는 `분석기법/22-KNN결측값대체`에서 SQLite로 실제
실행·검증된 테이블이다. 아래 수치는 그 검증 결과를 인용한 것이며, Oracle/
SQL Server 자체의 실제 실행은 미검증이다(12절 참고).

## STEP 1. 결측 식별

| total_rows | observed_rows | missing_rows |
|---|---|---|
| 20 | 15 | 5 |

C009: `status = '정상값(0 포함)'` (target_missing_value=0, NULL 아님)

## STEP 2. 전체 평균/중앙값

| overall_mean | overall_median | donor_pool_count |
|---|---|---|
| 6415.8 | 96 | 15 |

## STEP 3. 극단값(C012) 포함/제외 비교

| | 포함(15행) | 제외(14행) |
|---|---|---|
| 평균 | 6415.8 | 88.36 |
| 중앙값 | 96 | 90.5 |

극단값 하나를 뺐을 때 평균은 **6415.8 → 88.36으로 98.6% 감소**했지만,
중앙값은 **96 → 90.5로 5.7%만 변화**했다 — 평균의 극단값 민감도를 보여주는
핵심 수치.

## STEP 5. 최종 결과 테이블 (`mean_median_impute_result`)

| customer_id | scenario_type | original_value | mean_imputed | median_imputed | true_value_for_check | error_mean | error_median |
|---|---|---|---|---|---|---|---|
| C016 | single_null | NULL | 6415.8 | 96 | 132 | 6283.8 | -36 |
| C017 | multi_null | NULL | 6415.8 | 96 | 56 | 6359.8 | 40 |
| C018 | distance_tie | NULL | 6415.8 | 96 | 133 | 6282.8 | -37 |
| C019 | near_extreme | NULL | 6415.8 | 96 | 94000 | -87584.2 | -93904 |
| C020 | single_null | NULL | 6415.8 | 96 | 17 | 6398.8 | 79 |

## STEP 6. RMSE

| rmse_mean | rmse_median |
|---|---|
| 39576.11 | 41995.17 |

`분석기법/22-KNN결측값대체/README.md`의 "RMSE 비교" 절과 동일한 수치다 —
같은 테이블·같은 계산이므로 값이 같아야 정상이며, `13-kNN결측값대체`의
kNN RMSE(strict, 31360.29)와 이 값들을 비교하는 것이 이 모듈 종합 실습의
핵심이다.

## 12. 실제 실행 검증 여부

`impute_practice_raw`와 평균/중앙값 계산 로직 자체는 SQLite로 실제
실행·검증됨(`분석기법/22-KNN결측값대체/optional/`). Oracle `MEDIAN()`,
SQL Server `PERCENTILE_CONT() OVER()` 문법은 이 세션에서 실행하지
않았으므로 미검증이다.
