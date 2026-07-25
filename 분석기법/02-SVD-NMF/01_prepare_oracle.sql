-- 고객 x 카테고리 wide 행렬 생성 (Oracle) — 실행 상태: 실제 Oracle 검증 필요
-- Oracle은 PIVOT을 네이티브로 지원한다(11g+). 단, 특정 고객이 어떤 카테고리를 한 번도
-- 사지 않았다면 PIVOT은 0이 아니라 NULL을 채운다 - NMF는 값이 없는 게 아니라 0이어야
-- 하므로 NVL로 방어한다(SQLite의 SUM(CASE WHEN...ELSE 0)은 애초에 0을 채워 이 문제가 없었다).

DROP TABLE svd_input_matrix;

CREATE TABLE svd_input_matrix AS
SELECT
    customer_id,
    NVL(전자제품, 0) AS 전자제품, NVL(의류, 0) AS 의류, NVL(도서, 0) AS 도서, NVL(식품, 0) AS 식품,
    NVL(가구, 0) AS 가구, NVL(뷰티, 0) AS 뷰티, NVL(스포츠, 0) AS 스포츠, NVL(완구, 0) AS 완구
FROM (
    SELECT customer_id, category, amount FROM customer_category_spend
)
PIVOT (
    SUM(amount)
    FOR category IN (
        '전자제품' AS 전자제품, '의류' AS 의류, '도서' AS 도서, '식품' AS 식품,
        '가구' AS 가구, '뷰티' AS 뷰티, '스포츠' AS 스포츠, '완구' AS 완구
    )
);

SELECT COUNT(*) AS n_rows, MIN(전자제품) AS min_electronics, MIN(도서) AS min_books
FROM svd_input_matrix;
