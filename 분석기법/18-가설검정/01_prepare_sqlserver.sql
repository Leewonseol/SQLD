-- 가설검정 입력 준비: 집단별 요약통계 + 교차표 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요

-- 1) 대응표본 요약: SQL Server STDEV(표본)를 그대로 사용
IF OBJECT_ID('paired_diff_summary', 'U') IS NOT NULL DROP TABLE paired_diff_summary;
SELECT
    AVG(after_score - before_score) AS mean_diff,
    STDEV(after_score - before_score) AS sample_sd_diff,
    COUNT(*) AS n
INTO paired_diff_summary
FROM paired_scores;

-- 2) 지점별 요약
IF OBJECT_ID('branch_group_summary', 'U') IS NOT NULL DROP TABLE branch_group_summary;
SELECT branch, AVG(score) AS mean_score, VARP(score) AS pop_variance, COUNT(*) AS n
INTO branch_group_summary
FROM branch_scores
GROUP BY branch;

-- 3) A/B 교차표
IF OBJECT_ID('ab_contingency', 'U') IS NOT NULL DROP TABLE ab_contingency;
SELECT variant, converted, COUNT(*) AS n
INTO ab_contingency
FROM ab_test
GROUP BY variant, converted;

SELECT * FROM paired_diff_summary;
SELECT * FROM branch_group_summary ORDER BY branch;
SELECT * FROM ab_contingency ORDER BY variant, converted;
