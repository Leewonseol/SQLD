-- 문제01: 평균·분산·표준편차 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요 (이 세션에는 Oracle 실행 환경이 없음)
-- Oracle SQL Developer, Oracle Free(23ai) 등 실제 Oracle 환경에 그대로 복사해 실행 가능.

DROP TABLE sales;

CREATE TABLE sales (
    store  VARCHAR2(5),
    amount NUMBER
);

-- Oracle 전통 INSERT는 한 문장에 한 행만 허용한다(SQL Server의 다중행 VALUES 미지원).
INSERT INTO sales VALUES ('A', 12);
INSERT INTO sales VALUES ('B', 15);
INSERT INTO sales VALUES ('C', 11);
INSERT INTO sales VALUES ('D', 18);
INSERT INTO sales VALUES ('E', 14);
COMMIT;

SELECT
    AVG(amount)        AS mean,
    VAR_POP(amount)     AS pop_variance,
    STDDEV_POP(amount)  AS pop_stddev,
    VARIANCE(amount)    AS sample_variance,   -- Oracle: 인수 1개 VARIANCE = 표본분산
    STDDEV(amount)      AS sample_stddev      -- Oracle: 인수 1개 STDDEV = 표본표준편차
FROM sales;
