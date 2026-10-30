-- ex09 기본키가 2개 이상인 테이블과 서브쿼리 (PDF E-23)  | SQL Server
PRINT N'== [Q1] 두 키 모두 비교';
SELECT a.order_id, a.product_id, a.quantity, a.price,
       (SELECT SUM(b.quantity * b.price) FROM order_items b
        WHERE b.order_id = a.order_id AND b.product_id = a.product_id) AS total_amount
FROM order_items a ORDER BY a.order_id, a.product_id;
PRINT N'== [Q2] 키 하나만 비교';
SELECT a.order_id, a.product_id,
       (SELECT SUM(b.quantity * b.price) FROM order_items b WHERE b.order_id = a.order_id) AS order_total
FROM order_items a ORDER BY a.order_id, a.product_id;
GO
PRINT N'== [Q3] 키 하나 + 집계 없음 -> 오류';
GO
-- @expect-error: MSG-512
SELECT a.order_id, a.product_id, (SELECT b.quantity FROM order_items b WHERE b.order_id = a.order_id) AS q FROM order_items a;
GO
