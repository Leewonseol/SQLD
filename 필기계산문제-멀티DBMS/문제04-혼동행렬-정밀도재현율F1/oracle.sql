-- 문제04: 혼동행렬 기반 정밀도·재현율·F1 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요 (이 세션에는 Oracle 실행 환경이 없음)

DROP TABLE preds;

CREATE TABLE preds (
    customer_id NUMBER,
    actual      NUMBER,
    predicted   NUMBER
);

INSERT INTO preds VALUES (1,1,1);
INSERT INTO preds VALUES (2,1,0);
INSERT INTO preds VALUES (3,1,1);
INSERT INTO preds VALUES (4,0,1);
INSERT INTO preds VALUES (5,0,0);
INSERT INTO preds VALUES (6,0,0);
INSERT INTO preds VALUES (7,0,0);
INSERT INTO preds VALUES (8,0,0);
INSERT INTO preds VALUES (9,1,1);
INSERT INTO preds VALUES (10,0,0);
COMMIT;

-- Oracle의 NUMBER는 정수처럼 보이는 컬럼이라도 나눗셈 결과가 항상 정밀도를 보존한다.
-- 즉 캐스팅 없이 나눠도 SQL Server처럼 소수부가 잘리는 사고가 나지 않는다.
SELECT
    SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END) AS tp,
    SUM(CASE WHEN actual=0 AND predicted=1 THEN 1 ELSE 0 END) AS fp,
    SUM(CASE WHEN actual=0 AND predicted=0 THEN 1 ELSE 0 END) AS tn,
    SUM(CASE WHEN actual=1 AND predicted=0 THEN 1 ELSE 0 END) AS fn,
    SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
        / (SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
           + SUM(CASE WHEN actual=0 AND predicted=1 THEN 1 ELSE 0 END)) AS precision_no_cast
FROM preds;
