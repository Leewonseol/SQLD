-- 문제04: 혼동행렬 기반 정밀도·재현율·F1 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요 (이 세션에는 SQL Server 실행 환경이 없음)
-- 핵심 포인트: actual/predicted를 INT로 선언하면 SUM(CASE...)의 결과도 INT이고,
-- INT/INT는 SQL Server에서 정수 나눗셈으로 소수부가 잘린다(3/4 = 0).

IF OBJECT_ID('preds', 'U') IS NOT NULL DROP TABLE preds;

CREATE TABLE preds (
    customer_id INT,
    actual      INT,
    predicted   INT
);

INSERT INTO preds (customer_id, actual, predicted) VALUES
    (1,1,1), (2,1,0), (3,1,1), (4,0,1), (5,0,0),
    (6,0,0), (7,0,0), (8,0,0), (9,1,1), (10,0,0);

-- (A) 캐스팅 없이 그대로 나눈 버전 -> INT/INT라서 0으로 잘리는 오답이 나온다
SELECT
    SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END) AS tp,
    SUM(CASE WHEN actual=0 AND predicted=1 THEN 1 ELSE 0 END) AS fp,
    SUM(CASE WHEN actual=0 AND predicted=0 THEN 1 ELSE 0 END) AS tn,
    SUM(CASE WHEN actual=1 AND predicted=0 THEN 1 ELSE 0 END) AS fn,
    SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
        / (SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
           + SUM(CASE WHEN actual=0 AND predicted=1 THEN 1 ELSE 0 END)) AS precision_no_cast
FROM preds;

-- (B) 1.0을 곱해 FLOAT/DECIMAL로 승격시킨 올바른 버전
SELECT
    ROUND(1.0 * SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
        / (SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
           + SUM(CASE WHEN actual=0 AND predicted=1 THEN 1 ELSE 0 END)), 4) AS precision_cast,
    ROUND(1.0 * SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
        / (SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
           + SUM(CASE WHEN actual=1 AND predicted=0 THEN 1 ELSE 0 END)), 4) AS recall_cast,
    ROUND(1.0 * (SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
                 + SUM(CASE WHEN actual=0 AND predicted=0 THEN 1 ELSE 0 END)) / COUNT(*), 4) AS accuracy_cast
FROM preds;
