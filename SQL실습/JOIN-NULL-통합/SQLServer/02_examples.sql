-- JOIN×NULL 통합 예제 실행 (SQL Server)
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- Oracle/02_examples.sql과 example_id·기대값·설명(문제상황/직관/3값논리/근거)이
-- 전부 동일하므로 여기서는 개념 설명을 반복하지 않고, SQL Server 문법으로 옮긴
-- 코드와 두 곳(JN10, JN14)의 문법 차이 주석만 남긴다. 각 개념의 전체 설명은
-- Oracle/02_examples.sql의 해당 구획(A~N)을 참고.
--
-- 규칙: actual_row_count는 항상 리터럴 1, 실제 비교값은 항상 actual_numeric_value에
-- 담는다(섹션 7 규칙, Oracle 파일과 동일 원칙).

DELETE FROM sql_example_result WHERE example_id LIKE 'JN%';

-- ===================== A. 조인 키 자체가 NULL인 경우 =====================

-- JN01A. INNER JOIN
SELECT c.customer_id, c.sales_region, r.manager_name
FROM customers c JOIN regions r ON c.sales_region = r.sales_region;
INSERT INTO sql_example_result
SELECT 'JN01A', 1, COUNT(*), NULL, GETDATE()
FROM customers c JOIN regions r ON c.sales_region = r.sales_region;

-- JN01B. LEFT OUTER JOIN
SELECT c.customer_id, c.sales_region, r.manager_name
FROM customers c LEFT OUTER JOIN regions r ON c.sales_region = r.sales_region;
INSERT INTO sql_example_result
SELECT 'JN01B', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN regions r ON c.sales_region = r.sales_region;

-- ===================== B. OUTER JOIN이 새로 만드는 NULL =====================

-- JN02A. 패딩 NULL(주문 자체가 없음, order_id IS NULL)
SELECT c.customer_id, o.order_id, o.amount
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
INSERT INTO sql_example_result
SELECT 'JN02A', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- JN02B. 원본 NULL(주문은 있지만 amount만 NULL)
SELECT c.customer_id, o.order_id, o.amount
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NOT NULL AND o.amount IS NULL;
INSERT INTO sql_example_result
SELECT 'JN02B', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NOT NULL AND o.amount IS NULL;

-- ===================== C. ON 필터와 WHERE 필터의 차이 =====================

-- JN03A. ON 안에 조건 - 매칭 후보만 제한, 7명 전원 보존
SELECT c.customer_id, o.order_id, o.amount
FROM customers c LEFT OUTER JOIN orders o
  ON c.customer_id = o.customer_id AND o.amount > 100;
INSERT INTO sql_example_result
SELECT 'JN03A', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN orders o
  ON c.customer_id = o.customer_id AND o.amount > 100;

-- JN03B. WHERE로 옮긴 같은 조건 - null-rejecting predicate, 보존행까지 제거
SELECT c.customer_id, o.order_id, o.amount
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.amount > 100;
INSERT INTO sql_example_result
SELECT 'JN03B', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.amount > 100;

-- ===================== D. COUNT(*)와 COUNT(우측열) =====================

SELECT COUNT(*) AS cnt_star, COUNT(o.order_id) AS cnt_key, COUNT(o.amount) AS cnt_col
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id;

-- JN04A. COUNT(*)
INSERT INTO sql_example_result
SELECT 'JN04A', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id;

-- JN04B. COUNT(o.order_id) - NOT NULL 보장 키
INSERT INTO sql_example_result
SELECT 'JN04B', 1, COUNT(o.order_id), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id;

-- JN04C. COUNT(o.amount) - nullable 일반열
INSERT INTO sql_example_result
SELECT 'JN04C', 1, COUNT(o.amount), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id;

-- ===================== E. 안전한 안티조인 3종 비교 =====================

-- JN05A. LEFT JOIN + IS NULL(정상)
SELECT c.customer_id
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
INSERT INTO sql_example_result
SELECT 'JN05A', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- JN05B. NOT EXISTS(정상)
SELECT c.customer_id
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
INSERT INTO sql_example_result
SELECT 'JN05B', 1, COUNT(*), NULL, GETDATE()
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);

-- JN05C. NOT IN(함정 - 고아 주문의 NULL customer_id 때문에 깨짐)
SELECT c.customer_id
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM orders o);
INSERT INTO sql_example_result
SELECT 'JN05C', 1, COUNT(*), NULL, GETDATE()
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM orders o);

-- JN05D. NOT IN 안전 대안(서브쿼리에서 NULL 제거)
SELECT c.customer_id
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM orders o WHERE o.customer_id IS NOT NULL);
INSERT INTO sql_example_result
SELECT 'JN05D', 1, COUNT(*), NULL, GETDATE()
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM orders o WHERE o.customer_id IS NOT NULL);

-- ===================== F. 안티조인에서 검사 열을 잘못 선택하는 경우 =====================

-- JN06A. 올바른 검사열 - order_id IS NULL
SELECT c.customer_id
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
INSERT INTO sql_example_result
SELECT 'JN06A', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- JN06B. 잘못된 검사열 - amount IS NULL(주문없음/금액NULL 상태 혼합)
SELECT c.customer_id, o.order_id, o.amount
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.amount IS NULL;
INSERT INTO sql_example_result
SELECT 'JN06B', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.amount IS NULL;

-- ===================== G. 집계와 OUTER JOIN =====================
-- Oracle의 NVL 대신 SQL Server는 ISNULL을 쓴다(둘 다 2개 인수 고정).

-- JN07A. 실제 합계 0(C3) - raw_sum부터 NULL이 아니다
SELECT c.customer_id, SUM(o.amount) AS raw_sum, ISNULL(SUM(o.amount), 0) AS safe_sum
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '0054556ea954a76ad6f9c4ba79d34a98'
GROUP BY c.customer_id;
INSERT INTO sql_example_result
SELECT 'JN07A', 1, ISNULL(SUM(o.amount), 0),
       CASE WHEN SUM(o.amount) IS NULL THEN 'RAW_NULL' ELSE 'RAW_ZERO' END, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '0054556ea954a76ad6f9c4ba79d34a98'
GROUP BY c.customer_id;

-- JN07B. 주문없어 합계 NULL(C5) - 최종값은 JN07A와 같은 0이지만 원본은 NULL
SELECT c.customer_id, SUM(o.amount) AS raw_sum, ISNULL(SUM(o.amount), 0) AS safe_sum
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '006496598c918064dc19eef95e5e47f8'
GROUP BY c.customer_id;
INSERT INTO sql_example_result
SELECT 'JN07B', 1, ISNULL(SUM(o.amount), 0),
       CASE WHEN SUM(o.amount) IS NULL THEN 'RAW_NULL' ELSE 'RAW_ZERO' END, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '006496598c918064dc19eef95e5e47f8'
GROUP BY c.customer_id;

-- ===================== H. JOIN 결과의 GROUP BY NULL =====================

-- JN08A. 왼쪽 고객별 그룹 - c.customer_id
SELECT c.customer_id, COUNT(*) AS cnt
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;
INSERT INTO sql_example_result
SELECT 'JN08A', 1, COUNT(*), NULL, GETDATE()
FROM (
    SELECT c.customer_id
    FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
) t;

-- JN08B. 우측 조인키별 그룹 - o.customer_id(NULL 그룹 병합)
SELECT o.customer_id, COUNT(*) AS cnt
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY o.customer_id;
INSERT INTO sql_example_result
SELECT 'JN08B', 1, COUNT(*), NULL, GETDATE()
FROM (
    SELECT o.customer_id
    FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY o.customer_id
) t;

-- JN08C. 병합된 NULL 그룹의 실제 크기
SELECT COUNT(*) AS null_group_size
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
INSERT INTO sql_example_result
SELECT 'JN08C', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

-- ===================== I. FULL OUTER JOIN과 통합 키 =====================

SELECT COALESCE(c.sales_region, r.sales_region) AS unified_region,
       c.customer_id, c.sales_region AS c_region, r.region_id, r.sales_region AS r_region
FROM customers c FULL OUTER JOIN regions r ON c.sales_region = r.sales_region;

-- JN09. FULL OUTER JOIN 전체 행 수
INSERT INTO sql_example_result
SELECT 'JN09', 1, COUNT(*), NULL, GETDATE()
FROM customers c FULL OUTER JOIN regions r ON c.sales_region = r.sales_region;

-- JN09B. 통합 키(COALESCE)가 NULL인 행
INSERT INTO sql_example_result
SELECT 'JN09B', 1, COUNT(*), NULL, GETDATE()
FROM customers c FULL OUTER JOIN regions r ON c.sales_region = r.sales_region
WHERE COALESCE(c.sales_region, r.sales_region) IS NULL;

-- ===================== J. USING과 NULL =====================
-- *** SQL Server는 USING을 지원하지 않는다. Oracle의 USING (sales_region)을
-- ON customers.sales_region = regions.sales_region 으로만 표현할 수 있다.
-- USING도 결국 등가조인이므로 결과는 JN01A와 동일해야 한다(5행). ***
SELECT c.customer_id, c.sales_region, r.manager_name
FROM customers c JOIN regions r ON c.sales_region = r.sales_region;
INSERT INTO sql_example_result
SELECT 'JN10', 1, COUNT(*), NULL, GETDATE()
FROM customers c JOIN regions r ON c.sales_region = r.sales_region;

-- ===================== K. 비등가 조인과 NULL(BETWEEN, 경계값) =====================

-- JN11A. INNER JOIN(BETWEEN)
SELECT s.customer_id, s.total_spent, b.band
FROM customer_spend s JOIN spend_band b ON s.total_spent BETWEEN b.lo AND b.hi;
INSERT INTO sql_example_result
SELECT 'JN11A', 1, COUNT(*), NULL, GETDATE()
FROM customer_spend s JOIN spend_band b ON s.total_spent BETWEEN b.lo AND b.hi;

-- JN11B. LEFT JOIN(BETWEEN) - 미매칭 보존
SELECT s.customer_id, s.total_spent, b.band
FROM customer_spend s LEFT OUTER JOIN spend_band b ON s.total_spent BETWEEN b.lo AND b.hi;
INSERT INTO sql_example_result
SELECT 'JN11B', 1, COUNT(*), NULL, GETDATE()
FROM customer_spend s LEFT OUTER JOIN spend_band b ON s.total_spent BETWEEN b.lo AND b.hi;

-- ===================== L. 복합 조인 키 일부가 NULL인 경우 =====================

-- JN12. 복합키 INNER JOIN
SELECT o.order_id, o.customer_id, o.order_date, e.event_id, e.event_type
FROM orders o JOIN order_events e
  ON o.customer_id = e.customer_id AND o.order_date = e.event_date;
INSERT INTO sql_example_result
SELECT 'JN12', 1, COUNT(*), NULL, GETDATE()
FROM orders o JOIN order_events e
  ON o.customer_id = e.customer_id AND o.order_date = e.event_date;

-- JN12B. 복합키 LEFT JOIN - ORDERS 전부 보존
SELECT o.order_id, e.event_id
FROM orders o LEFT OUTER JOIN order_events e
  ON o.customer_id = e.customer_id AND o.order_date = e.event_date;
INSERT INTO sql_example_result
SELECT 'JN12B', 1, COUNT(*), NULL, GETDATE()
FROM orders o LEFT OUTER JOIN order_events e
  ON o.customer_id = e.customer_id AND o.order_date = e.event_date;

-- ===================== M. CROSS JOIN과 NULL(대조 전용) =====================

-- JN13. CROSS JOIN - CUSTOMERS(7) x REGIONS(4) = 28, JN01A(5행)와 대조
SELECT COUNT(*) AS cnt FROM customers CROSS JOIN regions;
INSERT INTO sql_example_result
SELECT 'JN13', 1, COUNT(*), NULL, GETDATE() FROM customers CROSS JOIN regions;

-- ===================== N. Oracle (+)와 SQL Server 대응 =====================
-- *** SQL Server는 (+) 문법이 없다. Oracle의
--   c.customer_id = o.customer_id(+) AND o.amount > 100
-- 은 SQL Server에서 LEFT JOIN ... WHERE o.amount > 100 으로만 표현할 수 있다.
-- 이 SQL은 JN03B와 완전히 동일하다 - SQL Server의 LEFT JOIN은 애초에 (+) 같은
-- "일부만 외부조인" 표시가 없으므로, WHERE에 우측 조건을 쓰는 순간 그대로
-- null-rejecting predicate 함정이 재현된다. ***
SELECT c.customer_id, o.amount
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.amount > 100;
INSERT INTO sql_example_result
SELECT 'JN14', 1, COUNT(*), NULL, GETDATE()
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.amount > 100;
