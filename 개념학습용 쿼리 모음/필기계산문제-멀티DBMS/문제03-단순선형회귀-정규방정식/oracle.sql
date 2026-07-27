-- 문제03: 단순선형회귀 정규방정식 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요 (이 세션에는 Oracle 실행 환경이 없음)

DROP TABLE ad_sales;

CREATE TABLE ad_sales (
    mon NUMBER,
    x   NUMBER,
    y   NUMBER
);

INSERT INTO ad_sales VALUES (1, 1, 2);
INSERT INTO ad_sales VALUES (2, 2, 4);
INSERT INTO ad_sales VALUES (3, 3, 5);
INSERT INTO ad_sales VALUES (4, 4, 4);
INSERT INTO ad_sales VALUES (5, 5, 5);
COMMIT;

-- Oracle은 REGR_* 회귀 집계함수를 내장하고 있다.
SELECT
    REGR_SLOPE(y, x)     AS beta1,
    REGR_INTERCEPT(y, x) AS beta0,
    REGR_INTERCEPT(y, x) + REGR_SLOPE(y, x) * 6 AS predict_at_x6,
    REGR_R2(y, x)        AS r_squared
FROM ad_sales;
