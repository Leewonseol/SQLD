-- 교차검증 결과 검산 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요
-- 컬럼명 "precision"은 예약어 충돌 위험이 있어 precision_metric으로 바꿨다(Oracle과 동일 조치).

CREATE TABLE cv_fold_results (
    fold INT, n_test INT, accuracy FLOAT, precision_metric FLOAT, recall FLOAT, f1 FLOAT
);
CREATE TABLE cv_summary (metric VARCHAR(20), mean FLOAT, std FLOAT);

SELECT fold, n_test, ROUND(accuracy, 4) AS accuracy, ROUND(precision_metric, 4) AS precision_metric,
       ROUND(recall, 4) AS recall, ROUND(f1, 4) AS f1
FROM cv_fold_results
ORDER BY fold;

SELECT * FROM cv_summary;

-- SQL로 정확도의 평균·모표준편차 직접 재계산
SELECT
    ROUND(AVG(accuracy), 4) AS mean_accuracy_sql,
    ROUND(SQRT(AVG(accuracy*accuracy) - AVG(accuracy)*AVG(accuracy)), 4) AS population_std_accuracy_sql
FROM cv_fold_results;

SELECT MAX(accuracy) - MIN(accuracy) AS accuracy_range
FROM cv_fold_results;
