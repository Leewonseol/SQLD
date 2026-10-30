-- ex09 서브쿼리 주의사항2: 기본키가 2개 이상인 테이블 (PDF E-23)  | Oracle  데이터: ORDER_ITEMS(구조 PDF, 값 [가상])
PROMPT == [Q1] PDF 쿼리: 두 키(order_id, product_id)를 모두 비교 -> 각 행의 금액 (자기 행 하나만 합산)
SELECT a.order_id, a.product_id, a.quantity, a.price,
       (SELECT SUM(b.quantity * b.price) FROM order_items b
        WHERE b.order_id = a.order_id AND b.product_id = a.product_id) AS total_amount
FROM order_items a ORDER BY a.order_id, a.product_id;

PROMPT == [Q2] 키 하나(order_id)만 비교 -> 같은 주문의 모든 품목이 합산되어 '주문 합계'가 된다 (의미가 바뀜)
SELECT a.order_id, a.product_id,
       (SELECT SUM(b.quantity * b.price) FROM order_items b WHERE b.order_id = a.order_id) AS order_total
FROM order_items a ORDER BY a.order_id, a.product_id;

PROMPT == [Q3] 집계 없이 단일 값을 가져오는 스칼라 서브쿼리에서 키 하나만 비교 -> 2행 이상 -> 오류
-- @expect-error: ORA-01427
SELECT a.order_id, a.product_id, (SELECT b.quantity FROM order_items b WHERE b.order_id = a.order_id) AS q FROM order_items a;
