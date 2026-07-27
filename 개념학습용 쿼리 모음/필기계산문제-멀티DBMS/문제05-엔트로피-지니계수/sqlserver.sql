-- 문제05: 엔트로피·지니계수 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요 (이 세션에는 SQL Server 실행 환경이 없음)
-- SQL Server LOG(x)는 인수 1개면 자연로그(ln)이고, 밑을 지정하려면 LOG(진수, 밑)
-- 순서로 두 번째 인수에 밑을 쓴다 - Oracle과 인수 순서가 반대다.

IF OBJECT_ID('node_dist', 'U') IS NOT NULL DROP TABLE node_dist;

CREATE TABLE node_dist (
    label VARCHAR(5),
    n     FLOAT
);

INSERT INTO node_dist (label, n) VALUES ('Yes', 8), ('No', 2);

SELECT
    - SUM((n/10) * LOG(n/10, 2)) AS entropy,   -- LOG(진수=n/10, 밑=2) *** Oracle과 인수 순서 반대 ***
    1 - SUM((n/10) * (n/10))     AS gini
FROM node_dist;

-- 함정 시연: 밑을 지정하지 않은 LOG(x)는 자연로그이므로 그대로 쓰면 틀린 엔트로피가 나온다.
SELECT - SUM((n/10) * LOG(n/10)) AS entropy_wrong_using_ln
FROM node_dist;
