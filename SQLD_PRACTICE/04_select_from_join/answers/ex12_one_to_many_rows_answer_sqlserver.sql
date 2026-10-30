-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex12_one_to_many_rows | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex12_one_to_many_rows.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 고객별 금액 합계와 상세 행 수';
GO
CREATE OR ALTER VIEW ans04_12_g1 (cust_id, amount_sum, line_cnt) AS
SELECT o.cust_id, SUM(o.amount), SUM(l.cnt)
FROM orders o JOIN (SELECT order_id, COUNT(*) AS cnt FROM order_line GROUP BY order_id) l ON o.order_id = l.order_id
GROUP BY o.cust_id;
GO
CREATE OR ALTER VIEW exp04_12_g1 (cust_id, amount_sum, line_cnt) AS
SELECT * FROM (VALUES (N'C01', 42000, 4),
       (N'C02', 50000, 2),
       (N'C03', 8000, 1)) v(cust_id, amount_sum, line_cnt);
GO
EXEC lab_check N'04-ex12-G1', N'ans04_12_g1', N'exp04_12_g1';
SELECT * FROM ans04_12_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] ''펜'' 주문 고객 수';
-- DISTINCT 를 빼면 3(C01 이 1001·1002 두 주문에서 '펜'을 샀다).
GO
CREATE OR ALTER VIEW ans04_12_g2 (cust_cnt) AS
SELECT COUNT(DISTINCT o.cust_id) FROM orders o JOIN order_line l ON o.order_id = l.order_id WHERE l.item = N'펜';
GO
CREATE OR ALTER VIEW exp04_12_g2 (cust_cnt) AS
SELECT * FROM (VALUES (2)) v(cust_cnt);
GO
EXEC lab_check N'04-ex12-G2', N'ans04_12_g2', N'exp04_12_g2';
SELECT * FROM ans04_12_g2 ORDER BY 1;
GO
