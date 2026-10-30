-- ex11 LEFT JOIN 에서 ON 조건과 WHERE 조건의 배치 차이 (요구목록 §9)  | Oracle   데이터: [가상] CUST, ORDERS
PROMPT == [Q1] 필터를 ON 에: 고객 4명 모두 남고, PAID 주문만 짝지어진다
SELECT c.cust_id, c.cust_name, o.order_id, o.status
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id AND o.status = 'PAID'
ORDER BY c.cust_id;

PROMPT == [Q2] 필터를 WHERE 에: 짝이 없는 행(o.status 가 NULL)이 WHERE 에서 제거 -> 사실상 INNER JOIN
SELECT c.cust_id, c.cust_name, o.order_id, o.status
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id
WHERE o.status = 'PAID'
ORDER BY c.cust_id;

PROMPT == [Q3] Oracle (+) 로 Q1 과 같은 결과: 상수 조건에도 (+) 를 붙여야 한다
SELECT c.cust_id, c.cust_name, o.order_id, o.status
FROM cust c, orders o
WHERE c.cust_id = o.cust_id(+) AND o.status(+) = 'PAID'
ORDER BY c.cust_id;

PROMPT == [Q4] (+) 를 상수 조건에서 빠뜨리면 Q2 와 같아진다
SELECT c.cust_id, c.cust_name, o.order_id, o.status
FROM cust c, orders o
WHERE c.cust_id = o.cust_id(+) AND o.status = 'PAID'
ORDER BY c.cust_id;

PROMPT == [Q5] 기준(왼쪽) 테이블 조건을 ON 에 두면 왼쪽 행을 거르지 못한다: GOLD 가 아닌 고객도 그대로 남음
SELECT c.cust_id, c.grade, o.order_id
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id AND c.grade = 'GOLD'
ORDER BY c.cust_id, o.order_id;

PROMPT == [Q6] 주문이 하나도 없는 고객 (안티 조인 패턴)
SELECT c.cust_id, c.cust_name
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id
WHERE o.order_id IS NULL
ORDER BY c.cust_id;

PROMPT == [Q7] 고객별 PAID 주문 수(0 포함): COUNT(o.order_id) 는 NULL 을 세지 않는다
SELECT c.cust_id, COUNT(o.order_id) AS paid_cnt, COUNT(*) AS row_cnt
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id AND o.status = 'PAID'
GROUP BY c.cust_id
ORDER BY c.cust_id;
