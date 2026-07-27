-- JOIN×NULL 통합 예제 실행 (SQL Server)
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- Oracle/02_examples.sql과 example_id·기대값은 모두 동일하다. 차이는 딱 두
-- 곳(JN11 USING, JN14 Oracle (+))뿐이며, SQL Server가 지원하지 않는 문법이므로
-- ON/LEFT JOIN 기반의 동등 구문으로 같은 결과를 낸다.

DELETE FROM sql_example_result WHERE example_id LIKE 'JN%';

-- =====================================================================
-- JN01. 등가조인 키에 NULL이 있으면 매칭 안 됨
-- 예상 결과: 4행
-- =====================================================================
SELECT c.customer_id, c.sales_region, r.manager_name
FROM customers c JOIN region_lookup r ON c.sales_region = r.sales_region;

INSERT INTO sql_example_result
SELECT 'JN01', 1, COUNT(*), NULL, GETDATE()
FROM customers c JOIN region_lookup r ON c.sales_region = r.sales_region;

-- =====================================================================
-- JN02. LEFT OUTER JOIN이 만드는 NULL
-- 예상 결과: 6행
-- =====================================================================
SELECT c.customer_id, o.order_id, o.amount
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id;

INSERT INTO sql_example_result
SELECT 'JN02', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id;

-- =====================================================================
-- JN03. COUNT(*) vs COUNT(우측열)
-- 예상 결과: COUNT(*)=6(actual_row_count), COUNT(order_id)=4(actual_numeric_value)
-- =====================================================================
SELECT COUNT(*) AS cnt_star, COUNT(o.order_id) AS cnt_col
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id;

INSERT INTO sql_example_result
SELECT 'JN03', COUNT(*), COUNT(o.order_id), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id;

-- =====================================================================
-- JN04. OUTER JOIN 후 WHERE로 보존행 제거 함정
-- 예상 결과: 2행
-- =====================================================================
SELECT c.customer_id, o.amount
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE o.amount > 100;

INSERT INTO sql_example_result
SELECT 'JN04', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE o.amount > 100;

-- =====================================================================
-- JN05. LEFT JOIN + IS NULL 안티조인(정상 동작)
-- 예상 결과: 2행 (고객3, 고객5)
-- =====================================================================
SELECT c.customer_id
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

INSERT INTO sql_example_result
SELECT 'JN05', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- =====================================================================
-- JN06. NOT IN 서브쿼리 함정 - JN05와 "같은 질문"에 대한 잘못된 방법
--   CUSTOMER_ORDERS.customer_id 목록에 고아 주문(O5)의 NULL이 섞여 있어
--   NOT IN 전체가 UNKNOWN이 되어 어떤 고객도 결과에 나오지 못한다.
-- 예상 결과: 0행 (JN05의 2행이 정답, 이 결과가 오답)
-- =====================================================================
SELECT c.customer_id
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM customer_orders o);

INSERT INTO sql_example_result
SELECT 'JN06', COUNT(*), NULL, NULL, GETDATE()
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM customer_orders o);

-- =====================================================================
-- JN07. COALESCE로 미매칭 집계값 기본값 치환
-- 예상 결과: 0 (COALESCE(NULL, 0))
-- =====================================================================
SELECT c.customer_id, SUM(o.amount) AS raw_sum, COALESCE(SUM(o.amount), 0) AS safe_sum
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '0054556ea954a76ad6f9c4ba79d34a98'
GROUP BY c.customer_id;

INSERT INTO sql_example_result
SELECT 'JN07', 1, COALESCE(SUM(o.amount), 0), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '0054556ea954a76ad6f9c4ba79d34a98'
GROUP BY c.customer_id;

-- =====================================================================
-- JN08. JOIN 결과 집계에서 NULL 제외 (AVG)
-- 예상 결과: 100 (고객1의 주문 100,NULL 평균은 NULL 제외한 100)
-- =====================================================================
SELECT c.customer_id, AVG(o.amount) AS avg_amount
FROM customers c JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '00331de1659c7f4fb660c8810e6de3f5'
GROUP BY c.customer_id;

INSERT INTO sql_example_result
SELECT 'JN08', 1, AVG(o.amount), NULL, GETDATE()
FROM customers c JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '00331de1659c7f4fb660c8810e6de3f5'
GROUP BY c.customer_id;

-- =====================================================================
-- JN09. LEFT JOIN + GROUP BY의 NULL 그룹
-- 예상 결과: 4그룹 (고객1,2,4 각자의 그룹 + 미매칭 NULL 그룹 1개)
-- =====================================================================
SELECT o.customer_id, COUNT(*) AS cnt
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
GROUP BY o.customer_id;

INSERT INTO sql_example_result
SELECT 'JN09', 1, COUNT(*), NULL, GETDATE()
FROM (
    SELECT o.customer_id
    FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
    GROUP BY o.customer_id
) t;

-- =====================================================================
-- JN10. FULL OUTER JOIN + COALESCE 키 병합
-- 예상 결과: 7행, 통합키는 전부 NOT NULL
-- =====================================================================
SELECT COALESCE(c.customer_id, l.customer_id) AS unified_id, c.customer_id AS c_id, l.customer_id AS l_id
FROM customers c FULL OUTER JOIN customer_loyalty l ON c.customer_id = l.customer_id;

INSERT INTO sql_example_result
SELECT 'JN10', COUNT(*), NULL, NULL, GETDATE()
FROM customers c FULL OUTER JOIN customer_loyalty l ON c.customer_id = l.customer_id;

-- =====================================================================
-- JN11. USING 동등 표현과 NULL 키 - SQL Server는 USING을 지원하지 않는다.
--   *** 개념적 대응: Oracle의 USING (sales_region)은 SQL Server에서
--   ON customers.sales_region = region_lookup.sales_region 으로만 표현할
--   수 있다. 결과는 JN01과 동일해야 한다(4행, NULL 키 제외). ***
-- 예상 결과: 4행
-- =====================================================================
SELECT c.customer_id, c.sales_region, r.manager_name
FROM customers c JOIN region_lookup r ON c.sales_region = r.sales_region;

INSERT INTO sql_example_result
SELECT 'JN11', 1, COUNT(*), NULL, GETDATE()
FROM customers c JOIN region_lookup r ON c.sales_region = r.sales_region;

-- =====================================================================
-- JN12. 비등가조인(BETWEEN) 경계값 NULL
-- 예상 결과: 4행
-- =====================================================================
SELECT s.customer_id, s.total_spent, b.band
FROM customer_spend s JOIN spend_band b ON s.total_spent BETWEEN b.lo AND b.hi;

INSERT INTO sql_example_result
SELECT 'JN12', 1, COUNT(*), NULL, GETDATE()
FROM customer_spend s JOIN spend_band b ON s.total_spent BETWEEN b.lo AND b.hi;

-- =====================================================================
-- JN13. CROSS JOIN은 NULL과 무관하게 행수 유지
-- 예상 결과: 15행
-- =====================================================================
SELECT COUNT(*) AS cnt FROM customers CROSS JOIN region_lookup;

INSERT INTO sql_example_result
SELECT 'JN13', 1, COUNT(*), NULL, GETDATE() FROM customers CROSS JOIN region_lookup;

-- =====================================================================
-- JN14. Oracle (+) 동등 표현 - SQL Server는 (+) 구문을 지원하지 않는다.
--   *** 개념적 대응: c.customer_id = o.customer_id(+) AND o.amount > 100 는
--   SQL Server에서 LEFT JOIN ... WHERE o.amount > 100 으로만 표현할 수
--   있다. ON에 (+)가 있든 없든 SQL Server의 LEFT JOIN은 WHERE 절 자체가
--   NULL 행을 걸러낸다는 점에서 이 함정과 정확히 같은 구조다(JN04와 동일). ***
-- 예상 결과: 2행 (JN04와 동일)
-- =====================================================================
SELECT c.customer_id, o.amount
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE o.amount > 100;

INSERT INTO sql_example_result
SELECT 'JN14', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE o.amount > 100;
