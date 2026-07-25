-- 데이터 전처리·변수변환 결과 검산

-- 1) 이상치 capping 전/후 극단값 개수 (원본에서 12배로 부풀려진 소득, 150세 나이가 사라졌는지)
SELECT
    (SELECT COUNT(*) FROM raw_customer_intake WHERE income_raw > 15000) AS extreme_income_before,
    (SELECT COUNT(*) FROM customer_clean WHERE income_clean > 15000)    AS extreme_income_after,
    (SELECT COUNT(*) FROM raw_customer_intake WHERE age_raw > 100) AS extreme_age_before,
    (SELECT COUNT(*) FROM customer_clean WHERE age_clean > 100)    AS extreme_age_after;

-- 2) Z-score 표준화 검산: 평균 0, 분산 1에 가까운지
SELECT
    ROUND(AVG(income_zscore), 4) AS mean_zscore,
    ROUND(AVG(income_zscore*income_zscore) - AVG(income_zscore)*AVG(income_zscore), 4) AS var_zscore
FROM customer_transformed;

-- 3) Min-Max 정규화 검산: 최소 0, 최대 1
SELECT MIN(income_minmax) AS min_val, MAX(income_minmax) AS max_val
FROM customer_transformed;

-- 4) 로그변환 전/후 왜도 비교
--    주의: 이 데이터는 01_prepare.sql에서 이미 5~95백분위로 capping해 극단값을 제거했기 때문에
--    원본(income_clean) 자체의 왜도가 이미 낮다(0.096, 거의 대칭). 이런 경우 로그변환을 추가로
--    적용하면 오히려 왜도가 나빠질 수 있다(-0.363, 대칭에서 더 멀어짐) - 로그변환은 "오른쪽 꼬리가
--    긴 분포"에 효과적인 처방이지, 이미 대칭화된 데이터에 무조건 적용할 처치가 아니라는 실무적 교훈이다.
SELECT * FROM preprocessing_skewness;

-- 5) 성별 정제 결과와 구간화(age_bin) 분포 확인
SELECT gender_clean, COUNT(*) AS n FROM customer_transformed GROUP BY gender_clean;
SELECT age_bin, COUNT(*) AS n, ROUND(MIN(age_clean),1) AS min_age, ROUND(MAX(age_clean),1) AS max_age
FROM customer_transformed
GROUP BY age_bin
ORDER BY age_bin;
