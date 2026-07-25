-- NULL·빈 문자열 처리 데모 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요
--
-- 주의: 이 파일도 오라클 버전과 마찬가지로 실제 Olist 데이터를 다루지 않는다.
-- mini_contacts는 NULL 처리 차이만 보여주기 위한 합성 테스트 테이블이다.

IF OBJECT_ID('mini_contacts', 'U') IS NOT NULL DROP TABLE mini_contacts;

CREATE TABLE mini_contacts (
    customer_ref VARCHAR(10),
    phone        VARCHAR(20)
);

INSERT INTO mini_contacts (customer_ref, phone) VALUES
    ('C1', '010-1234-5678'),
    ('C2', NULL),
    ('C3', '');   -- SQL Server: 빈 문자열은 NULL과 별개의 값으로 저장됨

SELECT customer_ref, phone,
       CASE WHEN phone IS NULL THEN 'Y' ELSE 'N' END AS is_null,
       CASE WHEN phone = '' THEN 'Y' ELSE 'N' END AS equals_empty_string
FROM mini_contacts
ORDER BY customer_ref;
-- 예상(Oracle과 정반대):
--   C2: is_null='Y', equals_empty_string='N'
--   C3: is_null='N', equals_empty_string='Y'  <- Oracle에서는 C3도 is_null='Y'였다.
-- 즉 "결측 고객 찾기" 쿼리를 Oracle 기준(IS NULL만 확인)으로 SQL Server에 그대로
-- 옮기면, 빈 문자열로 입력된 행을 놓치는 사고가 난다.
