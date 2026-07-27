-- JOIN×NULL 통합 예제 실행 (Oracle)
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- 각 예제는 조회용 SELECT와 sql_example_result에 1행을 남기는 INSERT로
-- 구성된다. 재실행해도 중복이 쌓이지 않도록 이 예제들의 example_id 범위를
-- 먼저 지운다.

DELETE FROM sql_example_result WHERE example_id LIKE 'JN%';
COMMIT;

-- =====================================================================
-- JN01. 등가조인 키에 NULL이 있으면 매칭 안 됨
--   SALES_REGION이 NULL인 고객(5번째)은 ON c.sales_region = r.sales_region이
--   "NULL = 'SUL'"류 비교가 되어 UNKNOWN이 되므로 결코 매칭되지 않는다.
--   REGION_LOOKUP에 NULL 키를 넣어봐도 소용없다 - NULL은 NULL과도 매칭되지 않는다.
-- 예상 결과: 4행 (5명 중 권역 미배정 1명만 제외)
-- =====================================================================
SELECT c.customer_id, c.sales_region, r.manager_name
FROM customers c JOIN region_lookup r ON c.sales_region = r.sales_region;

INSERT INTO sql_example_result
SELECT 'JN01', 1, COUNT(*), NULL, SYSDATE
FROM customers c JOIN region_lookup r ON c.sales_region = r.sales_region;

-- =====================================================================
-- JN02. LEFT OUTER JOIN이 만드는 NULL
--   고객1(주문2건)+고객2(1건)+고객3(0건->NULL로 보존)+고객4(1건)+고객5(0건->NULL로 보존)
-- 예상 결과: 6행 (2+1+1+1+1)
-- =====================================================================
SELECT c.customer_id, o.order_id, o.amount
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id;

INSERT INTO sql_example_result
SELECT 'JN02', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id;

-- =====================================================================
-- JN03. COUNT(*) vs COUNT(우측열)
--   COUNT(*)는 미매칭으로 NULL 패딩된 행도 그대로 센다(6).
--   COUNT(o.order_id)는 실제로 주문이 매칭된 행만 센다(4) - 고아 주문(O5)은
--   애초에 이 LEFT JOIN에서 등장하지 않으므로 4에 영향을 주지 않는다.
-- 예상 결과: COUNT(*)=6(actual_row_count), COUNT(order_id)=4(actual_numeric_value)
-- =====================================================================
SELECT COUNT(*) AS cnt_star, COUNT(o.order_id) AS cnt_col
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id;

INSERT INTO sql_example_result
SELECT 'JN03', COUNT(*), COUNT(o.order_id), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id;

-- =====================================================================
-- JN04. OUTER JOIN 후 WHERE로 보존행 제거 함정
--   LEFT JOIN이 고객3,5(주문없음)와 고객1의 O2(금액NULL)를 보존했지만,
--   WHERE o.amount > 100은 이 모든 NULL 행을 UNKNOWN으로 걸러낸다.
--   결국 실제 조건을 만족하는 매칭 행(O3=200, O4=150)만 남는다.
-- 예상 결과: 2행
-- =====================================================================
SELECT c.customer_id, o.amount
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE o.amount > 100;

INSERT INTO sql_example_result
SELECT 'JN04', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE o.amount > 100;

-- =====================================================================
-- JN05. LEFT JOIN + IS NULL 안티조인(정상 동작)
--   "주문이 한 건도 없는 고객"을 찾는 올바른 방법. 고아 주문(O5, customer_id
--   NULL)은 이 LEFT JOIN에서 애초에 어느 고객과도 연결되지 않으므로 결과에
--   영향을 주지 않는다.
-- 예상 결과: 2행 (고객3, 고객5)
-- =====================================================================
SELECT c.customer_id
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

INSERT INTO sql_example_result
SELECT 'JN05', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- =====================================================================
-- JN06. NOT IN 서브쿼리 함정 - JN05와 "같은 질문"에 대한 잘못된 방법
--   CUSTOMER_ORDERS.customer_id 목록에는 고아 주문(O5)의 NULL이 섞여 있다.
--   NOT IN은 이 목록과 "AND로 묶인 <> 비교"와 같으므로, 목록에 NULL이 있으면
--   비교 전체가 UNKNOWN이 되어 어떤 고객도 결과에 나오지 못한다.
-- 예상 결과: 0행 (직관적으로는 고객3,5가 나와야 할 것 같지만 실제로는 0행 -
--   JN05의 2행이 정답이고 이 결과가 오답이라는 것이 이 예제의 핵심)
-- =====================================================================
SELECT c.customer_id
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM customer_orders o);

INSERT INTO sql_example_result
SELECT 'JN06', COUNT(*), NULL, NULL, SYSDATE
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM customer_orders o);

-- =====================================================================
-- JN07. COALESCE로 미매칭 집계값 기본값 치환
--   고객3은 주문이 없으므로 SUM(o.amount)은 NULL이다. 보고서에서는 보통
--   "0원"으로 보여주고 싶을 때 COALESCE를 쓴다.
-- 예상 결과: 0 (COALESCE(NULL, 0))
-- =====================================================================
SELECT c.customer_id, SUM(o.amount) AS raw_sum, COALESCE(SUM(o.amount), 0) AS safe_sum
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '0054556ea954a76ad6f9c4ba79d34a98'
GROUP BY c.customer_id;

INSERT INTO sql_example_result
SELECT 'JN07', 1, COALESCE(SUM(o.amount), 0), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '0054556ea954a76ad6f9c4ba79d34a98'
GROUP BY c.customer_id;

-- =====================================================================
-- JN08. JOIN 결과 집계에서 NULL 제외 (AVG)
--   고객1의 주문 금액은 (100, NULL)이다. AVG는 NULL을 분자·분모 모두에서
--   제외하므로 결과는 100이지 50이 아니다.
-- 예상 결과: 100
-- =====================================================================
SELECT c.customer_id, AVG(o.amount) AS avg_amount
FROM customers c JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '00331de1659c7f4fb660c8810e6de3f5'
GROUP BY c.customer_id;

INSERT INTO sql_example_result
SELECT 'JN08', 1, AVG(o.amount), NULL, SYSDATE
FROM customers c JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '00331de1659c7f4fb660c8810e6de3f5'
GROUP BY c.customer_id;

-- =====================================================================
-- JN09. LEFT JOIN + GROUP BY의 NULL 그룹
--   미매칭 고객(고객3,5)의 O.CUSTOMER_ID는 둘 다 NULL이며, GROUP BY는 이
--   NULL들을 하나의 그룹으로 묶는다.
-- 예상 결과: 4그룹 (고객1,2,4 각자의 그룹 + 미매칭 NULL 그룹 1개)
-- =====================================================================
SELECT o.customer_id, COUNT(*) AS cnt
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
GROUP BY o.customer_id;

INSERT INTO sql_example_result
SELECT 'JN09', 1, COUNT(*), NULL, SYSDATE
FROM (
    SELECT o.customer_id
    FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
    GROUP BY o.customer_id
);

-- =====================================================================
-- JN10. FULL OUTER JOIN + COALESCE 키 병합
--   CUSTOMERS와 CUSTOMER_LOYALTY는 고객이 2명만 겹친다. FULL OUTER JOIN은
--   양쪽 미일치 행도 모두 보존하지만, 그 결과 CUSTOMER_ID 열 하나만으로는
--   행마다 어느 쪽 값이 NULL일지 알 수 없다 - COALESCE(c.id, l.id)로 항상
--   NULL이 아닌 "통합 키"를 만든다.
-- 예상 결과: 7행 (공통 2 + CUSTOMERS 전용 3 + LOYALTY 전용 2), 통합키는 전부 NOT NULL
-- =====================================================================
SELECT COALESCE(c.customer_id, l.customer_id) AS unified_id, c.customer_id AS c_id, l.customer_id AS l_id
FROM customers c FULL OUTER JOIN customer_loyalty l ON c.customer_id = l.customer_id;

INSERT INTO sql_example_result
SELECT 'JN10', COUNT(*), NULL, NULL, SYSDATE
FROM customers c FULL OUTER JOIN customer_loyalty l ON c.customer_id = l.customer_id;

-- =====================================================================
-- JN11. USING과 NULL 키
--   USING(SALES_REGION)도 결국 내부적으로 등가 조인이므로 JN01과 동일하게
--   SALES_REGION이 NULL인 고객은 제외된다.
-- 예상 결과: 4행 (JN01과 동일)
-- =====================================================================
SELECT customer_id, sales_region, manager_name
FROM customers JOIN region_lookup USING (sales_region);

INSERT INTO sql_example_result
SELECT 'JN11', 1, COUNT(*), NULL, SYSDATE
FROM customers JOIN region_lookup USING (sales_region);

-- =====================================================================
-- JN12. 비등가조인(BETWEEN) 경계값 NULL
--   두 번째 고객의 TOTAL_SPENT가 NULL이면 "NULL BETWEEN lo AND hi"는
--   UNKNOWN이 되어 어느 구간과도 매칭되지 않는다.
-- 예상 결과: 4행 (5명 중 TOTAL_SPENT가 NULL인 1명만 제외)
-- =====================================================================
SELECT s.customer_id, s.total_spent, b.band
FROM customer_spend s JOIN spend_band b ON s.total_spent BETWEEN b.lo AND b.hi;

INSERT INTO sql_example_result
SELECT 'JN12', 1, COUNT(*), NULL, SYSDATE
FROM customer_spend s JOIN spend_band b ON s.total_spent BETWEEN b.lo AND b.hi;

-- =====================================================================
-- JN13. CROSS JOIN은 NULL과 무관하게 행수 유지
--   CUSTOMERS 5행(그 중 1행은 SALES_REGION NULL) x REGION_LOOKUP 3행 = 15행.
--   카티션 곱은 조건 자체가 없으므로 NULL이 몇 개 있든 행 수에 영향이 없다 -
--   JN01(등가조인, NULL 키 제외돼 4행)과 정확히 대조된다.
-- 예상 결과: 15행
-- =====================================================================
SELECT COUNT(*) AS cnt FROM customers CROSS JOIN region_lookup;

INSERT INTO sql_example_result
SELECT 'JN13', 1, COUNT(*), NULL, SYSDATE FROM customers CROSS JOIN region_lookup;

-- =====================================================================
-- JN14. Oracle (+) - 반대편 필터 조건에 (+)가 빠지면 OUTER JOIN이 무력화됨
--   c.customer_id = o.customer_id(+) 자체는 LEFT JOIN처럼 고객을 보존하려
--   하지만, 뒤이은 AND o.amount > 100에는 (+)가 없다. 이 조건이 NULL(미매칭)
--   행을 전부 걸러내 결과적으로 INNER JOIN과 똑같아진다 - JN04(ANSI 문법의
--   같은 함정)와 결과가 동일해야 한다.
-- 예상 결과: 2행 (JN04와 동일)
-- =====================================================================
SELECT c.customer_id, o.amount
FROM customers c, customer_orders o
WHERE c.customer_id = o.customer_id(+)
  AND o.amount > 100;

INSERT INTO sql_example_result
SELECT 'JN14', 1, COUNT(*), NULL, SYSDATE
FROM customers c, customer_orders o
WHERE c.customer_id = o.customer_id(+)
  AND o.amount > 100;

COMMIT;
