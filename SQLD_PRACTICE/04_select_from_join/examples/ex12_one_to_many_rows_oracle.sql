-- ex12 1:N 관계에서 결과 행 수 증가와 중복 합계 (요구목록 §9)  | Oracle   데이터: [가상] ORDERS(4) - ORDER_LINE(7)
PROMPT == [Q1] 주문(1) - 주문상세(N) 조인: 결과 행 수 = 주문상세 행 수 7
SELECT o.order_id, o.cust_id, o.amount, l.line_no, l.item
FROM orders o JOIN order_line l ON o.order_id = l.order_id
ORDER BY o.order_id, l.line_no;

PROMPT == [Q2] 함정: 조인 후 주문 금액(1쪽 값)을 SUM 하면 상세 행 수만큼 중복 합산된다
SELECT o.cust_id, SUM(o.amount) AS wrong_sum
FROM orders o JOIN order_line l ON o.order_id = l.order_id
GROUP BY o.cust_id
ORDER BY o.cust_id;

PROMPT == [Q3] 바른 합계: 1쪽 테이블만으로 집계
SELECT cust_id, SUM(amount) AS right_sum FROM orders GROUP BY cust_id ORDER BY cust_id;

PROMPT == [Q4] 상세 정보가 함께 필요하면 N쪽을 먼저 집계한 뒤(1행으로 만든 뒤) 조인
SELECT o.cust_id, SUM(o.amount) AS amount_sum, SUM(l.line_cnt) AS line_cnt
FROM orders o JOIN (SELECT order_id, COUNT(*) AS line_cnt FROM order_line GROUP BY order_id) l
  ON o.order_id = l.order_id
GROUP BY o.cust_id
ORDER BY o.cust_id;

PROMPT == [Q5] 고객-주문 조인 행 수: 주문 4행. 주문 없는 C04 는 빠지고 C01 은 두 번 나온다
SELECT c.cust_id, c.cust_name, o.order_id
FROM cust c JOIN orders o ON c.cust_id = o.cust_id
ORDER BY c.cust_id, o.order_id;
