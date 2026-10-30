-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex09_composite_key_subquery | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex09_composite_key_subquery.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 행 금액과 주문 합계';
GO
CREATE OR ALTER VIEW ans08_09_g1 (order_id, product_id, line_amt, order_total) AS
SELECT a.order_id, a.product_id, a.quantity * a.price,
       (SELECT SUM(b.quantity * b.price) FROM order_items b WHERE b.order_id = a.order_id)
FROM order_items a;
GO
CREATE OR ALTER VIEW exp08_09_g1 (order_id, product_id, line_amt, order_total) AS
SELECT * FROM (VALUES (1, 10, 2000, 7000),
       (1, 20, 5000, 7000),
       (2, 10, 3000, 5500),
       (2, 30, 2500, 5500),
       (3, 20, 10000, 10000)) v(order_id, product_id, line_amt, order_total);
GO
EXEC lab_check N'08-ex09-G1', N'ans08_09_g1', N'exp08_09_g1';
SELECT * FROM ans08_09_g1 ORDER BY 1, 2, 3, 4;
GO

PRINT N'== [G2] 주문별 최대 금액 품목';
-- 연관 조건은 order_id 하나(주문 단위 비교)가 맞다. product_id 까지 넣으면 자기 행과만 비교해 모든 행이 나온다.
GO
CREATE OR ALTER VIEW ans08_09_g2 (order_id, product_id) AS
SELECT a.order_id, a.product_id FROM order_items a
WHERE a.quantity * a.price = (SELECT MAX(b.quantity * b.price) FROM order_items b WHERE b.order_id = a.order_id);
GO
CREATE OR ALTER VIEW exp08_09_g2 (order_id, product_id) AS
SELECT * FROM (VALUES (1, 20),
       (2, 10),
       (3, 20)) v(order_id, product_id);
GO
EXEC lab_check N'08-ex09-G2', N'ans08_09_g2', N'exp08_09_g2';
SELECT * FROM ans08_09_g2 ORDER BY 1, 2;
GO
