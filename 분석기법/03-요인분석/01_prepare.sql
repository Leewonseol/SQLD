-- 요인분석 입력 준비: 표준화 + 롱포맷 변환 + 문항 간 상관행렬 계산

DROP TABLE IF EXISTS fa_input;
CREATE TABLE fa_input AS
SELECT
    s.customer_id,
    (s.q1_quality    - t.m1) / t.sd1 AS q1_z,
    (s.q2_price      - t.m2) / t.sd2 AS q2_z,
    (s.q3_delivery   - t.m3) / t.sd3 AS q3_z,
    (s.q4_service    - t.m4) / t.sd4 AS q4_z,
    (s.q5_repurchase - t.m5) / t.sd5 AS q5_z,
    (s.q6_recommend  - t.m6) / t.sd6 AS q6_z
FROM customer_survey s
CROSS JOIN (
    SELECT
        AVG(q1_quality) m1, SQRT(AVG(q1_quality*q1_quality)-AVG(q1_quality)*AVG(q1_quality)) sd1,
        AVG(q2_price) m2, SQRT(AVG(q2_price*q2_price)-AVG(q2_price)*AVG(q2_price)) sd2,
        AVG(q3_delivery) m3, SQRT(AVG(q3_delivery*q3_delivery)-AVG(q3_delivery)*AVG(q3_delivery)) sd3,
        AVG(q4_service) m4, SQRT(AVG(q4_service*q4_service)-AVG(q4_service)*AVG(q4_service)) sd4,
        AVG(q5_repurchase) m5, SQRT(AVG(q5_repurchase*q5_repurchase)-AVG(q5_repurchase)*AVG(q5_repurchase)) sd5,
        AVG(q6_recommend) m6, SQRT(AVG(q6_recommend*q6_recommend)-AVG(q6_recommend)*AVG(q6_recommend)) sd6
    FROM customer_survey
) t;

-- 롱포맷: 문항 간 상관행렬을 self-join으로 계산하기 위한 중간 테이블
DROP TABLE IF EXISTS survey_long;
CREATE TABLE survey_long AS
SELECT customer_id, 'q1_quality'    AS item, q1_quality    AS value FROM customer_survey
UNION ALL SELECT customer_id, 'q2_price',      q2_price      FROM customer_survey
UNION ALL SELECT customer_id, 'q3_delivery',   q3_delivery   FROM customer_survey
UNION ALL SELECT customer_id, 'q4_service',    q4_service    FROM customer_survey
UNION ALL SELECT customer_id, 'q5_repurchase', q5_repurchase FROM customer_survey
UNION ALL SELECT customer_id, 'q6_recommend',  q6_recommend  FROM customer_survey;

-- 문항 간 상관계수: corr(x,y) = (E[xy]-E[x]E[y]) / (sd_x * sd_y)
-- (Oracle은 CORR(x,y) 내장 집계함수로 대체 가능)
DROP TABLE IF EXISTS survey_correlation_matrix;
CREATE TABLE survey_correlation_matrix AS
SELECT
    a.item AS item1,
    b.item AS item2,
    (AVG(a.value*b.value) - AVG(a.value)*AVG(b.value))
        / (
            SQRT(AVG(a.value*a.value) - AVG(a.value)*AVG(a.value))
            * SQRT(AVG(b.value*b.value) - AVG(b.value)*AVG(b.value))
          ) AS correlation
FROM survey_long a
JOIN survey_long b ON a.customer_id = b.customer_id
GROUP BY a.item, b.item;

SELECT COUNT(*) AS n_pairs FROM survey_correlation_matrix;
