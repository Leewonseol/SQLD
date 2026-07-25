-- 가설검정 입력 준비: 집단별 요약통계 + 교차표

-- 1) 대응표본 요약: 차이(diff)의 평균/표준편차/표본크기
DROP TABLE IF EXISTS paired_diff_summary;
CREATE TABLE paired_diff_summary AS
SELECT
    AVG(after_score - before_score) AS mean_diff,
    SQRT(AVG((after_score-before_score)*(after_score-before_score)) - AVG(after_score-before_score)*AVG(after_score-before_score))
        * SQRT(1.0 * COUNT(*) / (COUNT(*)-1)) AS sample_sd_diff,  -- 모표준편차 -> 표본표준편차 보정
    COUNT(*) AS n
FROM paired_scores;

-- 2) 지점별 요약: 평균/모분산/표본크기 (ANOVA 계산용)
DROP TABLE IF EXISTS branch_group_summary;
CREATE TABLE branch_group_summary AS
SELECT
    branch,
    AVG(score) AS mean_score,
    AVG(score*score) - AVG(score)*AVG(score) AS pop_variance,
    COUNT(*) AS n
FROM branch_scores
GROUP BY branch;

-- 3) A/B 교차표 (변형 x 전환여부)
DROP TABLE IF EXISTS ab_contingency;
CREATE TABLE ab_contingency AS
SELECT variant, converted, COUNT(*) AS n
FROM ab_test
GROUP BY variant, converted;

SELECT * FROM paired_diff_summary;
SELECT * FROM branch_group_summary ORDER BY branch;
SELECT * FROM ab_contingency ORDER BY variant, converted;
