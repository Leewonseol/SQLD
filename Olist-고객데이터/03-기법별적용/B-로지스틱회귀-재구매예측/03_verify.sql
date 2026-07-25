-- 로지스틱회귀 결과 검산: SQL EXP()로 오즈비 재계산

SELECT variable, ROUND(coef, 4) AS coef,
       ROUND(EXP(coef), 4) AS odds_ratio_from_sql,
       ROUND(odds_ratio, 4) AS odds_ratio_from_python,
       ROUND(p_value, 5) AS p_value
FROM logit_coefficients
ORDER BY variable;

SELECT * FROM logit_metrics;
