-- NULL·빈 문자열 처리 데모 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요
--
-- 주의: 이 파일은 올바른 Olist 데이터를 다루지 않는다. 00-데이터사전/README.md에서
-- 이미 확인했듯 실제 olist_customers_dataset.csv에는 NULL도 빈 문자열도 없다.
-- 아래 mini_contacts는 오직 Oracle과 SQL Server의 NULL 처리 차이를 보여주기 위해
-- 새로 만든 작은 합성 테스트 테이블이며, 실제 Olist 데이터가 아니다.

DROP TABLE mini_contacts;

CREATE TABLE mini_contacts (
    customer_ref VARCHAR2(10),
    phone        VARCHAR2(20)
);

INSERT INTO mini_contacts VALUES ('C1', '010-1234-5678');
INSERT INTO mini_contacts VALUES ('C2', NULL);
INSERT INTO mini_contacts VALUES ('C3', '');   -- Oracle: 빈 문자열은 NULL로 저장됨
COMMIT;

SELECT customer_ref, phone,
       CASE WHEN phone IS NULL THEN 'Y' ELSE 'N' END AS is_null,
       CASE WHEN phone = '' THEN 'Y' ELSE 'N' END AS equals_empty_string  -- 항상 'N'만 나옴
                                                                            -- (= 연산자로 NULL 비교 불가)
FROM mini_contacts
ORDER BY customer_ref;
-- 예상: C3의 phone은 화면상 빈 값이지만 is_null='Y' (NULL로 저장되었기 때문).
-- equals_empty_string이 모든 행에서 'N'인 이유: NULL = '' 비교는 항상 UNKNOWN이라
-- CASE의 두 WHEN 모두 참이 될 수 없다(= 연산자로 NULL을 찾을 수 없다는 규칙의 실례).
