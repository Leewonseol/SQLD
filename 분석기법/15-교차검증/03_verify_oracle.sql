-- 교차검증 결과 검산 (Oracle) — 실행 상태: 실제 Oracle 검증 필요
-- 주의: 컬럼명 "precision"은 ANSI SQL 예약어라 Oracle에서 그대로 쓰면 위험하다.
-- 02_analyze.py를 Oracle에 연결할 때는 to_sql 이전에 precision -> precision_metric으로
-- rename해야 한다(이 파일은 이미 그렇게 반영했다).

CREATE TABLE cv_fold_results (
    fold NUMBER, n_test NUMBER, accuracy NUMBER, precision_metric NUMBER, recall NUMBER, f1 NUMBER
);
CREATE TABLE cv_summary (metric VARCHAR2(20), mean NUMBER, std NUMBER);

SELECT fold, n_test, ROUND(accuracy, 4) AS accuracy, ROUND(precision_metric, 4) AS precision_metric,
       ROUND(recall, 4) AS recall, ROUND(f1, 4) AS f1
FROM cv_fold_results
ORDER BY fold;

SELECT * FROM cv_summary;

-- SQL로 정확도의 평균·모표준편차 직접 재계산 (Oracle NUMBER는 나눗셈 캐스팅 불필요)
SELECT
    ROUND(AVG(accuracy), 4) AS mean_accuracy_sql,
    ROUND(SQRT(AVG(accuracy*accuracy) - AVG(accuracy)*AVG(accuracy)), 4) AS population_std_accuracy_sql
FROM cv_fold_results;

SELECT MAX(accuracy) - MIN(accuracy) AS accuracy_range
FROM cv_fold_results;
