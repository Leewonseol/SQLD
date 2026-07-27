-- 문제06: Z-score 표준화 · Min-Max 정규화 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요 (이 세션에는 Oracle 실행 환경이 없음)

DROP TABLE sales;

CREATE TABLE sales (
    store  VARCHAR2(5),
    amount NUMBER
);

INSERT INTO sales VALUES ('A', 12);
INSERT INTO sales VALUES ('B', 15);
INSERT INTO sales VALUES ('C', 11);
INSERT INTO sales VALUES ('D', 18);
INSERT INTO sales VALUES ('E', 14);
COMMIT;

-- 파티션 없는 윈도우 함수(OVER())로 전체 평균/표준편차/최소/최대를 모든 행에 broadcast
SELECT
    store, amount,
    (amount - AVG(amount) OVER()) / STDDEV_POP(amount) OVER() AS z_score,
    (amount - MIN(amount) OVER()) / (MAX(amount) OVER() - MIN(amount) OVER()) AS min_max
FROM sales
ORDER BY store;
