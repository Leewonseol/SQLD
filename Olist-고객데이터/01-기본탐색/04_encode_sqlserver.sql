-- Olist 고객 데이터 범주형 인코딩 · 희소 범주 통합 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요
-- 이 단계는 Oracle과 문법 차이가 거의 없다 - DENSE_RANK/CASE WHEN/GROUP BY 표현식
-- 모두 두 DBMS에서 동일하게 동작한다. 차이는 상위 N행 문법(TOP vs FETCH FIRST)뿐이다.

-- 레이블 인코딩
SELECT TOP 10 customer_state, COUNT(*) AS n_customers,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS state_label_code
FROM customers_raw
GROUP BY customer_state
ORDER BY state_label_code;

-- 희소 범주 통합
SELECT
    CASE WHEN s.n_customers >= 500 THEN c.customer_state ELSE '기타' END AS state_grouped,
    COUNT(*) AS n_customers
FROM customers_raw c
JOIN (SELECT customer_state, COUNT(*) AS n_customers FROM customers_raw GROUP BY customer_state) s
    ON s.customer_state = c.customer_state
GROUP BY CASE WHEN s.n_customers >= 500 THEN c.customer_state ELSE '기타' END
ORDER BY n_customers DESC;
