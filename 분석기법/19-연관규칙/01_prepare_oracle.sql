-- 연관규칙 입력 준비 (Oracle) — 실행 상태: 실제 Oracle 검증 필요
-- 거래x품목 원-핫 인코딩: PIVOT은 SUM/MAX 등 집계함수가 필요하므로 "있으면 1"을
-- MAX(CASE WHEN...)로 표현한 뒤 PIVOT한다. 결측 조합은 NVL로 0 처리.

DROP TABLE basket_onehot;

CREATE TABLE basket_onehot AS
SELECT
    transaction_id,
    NVL(기저귀,0) AS 기저귀, NVL(맥주,0) AS 맥주, NVL(빵,0) AS 빵, NVL(우유,0) AS 우유,
    NVL(계란,0) AS 계란, NVL(커피,0) AS 커피, NVL(설탕,0) AS 설탕, NVL(과자,0) AS 과자,
    NVL(라면,0) AS 라면, NVL(생수,0) AS 생수
FROM (
    SELECT transaction_id, item, 1 AS present FROM basket_transactions
)
PIVOT (
    MAX(present)
    FOR item IN (
        '기저귀' AS 기저귀, '맥주' AS 맥주, '빵' AS 빵, '우유' AS 우유, '계란' AS 계란,
        '커피' AS 커피, '설탕' AS 설탕, '과자' AS 과자, '라면' AS 라면, '생수' AS 생수
    )
);

SELECT
    ROUND(SUM(기저귀)/COUNT(*), 4) AS support_기저귀,
    ROUND(SUM(맥주)/COUNT(*), 4)   AS support_맥주,
    ROUND(SUM(빵)/COUNT(*), 4)     AS support_빵,
    ROUND(SUM(우유)/COUNT(*), 4)   AS support_우유,
    COUNT(*) AS n_transactions
FROM basket_onehot;
