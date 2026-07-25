-- 연관규칙 입력 준비 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요

IF OBJECT_ID('basket_onehot', 'U') IS NOT NULL DROP TABLE basket_onehot;

SELECT
    transaction_id,
    ISNULL([기저귀],0) AS 기저귀, ISNULL([맥주],0) AS 맥주, ISNULL([빵],0) AS 빵, ISNULL([우유],0) AS 우유,
    ISNULL([계란],0) AS 계란, ISNULL([커피],0) AS 커피, ISNULL([설탕],0) AS 설탕, ISNULL([과자],0) AS 과자,
    ISNULL([라면],0) AS 라면, ISNULL([생수],0) AS 생수
INTO basket_onehot
FROM (
    SELECT transaction_id, item, 1 AS present FROM basket_transactions
) src
PIVOT (
    MAX(present) FOR item IN ([기저귀],[맥주],[빵],[우유],[계란],[커피],[설탕],[과자],[라면],[생수])
) AS p;

SELECT
    ROUND(1.0 * SUM(기저귀)/COUNT(*), 4) AS support_기저귀,
    ROUND(1.0 * SUM(맥주)/COUNT(*), 4)   AS support_맥주,
    ROUND(1.0 * SUM(빵)/COUNT(*), 4)     AS support_빵,
    ROUND(1.0 * SUM(우유)/COUNT(*), 4)   AS support_우유,
    COUNT(*) AS n_transactions
FROM basket_onehot;
