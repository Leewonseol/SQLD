-- 문제05: 엔트로피·지니계수 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요 (이 세션에는 Oracle 실행 환경이 없음)
-- Oracle의 LOG는 인수 1개짜리가 없다 - 항상 LOG(밑, 진수) 두 인수가 필요하다.
-- (자연로그가 필요하면 별도 함수 LN(x)를 쓴다)

DROP TABLE node_dist;

CREATE TABLE node_dist (
    label VARCHAR2(5),
    n     NUMBER
);

INSERT INTO node_dist VALUES ('Yes', 8);
INSERT INTO node_dist VALUES ('No', 2);
COMMIT;

SELECT
    - SUM((n/10) * LOG(2, n/10)) AS entropy,     -- LOG(밑=2, 진수=n/10)
    1 - SUM((n/10) * (n/10))     AS gini
FROM node_dist;
