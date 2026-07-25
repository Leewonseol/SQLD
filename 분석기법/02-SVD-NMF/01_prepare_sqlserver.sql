-- 고객 x 카테고리 wide 행렬 생성 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요
-- SQL Server도 PIVOT을 네이티브로 지원하지만 컬럼명을 대괄호로 감싸야 하고, FOR 뒤의
-- 값 목록에는 'AS 별칭' 표기를 쓰지 않는다(Oracle과 PIVOT 세부 문법이 다르다).
-- 결측 조합은 Oracle과 마찬가지로 NULL이 되므로 ISNULL로 방어한다.

IF OBJECT_ID('svd_input_matrix', 'U') IS NOT NULL DROP TABLE svd_input_matrix;

SELECT
    customer_id,
    ISNULL([전자제품], 0) AS 전자제품, ISNULL([의류], 0) AS 의류, ISNULL([도서], 0) AS 도서, ISNULL([식품], 0) AS 식품,
    ISNULL([가구], 0) AS 가구, ISNULL([뷰티], 0) AS 뷰티, ISNULL([스포츠], 0) AS 스포츠, ISNULL([완구], 0) AS 완구
INTO svd_input_matrix
FROM (
    SELECT customer_id, category, amount FROM customer_category_spend
) src
PIVOT (
    SUM(amount) FOR category IN ([전자제품], [의류], [도서], [식품], [가구], [뷰티], [스포츠], [완구])
) AS p;

SELECT COUNT(*) AS n_rows, MIN(전자제품) AS min_electronics, MIN(도서) AS min_books
FROM svd_input_matrix;
