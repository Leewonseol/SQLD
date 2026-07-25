-- 문제02: 피어슨 상관계수 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요 (이 세션에는 Oracle 실행 환경이 없음)

DROP TABLE ad_sales;

CREATE TABLE ad_sales (
    mon    NUMBER,
    x      NUMBER,
    y      NUMBER
);

INSERT INTO ad_sales VALUES (1, 1, 2);
INSERT INTO ad_sales VALUES (2, 2, 4);
INSERT INTO ad_sales VALUES (3, 3, 5);
INSERT INTO ad_sales VALUES (4, 4, 4);
INSERT INTO ad_sales VALUES (5, 5, 5);
COMMIT;

-- Oracle은 CORR 집계함수를 내장하고 있다.
SELECT CORR(y, x) AS r_builtin
FROM ad_sales;

-- 검산용: 공식을 직접 전개해도 같은 값이 나와야 한다.
SELECT
    (AVG(x*y) - AVG(x)*AVG(y))
    / (
        SQRT(VAR_POP(x)) * SQRT(VAR_POP(y))
      ) AS r_manual
FROM ad_sales;
