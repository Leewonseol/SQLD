-- Olist 고객 데이터 범주형 인코딩 · 희소 범주 통합 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요
-- DENSE_RANK/CASE WHEN은 Oracle과 SQL Server가 문법상 차이가 거의 없는 지점이다.

-- 레이블 인코딩: 고객수 내림차순 순위로 정수 코드화
SELECT customer_state, COUNT(*) AS n_customers,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS state_label_code
FROM customers_raw
GROUP BY customer_state
ORDER BY state_label_code
FETCH FIRST 10 ROWS ONLY;

-- 희소 범주 통합: 500명 미만 주는 '기타'로 묶기
SELECT
    CASE WHEN s.n_customers >= 500 THEN c.customer_state ELSE '기타' END AS state_grouped,
    COUNT(*) AS n_customers
FROM customers_raw c
JOIN (SELECT customer_state, COUNT(*) AS n_customers FROM customers_raw GROUP BY customer_state) s
    ON s.customer_state = c.customer_state
GROUP BY CASE WHEN s.n_customers >= 500 THEN c.customer_state ELSE '기타' END
ORDER BY n_customers DESC;
