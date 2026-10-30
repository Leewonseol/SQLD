-- ex11 LEFT JOIN 에서 ON 과 WHERE (요구목록 §9)  | SQL Server
PRINT N'== [Q1] 필터를 ON 에';
SELECT c.cust_id, c.cust_name, o.order_id, o.status
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id AND o.status = 'PAID'
ORDER BY c.cust_id;
PRINT N'== [Q2] 필터를 WHERE 에';
SELECT c.cust_id, c.cust_name, o.order_id, o.status
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id
WHERE o.status = 'PAID'
ORDER BY c.cust_id;
PRINT N'== [Q5] 왼쪽 테이블 조건을 ON 에';
SELECT c.cust_id, c.grade, o.order_id
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id AND c.grade = 'GOLD'
ORDER BY c.cust_id, o.order_id;
PRINT N'== [Q6] 주문 없는 고객';
SELECT c.cust_id, c.cust_name
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id
WHERE o.order_id IS NULL
ORDER BY c.cust_id;
PRINT N'== [Q7] 고객별 PAID 주문 수(0 포함)';
SELECT c.cust_id, COUNT(o.order_id) AS paid_cnt, COUNT(*) AS row_cnt
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id AND o.status = 'PAID'
GROUP BY c.cust_id
ORDER BY c.cust_id;
