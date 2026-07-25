-- 주(state) 단위 프로파일 집계 -> 표준화

DROP TABLE IF EXISTS state_profile;
CREATE TABLE state_profile AS
SELECT
    r.state,
    COUNT(*) AS n_customers,
    AVG(r.is_repeat_customer) AS repeat_rate,
    AVG(r.n_orders) AS avg_n_orders,
    (SELECT COUNT(DISTINCT c2.customer_city) FROM customers_raw c2 WHERE c2.customer_state = r.state) AS n_cities,
    (
        SELECT SUM((1.0*cc.n/city_total.total) * (1.0*cc.n/city_total.total))
        FROM (
            SELECT customer_city, COUNT(*) AS n
            FROM customers_raw c3
            WHERE c3.customer_state = r.state
            GROUP BY customer_city
        ) cc
        CROSS JOIN (SELECT COUNT(*) AS total FROM customers_raw c4 WHERE c4.customer_state = r.state) city_total
    ) AS city_hhi
FROM customer_repeat_features r
GROUP BY r.state;

DROP TABLE IF EXISTS state_profile_z;
CREATE TABLE state_profile_z AS
SELECT
    state,
    (n_customers - t.m1) / t.sd1 AS n_customers_z,
    (repeat_rate - t.m2) / t.sd2 AS repeat_rate_z,
    (avg_n_orders - t.m3) / t.sd3 AS avg_n_orders_z,
    (n_cities - t.m4) / t.sd4 AS n_cities_z,
    (city_hhi - t.m5) / t.sd5 AS city_hhi_z
FROM state_profile
CROSS JOIN (
    SELECT
        AVG(n_customers) m1, SQRT(AVG(n_customers*n_customers)-AVG(n_customers)*AVG(n_customers)) sd1,
        AVG(repeat_rate) m2, SQRT(AVG(repeat_rate*repeat_rate)-AVG(repeat_rate)*AVG(repeat_rate)) sd2,
        AVG(avg_n_orders) m3, SQRT(AVG(avg_n_orders*avg_n_orders)-AVG(avg_n_orders)*AVG(avg_n_orders)) sd3,
        AVG(n_cities) m4, SQRT(AVG(n_cities*n_cities)-AVG(n_cities)*AVG(n_cities)) sd4,
        AVG(city_hhi) m5, SQRT(AVG(city_hhi*city_hhi)-AVG(city_hhi)*AVG(city_hhi)) sd5
    FROM state_profile
) t;

SELECT * FROM state_profile ORDER BY n_customers DESC LIMIT 10;
