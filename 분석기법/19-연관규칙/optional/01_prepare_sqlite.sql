-- 연관규칙 입력 준비: 거래 롱포맷 -> 거래x품목 원-핫 wide 행렬로 PIVOT
-- (SQLite는 PIVOT 구문이 없어 SUM(CASE WHEN...) 조건부 집계로 대체)

DROP TABLE IF EXISTS basket_onehot;
CREATE TABLE basket_onehot AS
SELECT
    transaction_id,
    MAX(CASE WHEN item = '기저귀' THEN 1 ELSE 0 END) AS 기저귀,
    MAX(CASE WHEN item = '맥주'   THEN 1 ELSE 0 END) AS 맥주,
    MAX(CASE WHEN item = '빵'     THEN 1 ELSE 0 END) AS 빵,
    MAX(CASE WHEN item = '우유'   THEN 1 ELSE 0 END) AS 우유,
    MAX(CASE WHEN item = '계란'   THEN 1 ELSE 0 END) AS 계란,
    MAX(CASE WHEN item = '커피'   THEN 1 ELSE 0 END) AS 커피,
    MAX(CASE WHEN item = '설탕'   THEN 1 ELSE 0 END) AS 설탕,
    MAX(CASE WHEN item = '과자'   THEN 1 ELSE 0 END) AS 과자,
    MAX(CASE WHEN item = '라면'   THEN 1 ELSE 0 END) AS 라면,
    MAX(CASE WHEN item = '생수'   THEN 1 ELSE 0 END) AS 생수
FROM basket_transactions
GROUP BY transaction_id;

-- 품목별 지지도(단일 품목) 확인
SELECT
    ROUND(1.0*SUM(기저귀)/COUNT(*), 4) AS support_기저귀,
    ROUND(1.0*SUM(맥주)/COUNT(*), 4)   AS support_맥주,
    ROUND(1.0*SUM(빵)/COUNT(*), 4)     AS support_빵,
    ROUND(1.0*SUM(우유)/COUNT(*), 4)   AS support_우유,
    COUNT(*) AS n_transactions
FROM basket_onehot;
