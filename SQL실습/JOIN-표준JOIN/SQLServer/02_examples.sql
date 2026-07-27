-- JOIN·표준 JOIN 예제 실행 (SQL Server)
-- 대상: 깨우침/JOIN·표준 JOIN 문제 풀이표.md 의 21개 개념 순서를 그대로 따른다.
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- Oracle/02_examples.sql과 example_id·기대값은 모두 동일하다. 차이는 딱 세 곳
-- (J15 USING, J16 NATURAL JOIN, J18 Oracle (+))뿐이며, 이 세 곳은 SQL Server가
-- 지원하지 않는 문법이므로 "지원하지 않는다"고 주석으로 명시하고 ON 기반의
-- 동등 구문으로 같은 결과를 낸다.

DELETE FROM sql_example_result WHERE example_id LIKE 'J%';

-- =====================================================================
-- J01. 테이블 수
-- 예상 결과: 1행(집계행), CUSTOMERS 전체 8건
-- =====================================================================
SELECT * FROM customers;

INSERT INTO sql_example_result
SELECT 'J01', 1, COUNT(*), NULL, GETDATE() FROM customers;

-- =====================================================================
-- J02. 연결 조건 존재 여부 - 카티션 곱
-- 예상 결과: CUSTOMERS(8) x STATE_REGION(4) = 32행
-- =====================================================================
SELECT COUNT(*) AS cnt FROM customers CROSS JOIN state_region;

INSERT INTO sql_example_result
SELECT 'J02', 1, COUNT(*), NULL, GETDATE() FROM customers CROSS JOIN state_region;

-- =====================================================================
-- J03. 연결 조건 존재 여부 - 조건부 JOIN
-- 예상 결과: 8행
-- =====================================================================
SELECT c.customer_id, r.region
FROM customers c JOIN state_region r ON c.state = r.state;

INSERT INTO sql_example_result
SELECT 'J03', 1, COUNT(*), NULL, GETDATE()
FROM customers c JOIN state_region r ON c.state = r.state;

-- =====================================================================
-- J04. 카티션 곱 계산 (행수=곱, 열수=합)
-- 예상 결과: STATE_REGION(4행,2열) x REVIEW_TIER(3행,2열) = 12행, 4열
-- =====================================================================
SELECT COUNT(*) AS row_cnt, 2 + 2 AS col_cnt
FROM state_region CROSS JOIN review_tier;

INSERT INTO sql_example_result
SELECT 'J04', 1, COUNT(*), NULL, GETDATE() FROM state_region CROSS JOIN review_tier;

-- =====================================================================
-- J05. CROSS JOIN - 첨부 표준 JOIN 문제 9번 유형(A 2행, B 3행)
-- 예상 결과: 2 x 3 = 6행
-- =====================================================================
SELECT COUNT(*) AS cnt FROM sample_states CROSS JOIN sample_scores;

INSERT INTO sql_example_result
SELECT 'J05', 1, COUNT(*), NULL, GETDATE() FROM sample_states CROSS JOIN sample_scores;

-- =====================================================================
-- J06. 등가 조인
-- 예상 결과: 8행
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'J06', 1, COUNT(*), NULL, GETDATE()
FROM customers c JOIN state_region r ON c.state = r.state;

-- =====================================================================
-- J07. 비등가 조인 (TOTAL_SPENT BETWEEN LOSAL AND HISAL)
-- 예상 결과: 8행
-- =====================================================================
SELECT c.customer_id, c.total_spent, t.tier
FROM customers c JOIN spend_tier t ON c.total_spent BETWEEN t.losal AND t.hisal;

INSERT INTO sql_example_result
SELECT 'J07', 1, COUNT(*), NULL, GETDATE()
FROM customers c JOIN spend_tier t ON c.total_spent BETWEEN t.losal AND t.hisal;

-- =====================================================================
-- J08. 조인 조건과 일반 필터 조건 구분
-- 예상 결과: 4행
-- =====================================================================
SELECT c.customer_id, c.total_spent
FROM customers c JOIN state_region r ON c.state = r.state
WHERE c.total_spent > 2000;

INSERT INTO sql_example_result
SELECT 'J08', 1, COUNT(*), NULL, GETDATE()
FROM customers c JOIN state_region r ON c.state = r.state
WHERE c.total_spent > 2000;

-- =====================================================================
-- J09. 중복값에 따른 결과 행 수 증가 (실제 재구매 고객 데이터)
-- 예상 결과: 3행 (U1: 0개, U2: 1x2=2개, U3: 1x1=1개, 합계 3)
-- =====================================================================
SELECT d.customer_unique_id
FROM customer_dim d JOIN customer_orders_sample o
  ON d.customer_unique_id = o.customer_unique_id;

INSERT INTO sql_example_result
SELECT 'J09', 1, COUNT(*), NULL, GETDATE()
FROM customer_dim d JOIN customer_orders_sample o
  ON d.customer_unique_id = o.customer_unique_id;

-- =====================================================================
-- J10. INNER JOIN
-- 예상 결과: 2행 (공통 고객 Ca, Cb만 유지)
-- =====================================================================
SELECT m.customer_id, m.city, r.subject, r.scoreval
FROM customer_master m JOIN customer_review r ON m.customer_id = r.customer_id;

INSERT INTO sql_example_result
SELECT 'J10', 1, COUNT(*), NULL, GETDATE()
FROM customer_master m JOIN customer_review r ON m.customer_id = r.customer_id;

-- =====================================================================
-- J11. LEFT OUTER JOIN
-- 예상 결과: 3행 (MASTER 3명 전원 보존, Cc는 리뷰 열이 NULL)
-- =====================================================================
SELECT m.customer_id, r.scoreval
FROM customer_master m LEFT OUTER JOIN customer_review r ON m.customer_id = r.customer_id;

INSERT INTO sql_example_result
SELECT 'J11', 1, COUNT(*), NULL, GETDATE()
FROM customer_master m LEFT OUTER JOIN customer_review r ON m.customer_id = r.customer_id;

-- =====================================================================
-- J12. RIGHT OUTER JOIN
-- 예상 결과: 3행 (REVIEW 3건 보존, Cd는 MASTER쪽 열이 NULL)
-- =====================================================================
SELECT m.customer_id AS master_id, r.customer_id AS review_id, r.scoreval
FROM customer_master m RIGHT OUTER JOIN customer_review r ON m.customer_id = r.customer_id;

INSERT INTO sql_example_result
SELECT 'J12', 1, COUNT(*), NULL, GETDATE()
FROM customer_master m RIGHT OUTER JOIN customer_review r ON m.customer_id = r.customer_id;

-- =====================================================================
-- J13. FULL OUTER JOIN - 첨부 표준 JOIN 문제 8번 그대로(A:SP,RJ / B:RJ,MG)
-- 예상 결과: 3행
-- =====================================================================
SELECT a.state AS a_state, b.state AS b_state
FROM full_a a FULL OUTER JOIN full_b b ON a.state = b.state;

INSERT INTO sql_example_result
SELECT 'J13', 1, COUNT(*), NULL, GETDATE()
FROM full_a a FULL OUTER JOIN full_b b ON a.state = b.state;

-- =====================================================================
-- J13B. FULL OUTER JOIN 추가 연습(CUSTOMER_MASTER/CUSTOMER_REVIEW)
-- 예상 결과: 4행
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'J13B', 1, COUNT(*), NULL, GETDATE()
FROM customer_master m FULL OUTER JOIN customer_review r ON m.customer_id = r.customer_id;

-- =====================================================================
-- J14. ON - 열 이름이 서로 달라도 가능 (CUSTOMERS.STATE = STATE_REGION2.STATE_CODE)
-- 예상 결과: 8행
-- =====================================================================
SELECT c.customer_id, r2.region_name
FROM customers c JOIN state_region2 r2 ON c.state = r2.state_code;

INSERT INTO sql_example_result
SELECT 'J14', 1, COUNT(*), NULL, GETDATE()
FROM customers c JOIN state_region2 r2 ON c.state = r2.state_code;

-- =====================================================================
-- J15. USING - SQL Server는 USING을 지원하지 않는다.
--   *** 개념적 대응: Oracle의 USING (customer_id)는 SQL Server에서
--   ON customer_master.customer_id = customer_review.customer_id 로만
--   표현할 수 있다(공통 열 이름을 한 번만 쓰는 축약 문법 자체가 없다). ***
-- 예상 결과: 2행 (Oracle의 USING 결과와 동일해야 함)
-- =====================================================================
SELECT m.customer_id, m.city, r.subject, r.scoreval
FROM customer_master m JOIN customer_review r ON m.customer_id = r.customer_id;

INSERT INTO sql_example_result
SELECT 'J15', 1, COUNT(*), NULL, GETDATE()
FROM customer_master m JOIN customer_review r ON m.customer_id = r.customer_id;

-- =====================================================================
-- J16. NATURAL JOIN - SQL Server는 NATURAL JOIN을 지원하지 않는다.
--   *** 개념적 대응: 공통 열(customer_id) 하나를 자동으로 찾아 등가 조인하는
--   NATURAL JOIN은 SQL Server에 없으며, 반드시 ON으로 직접 명시해야 한다. ***
-- 예상 결과: 2행 (Oracle의 NATURAL JOIN 결과와 동일해야 함)
-- =====================================================================
SELECT m.customer_id, m.city, r.subject, r.scoreval
FROM customer_master m JOIN customer_review r ON m.customer_id = r.customer_id;

INSERT INTO sql_example_result
SELECT 'J16', 1, COUNT(*), NULL, GETDATE()
FROM customer_master m JOIN customer_review r ON m.customer_id = r.customer_id;

-- =====================================================================
-- J17. 구문형 JOIN (FROM A, B ... WHERE 조인조건)
-- 예상 결과: 4행
-- =====================================================================
SELECT a.customer_id, a.total_spent
FROM customers a, state_region b
WHERE a.state = b.state
  AND a.total_spent > 2000;

INSERT INTO sql_example_result
SELECT 'J17', 1, COUNT(*), NULL, GETDATE()
FROM customers a, state_region b
WHERE a.state = b.state
  AND a.total_spent > 2000;

-- =====================================================================
-- J18. Oracle (+) 동등 표현 - SQL Server는 (+) 구문을 지원하지 않는다.
--   *** 개념적 대응: STATE_REGION a, CUSTOMERS b WHERE a.STATE = b.STATE(+) 는
--   SQL Server에서 STATE_REGION a LEFT JOIN CUSTOMERS b ON a.STATE = b.STATE
--   로만 표현할 수 있다. ***
-- 예상 결과: 9행 (CUSTOMERS 8행이 각자의 STATE와 매칭 + 'BA'가 NULL로 보존)
-- =====================================================================
SELECT a.state, a.region, b.customer_id
FROM state_region a LEFT JOIN customers b ON a.state = b.state;

INSERT INTO sql_example_result
SELECT 'J18', 1, COUNT(*), NULL, GETDATE()
FROM state_region a LEFT JOIN customers b ON a.state = b.state;

-- =====================================================================
-- J19. OUTER JOIN 이후 WHERE로 미일치 행 제거
-- 예상 결과: 1행 (Ma의 휴대폰 연락처만 남음)
-- =====================================================================
SELECT m.customer_id, c.contact_type, c.contact_no
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id
WHERE c.contact_type = N'휴대폰';

INSERT INTO sql_example_result
SELECT 'J19', 1, COUNT(*), NULL, GETDATE()
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id
WHERE c.contact_type = N'휴대폰';

-- =====================================================================
-- J20. LEFT JOIN + IS NULL
-- 예상 결과: 1행 (연락처가 없는 회원 Mc)
-- =====================================================================
SELECT m.customer_id, m.city
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

INSERT INTO sql_example_result
SELECT 'J20', 1, COUNT(*), NULL, GETDATE()
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- =====================================================================
-- J21 / J21B. COUNT(*)와 COUNT(오른쪽 열)의 차이
-- 예상 결과: COUNT(*)=4(J21), COUNT(CONTACT.customer_id)=3(J21B)
-- =====================================================================
SELECT COUNT(*) AS cnt_star, COUNT(c.customer_id) AS cnt_col
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id;

INSERT INTO sql_example_result
SELECT 'J21', COUNT(*), NULL, NULL, GETDATE()
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id;

INSERT INTO sql_example_result
SELECT 'J21B', 1, COUNT(c.customer_id), NULL, GETDATE()
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id;

-- =====================================================================
-- J22. 테이블 별칭
--   잘못된 예(실행하지 않음, 오류 발생):
--   SELECT customers.state FROM customers a, state_region b WHERE a.state = b.state;
-- 예상 결과: 8행 (올바른 별칭 사용)
-- =====================================================================
SELECT a.customer_id, b.region
FROM customers a, state_region b
WHERE a.state = b.state;

INSERT INTO sql_example_result
SELECT 'J22', 1, COUNT(*), NULL, GETDATE()
FROM customers a, state_region b
WHERE a.state = b.state;

-- =====================================================================
-- J23. 첨부 문제 형태와 유사한 행 수 계산 연습
-- 예상 결과: 3행
--   SP: STATE_ORDERS에 없음 -> 0행
--   RJ: STATE_BRANCH 1행 x STATE_ORDERS 2행 -> 2행 생성
--   MG: STATE_BRANCH 1행 x STATE_ORDERS 1행 -> 1행 생성
--   총 3행
-- =====================================================================
SELECT br.state
FROM state_branch br JOIN state_orders o ON br.state = o.state;

INSERT INTO sql_example_result
SELECT 'J23', 1, COUNT(*), NULL, GETDATE()
FROM state_branch br JOIN state_orders o ON br.state = o.state;
