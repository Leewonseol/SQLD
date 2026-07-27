-- JOIN·표준 JOIN 예제 실행 (Oracle)
-- 대상: 깨우침/JOIN·표준 JOIN 문제 풀이표.md 의 21개 개념 순서를 그대로 따른다.
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- 각 예제는 두 부분으로 구성된다.
--   1) 사람이 결과를 눈으로 볼 수 있는 SELECT(그대로 실행 가능, 조회용)
--   2) sql_example_result에 example_id별로 정확히 1행을 남기는 INSERT
-- 재실행해도 중복이 쌓이지 않도록, 이 예제들이 쓰는 example_id 범위를 먼저 지운다.

DELETE FROM sql_example_result WHERE example_id LIKE 'J%';
COMMIT;

-- =====================================================================
-- J01. 테이블 수 (FROM에 테이블 1개 -> JOIN 아님)
-- 예상 결과: 1행(집계행), CUSTOMERS 전체 8건
-- =====================================================================
SELECT * FROM customers;

INSERT INTO sql_example_result
SELECT 'J01', 1, COUNT(*), NULL, SYSDATE FROM customers;

-- =====================================================================
-- J02. 연결 조건 존재 여부 - 카티션 곱 (조건 없음)
-- 예상 결과: CUSTOMERS(8) x STATE_REGION(4) = 32행
-- =====================================================================
SELECT COUNT(*) AS cnt FROM customers CROSS JOIN state_region;

INSERT INTO sql_example_result
SELECT 'J02', 1, COUNT(*), NULL, SYSDATE FROM customers CROSS JOIN state_region;

-- =====================================================================
-- J03. 연결 조건 존재 여부 - 조건부 JOIN
-- 예상 결과: 8행. 고객 8명 전원이 STATE_REGION(SP,RJ,MG) 안에 속하므로
-- 카티션 곱(32행) 대신 조건을 만족하는 8행만 남는다.
-- =====================================================================
SELECT c.customer_id, r.region
FROM customers c JOIN state_region r ON c.state = r.state;

INSERT INTO sql_example_result
SELECT 'J03', 1, COUNT(*), NULL, SYSDATE
FROM customers c JOIN state_region r ON c.state = r.state;

-- =====================================================================
-- J04. 카티션 곱 계산 (행수=곱, 열수=합)
-- 예상 결과: STATE_REGION(4행,2열) x REVIEW_TIER(3행,2열) = 12행, 4열
-- =====================================================================
SELECT COUNT(*) AS row_cnt, 2 + 2 AS col_cnt
FROM state_region CROSS JOIN review_tier;

INSERT INTO sql_example_result
SELECT 'J04', 1, COUNT(*), NULL, SYSDATE FROM state_region CROSS JOIN review_tier;

-- =====================================================================
-- J05. CROSS JOIN - 첨부 표준 JOIN 문제 9번 유형(A 2행, B 3행)
-- 예상 결과: 2 x 3 = 6행
-- =====================================================================
SELECT COUNT(*) AS cnt FROM sample_states CROSS JOIN sample_scores;

INSERT INTO sql_example_result
SELECT 'J05', 1, COUNT(*), NULL, SYSDATE FROM sample_states CROSS JOIN sample_scores;

-- =====================================================================
-- J06. 등가 조인 (CUSTOMERS.STATE = STATE_REGION.STATE)
-- 예상 결과: 8행 (J03과 동일 데이터, "=" 비교라는 점을 강조)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'J06', 1, COUNT(*), NULL, SYSDATE
FROM customers c JOIN state_region r ON c.state = r.state;

-- =====================================================================
-- J07. 비등가 조인 (TOTAL_SPENT BETWEEN LOSAL AND HISAL)
-- 예상 결과: 8행. 고객 8명 전원의 TOTAL_SPENT가 SPEND_TIER 어느 한 구간에 속한다.
-- =====================================================================
SELECT c.customer_id, c.total_spent, t.tier
FROM customers c JOIN spend_tier t ON c.total_spent BETWEEN t.losal AND t.hisal;

INSERT INTO sql_example_result
SELECT 'J07', 1, COUNT(*), NULL, SYSDATE
FROM customers c JOIN spend_tier t ON c.total_spent BETWEEN t.losal AND t.hisal;

-- =====================================================================
-- J08. 조인 조건과 일반 필터 조건 구분
--   STATE 조건 = 조인 조건, TOTAL_SPENT>2000 = 일반 필터 조건
-- 예상 결과: 4행 (RJ고객1 2975, RJ고객3 2850, MG고객1 2450, MG고객2 3000)
-- =====================================================================
SELECT c.customer_id, c.total_spent
FROM customers c JOIN state_region r ON c.state = r.state
WHERE c.total_spent > 2000;

INSERT INTO sql_example_result
SELECT 'J08', 1, COUNT(*), NULL, SYSDATE
FROM customers c JOIN state_region r ON c.state = r.state
WHERE c.total_spent > 2000;

-- =====================================================================
-- J09. 중복값에 따른 결과 행 수 증가 - 첨부 JOIN 문제 5번
--   CUSTOMER_DIM: U1(1회성 고객), U2(실제 3회 재구매 고객 중 2건),
--   U3(실제 2회 재구매 고객 중 1건)
-- 예상 결과: 3행 (U1: 0개, U2: 1x2=2개, U3: 1x1=1개, 합계 3)
-- =====================================================================
SELECT d.customer_unique_id
FROM customer_dim d JOIN customer_orders_sample o
  ON d.customer_unique_id = o.customer_unique_id;

INSERT INTO sql_example_result
SELECT 'J09', 1, COUNT(*), NULL, SYSDATE
FROM customer_dim d JOIN customer_orders_sample o
  ON d.customer_unique_id = o.customer_unique_id;

-- =====================================================================
-- J10. INNER JOIN - CUSTOMER_MASTER(Ca,Cb,Cc) / CUSTOMER_REVIEW(Ca,Cb,Cd)
-- 예상 결과: 2행 (공통 고객 Ca, Cb만 유지)
-- =====================================================================
SELECT m.customer_id, m.city, r.subject, r.scoreval
FROM customer_master m JOIN customer_review r ON m.customer_id = r.customer_id;

INSERT INTO sql_example_result
SELECT 'J10', 1, COUNT(*), NULL, SYSDATE
FROM customer_master m JOIN customer_review r ON m.customer_id = r.customer_id;

-- =====================================================================
-- J11. LEFT OUTER JOIN
-- 예상 결과: 3행 (MASTER 3명 전원 보존, Cc는 리뷰 열이 NULL)
-- =====================================================================
SELECT m.customer_id, r.scoreval
FROM customer_master m LEFT OUTER JOIN customer_review r ON m.customer_id = r.customer_id;

INSERT INTO sql_example_result
SELECT 'J11', 1, COUNT(*), NULL, SYSDATE
FROM customer_master m LEFT OUTER JOIN customer_review r ON m.customer_id = r.customer_id;

-- =====================================================================
-- J12. RIGHT OUTER JOIN
-- 예상 결과: 3행 (REVIEW 3건 보존, Cd는 MASTER쪽 열이 NULL)
-- =====================================================================
SELECT m.customer_id AS master_id, r.customer_id AS review_id, r.scoreval
FROM customer_master m RIGHT OUTER JOIN customer_review r ON m.customer_id = r.customer_id;

INSERT INTO sql_example_result
SELECT 'J12', 1, COUNT(*), NULL, SYSDATE
FROM customer_master m RIGHT OUTER JOIN customer_review r ON m.customer_id = r.customer_id;

-- =====================================================================
-- J13. FULL OUTER JOIN - 첨부 표준 JOIN 문제 8번 그대로(A:SP,RJ / B:RJ,MG)
-- 예상 결과: 3행 (SP는 A에만, RJ는 양쪽 결합 1행, MG는 B에만 -> 총 3행)
-- =====================================================================
SELECT a.state AS a_state, b.state AS b_state
FROM full_a a FULL OUTER JOIN full_b b ON a.state = b.state;

INSERT INTO sql_example_result
SELECT 'J13', 1, COUNT(*), NULL, SYSDATE
FROM full_a a FULL OUTER JOIN full_b b ON a.state = b.state;

-- =====================================================================
-- J13B. FULL OUTER JOIN 추가 연습(CUSTOMER_MASTER/CUSTOMER_REVIEW)
-- 예상 결과: 4행 (Ca,Cb,Cc,Cd 각각 1행씩)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'J13B', 1, COUNT(*), NULL, SYSDATE
FROM customer_master m FULL OUTER JOIN customer_review r ON m.customer_id = r.customer_id;

-- =====================================================================
-- J14. ON - 열 이름이 서로 달라도 가능 (CUSTOMERS.STATE = STATE_REGION2.STATE_CODE)
-- 예상 결과: 8행 (J03과 같은 결과지만 조인 열 이름이 서로 다름 -> USING/NATURAL 불가,
-- ON만 가능함을 보여준다)
-- =====================================================================
SELECT c.customer_id, r2.region_name
FROM customers c JOIN state_region2 r2 ON c.state = r2.state_code;

INSERT INTO sql_example_result
SELECT 'J14', 1, COUNT(*), NULL, SYSDATE
FROM customers c JOIN state_region2 r2 ON c.state = r2.state_code;

-- =====================================================================
-- J15. USING - 양쪽 조인 열 이름이 같을 때(customer_id)
-- 예상 결과: 2행 (INNER JOIN과 동일한 등가 조인 결과)
-- =====================================================================
SELECT customer_id, city, subject, scoreval
FROM customer_master JOIN customer_review USING (customer_id);

INSERT INTO sql_example_result
SELECT 'J15', 1, COUNT(*), NULL, SYSDATE
FROM customer_master JOIN customer_review USING (customer_id);

-- =====================================================================
-- J16. NATURAL JOIN - 이름이 같은 공통 열(customer_id)을 자동으로 사용
-- 예상 결과: 2행 (MASTER/REVIEW의 공통 열은 customer_id 하나뿐이므로 USING과 동일)
-- =====================================================================
SELECT customer_id, city, subject, scoreval
FROM customer_master NATURAL JOIN customer_review;

INSERT INTO sql_example_result
SELECT 'J16', 1, COUNT(*), NULL, SYSDATE
FROM customer_master NATURAL JOIN customer_review;

-- =====================================================================
-- J17. 구문형 JOIN (FROM A, B ... WHERE 조인조건)
-- 예상 결과: 4행 (J08과 같은 조건, 문법만 다름)
-- =====================================================================
SELECT a.customer_id, a.total_spent
FROM customers a, state_region b
WHERE a.state = b.state
  AND a.total_spent > 2000;

INSERT INTO sql_example_result
SELECT 'J17', 1, COUNT(*), NULL, SYSDATE
FROM customers a, state_region b
WHERE a.state = b.state
  AND a.total_spent > 2000;

-- =====================================================================
-- J18. Oracle (+) - STATE_REGION을 기준으로 보존, CUSTOMERS가 부족한 쪽
--   'BA'(Nordeste)에는 고객이 없다 -> (+) 없이 등가조인하면 사라질 행이
--   (+) 덕분에 CUSTOMERS 쪽 열이 NULL인 채로 보존된다.
-- 예상 결과: 9행 (CUSTOMERS 8행이 각자의 STATE와 매칭 + BA가 NULL로 보존)
-- =====================================================================
SELECT a.state, a.region, b.customer_id
FROM state_region a, customers b
WHERE a.state = b.state(+);

INSERT INTO sql_example_result
SELECT 'J18', 1, COUNT(*), NULL, SYSDATE
FROM state_region a, customers b
WHERE a.state = b.state(+);

-- =====================================================================
-- J19. OUTER JOIN 이후 WHERE로 미일치 행 제거
--   MEMBER 3명을 LEFT JOIN으로 전부 보존한 뒤, WHERE로 '휴대폰'만 필터링하면
--   LEFT JOIN으로 보존했던 Mc(연락처 없음)이 다시 사라진다.
-- 예상 결과: 1행 (Ma의 휴대폰 연락처만 남음)
-- =====================================================================
SELECT m.customer_id, c.contact_type, c.contact_no
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id
WHERE c.contact_type = '휴대폰';

INSERT INTO sql_example_result
SELECT 'J19', 1, COUNT(*), NULL, SYSDATE
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id
WHERE c.contact_type = '휴대폰';

-- =====================================================================
-- J20. LEFT JOIN + IS NULL - 오른쪽에 대응 행이 없는 왼쪽 행만 추출
-- 예상 결과: 1행 (연락처가 없는 회원 Mc)
-- =====================================================================
SELECT m.customer_id, m.city
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

INSERT INTO sql_example_result
SELECT 'J20', 1, COUNT(*), NULL, SYSDATE
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- =====================================================================
-- J21 / J21B. COUNT(*)와 COUNT(오른쪽 열)의 차이
--   LEFT JOIN 결과: Ma(2행) + Mb(1행) + Mc(연락처 NULL, 1행) = 4행
-- 예상 결과: COUNT(*)=4(J21), COUNT(CONTACT.customer_id)=3(J21B, Mc의 NULL 제외)
-- =====================================================================
SELECT COUNT(*) AS cnt_star, COUNT(c.customer_id) AS cnt_col
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id;

INSERT INTO sql_example_result
SELECT 'J21', COUNT(*), NULL, NULL, SYSDATE
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id;

INSERT INTO sql_example_result
SELECT 'J21B', 1, COUNT(c.customer_id), NULL, SYSDATE
FROM member m LEFT OUTER JOIN contact c ON m.customer_id = c.customer_id;

-- =====================================================================
-- J22. 테이블 별칭
--   FROM CUSTOMERS A, STATE_REGION B 선언 후에는 A.STATE처럼 별칭으로만
--   참조해야 한다. 아래 CUSTOMERS.STATE는 별칭 선언 후 원래 테이블명을 쓴
--   오류 예시이며 실행하지 않는다(주석 처리, 첨부 JOIN 문제 2번 유형).
-- 예상 결과: 8행 (올바른 별칭 사용)
-- =====================================================================
-- 잘못된 예(실행하지 않음, 오류 발생):
-- SELECT customers.state FROM customers A, state_region B WHERE A.state = B.state;

SELECT a.customer_id, b.region
FROM customers a, state_region b
WHERE a.state = b.state;

INSERT INTO sql_example_result
SELECT 'J22', 1, COUNT(*), NULL, SYSDATE
FROM customers a, state_region b
WHERE a.state = b.state;

-- =====================================================================
-- J23. 첨부 문제 형태와 유사한 행 수 계산 연습
--   STATE_BRANCH(SP,RJ,MG) x STATE_ORDERS(RJ,RJ,MG)
-- 예상 결과: 3행
--   SP: STATE_ORDERS에 없음 -> 0행
--   RJ: STATE_BRANCH 1행 x STATE_ORDERS 2행 -> 2행 생성
--   MG: STATE_BRANCH 1행 x STATE_ORDERS 1행 -> 1행 생성
--   총 3행
-- =====================================================================
SELECT br.state
FROM state_branch br JOIN state_orders o ON br.state = o.state;

INSERT INTO sql_example_result
SELECT 'J23', 1, COUNT(*), NULL, SYSDATE
FROM state_branch br JOIN state_orders o ON br.state = o.state;

COMMIT;
