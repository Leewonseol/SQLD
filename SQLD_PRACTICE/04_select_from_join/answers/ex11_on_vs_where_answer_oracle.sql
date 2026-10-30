-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex11_on_vs_where | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex11_on_vs_where.md
-- =====================================================================

PROMPT == [G1] 고객별 취소 금액(0 포함)
-- status 조건을 WHERE 로 옮기면 C02·C04 가 사라진다. SUM 은 짝이 없는 행에서 NULL 이므로 NVL/ISNULL 로 0 처리.
CREATE OR REPLACE VIEW ans04_11_g1 (cust_id, canceled_amt) AS
SELECT c.cust_id, NVL(SUM(o.amount), 0)
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id AND o.status = 'CANCELED'
GROUP BY c.cust_id;
CREATE OR REPLACE VIEW exp04_11_g1 (cust_id, canceled_amt) AS
-- (cust_id, canceled_amt)
SELECT 'C01', 12000 FROM dual
UNION ALL SELECT 'C02', 0 FROM dual
UNION ALL SELECT 'C03', 8000 FROM dual
UNION ALL SELECT 'C04', 0 FROM dual;
EXEC lab_check('04-ex11-G1', 'ANS04_11_G1', 'EXP04_11_G1')
SELECT * FROM ans04_11_g1 ORDER BY 1, 2;

PROMPT == [G2] GOLD 고객의 PAID 주문
-- 기준 테이블 조건(grade)은 WHERE, 짝짓기 조건(status)은 ON. 반대로 두면 각각 C01·C04 가 남거나 C03 이 사라진다.
CREATE OR REPLACE VIEW ans04_11_g2 (cust_id, order_id) AS
SELECT c.cust_id, o.order_id
FROM cust c LEFT JOIN orders o ON c.cust_id = o.cust_id AND o.status = 'PAID'
WHERE c.grade = 'GOLD';
CREATE OR REPLACE VIEW exp04_11_g2 (cust_id, order_id) AS
-- (cust_id, order_id)
SELECT 'C02', 1003 FROM dual
UNION ALL SELECT 'C03', CAST(NULL AS NUMBER) FROM dual;
EXEC lab_check('04-ex11-G2', 'ANS04_11_G2', 'EXP04_11_G2')
SELECT * FROM ans04_11_g2 ORDER BY 1, 2;
