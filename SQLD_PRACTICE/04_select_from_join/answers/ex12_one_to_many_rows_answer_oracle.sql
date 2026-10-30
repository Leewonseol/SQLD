-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex12_one_to_many_rows | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex12_one_to_many_rows.md
-- =====================================================================

PROMPT == [G1] 고객별 금액 합계와 상세 행 수
CREATE OR REPLACE VIEW ans04_12_g1 (cust_id, amount_sum, line_cnt) AS
SELECT o.cust_id, SUM(o.amount), SUM(l.cnt)
FROM orders o JOIN (SELECT order_id, COUNT(*) AS cnt FROM order_line GROUP BY order_id) l ON o.order_id = l.order_id
GROUP BY o.cust_id;
CREATE OR REPLACE VIEW exp04_12_g1 (cust_id, amount_sum, line_cnt) AS
-- (cust_id, amount_sum, line_cnt)
SELECT 'C01', 42000, 4 FROM dual
UNION ALL SELECT 'C02', 50000, 2 FROM dual
UNION ALL SELECT 'C03', 8000, 1 FROM dual;
EXEC lab_check('04-ex12-G1', 'ANS04_12_G1', 'EXP04_12_G1')
SELECT * FROM ans04_12_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] '펜' 주문 고객 수
-- DISTINCT 를 빼면 3(C01 이 1001·1002 두 주문에서 '펜'을 샀다).
CREATE OR REPLACE VIEW ans04_12_g2 (cust_cnt) AS
SELECT COUNT(DISTINCT o.cust_id) FROM orders o JOIN order_line l ON o.order_id = l.order_id WHERE l.item = '펜';
CREATE OR REPLACE VIEW exp04_12_g2 (cust_cnt) AS
-- (cust_cnt)
SELECT 2 FROM dual;
EXEC lab_check('04-ex12-G2', 'ANS04_12_G2', 'EXP04_12_G2')
SELECT * FROM ans04_12_g2 ORDER BY 1;
