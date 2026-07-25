-- 가설검정 입력 준비: 집단별 요약통계 + 교차표 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요

-- 1) 대응표본 요약: Oracle은 STDDEV(표본)를 그대로 쓸 수 있어 모->표본 보정식이 필요 없다.
DROP TABLE paired_diff_summary;
CREATE TABLE paired_diff_summary AS
SELECT
    AVG(after_score - before_score) AS mean_diff,
    STDDEV(after_score - before_score) AS sample_sd_diff,   -- Oracle STDDEV(인수 1개) = 표본표준편차
    COUNT(*) AS n
FROM paired_scores;

-- 2) 지점별 요약: 평균/모분산/표본크기 (ANOVA는 모분산 기반 SSW를 쓰므로 VAR_POP 사용)
DROP TABLE branch_group_summary;
CREATE TABLE branch_group_summary AS
SELECT branch, AVG(score) AS mean_score, VAR_POP(score) AS pop_variance, COUNT(*) AS n
FROM branch_scores
GROUP BY branch;

-- 3) A/B 교차표
DROP TABLE ab_contingency;
CREATE TABLE ab_contingency AS
SELECT variant, converted, COUNT(*) AS n
FROM ab_test
GROUP BY variant, converted;

SELECT * FROM paired_diff_summary;
SELECT * FROM branch_group_summary ORDER BY branch;
SELECT * FROM ab_contingency ORDER BY variant, converted;
