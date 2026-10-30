-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex11_on_vs_where | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex11_on_vs_where.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 고객별 취소 금액(0 포함)';
-- status 조건을 WHERE 로 옮기면 C02·C04 가 사라진다. SUM 은 짝이 없는 행에서 NULL 이므로 NVL/ISNULL 로 0 처리.
GO
CREATE OR ALTER VIEW ans04_11_g1 (cust_id, canceled_amt) AS
SELECT c.cust_id, ISNULL(SUM(o.amount), 0)
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id AND o.status = 'CANCELED'
GROUP BY c.cust_id;
GO
CREATE OR ALTER VIEW exp04_11_g1 (cust_id, canceled_amt) AS
SELECT * FROM (VALUES (N'C01', 12000),
       (N'C02', 0),
       (N'C03', 8000),
       (N'C04', 0)) v(cust_id, canceled_amt);
GO
EXEC lab_check N'04-ex11-G1', N'ans04_11_g1', N'exp04_11_g1';
SELECT * FROM ans04_11_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] GOLD 고객의 PAID 주문';
-- 기준 테이블 조건(grade)은 WHERE, 짝짓기 조건(status)은 ON. 반대로 두면 각각 C01·C04 가 남거나 C03 이 사라진다.
GO
CREATE OR ALTER VIEW ans04_11_g2 (cust_id, order_id) AS
SELECT c.cust_id, o.order_id
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id AND o.status = 'PAID'
WHERE c.grade = 'GOLD';
GO
CREATE OR ALTER VIEW exp04_11_g2 (cust_id, order_id) AS
SELECT * FROM (VALUES (N'C02', 1003),
       (N'C03', NULL)) v(cust_id, order_id);
GO
EXEC lab_check N'04-ex11-G2', N'ans04_11_g2', N'exp04_11_g2';
SELECT * FROM ans04_11_g2 ORDER BY 1, 2;
GO
