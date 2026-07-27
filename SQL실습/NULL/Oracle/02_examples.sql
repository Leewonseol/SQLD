-- NULL 예제 실행 (Oracle)
-- 대상: 깨우침/NULL 정리.md 의 36개 개념 순서를 그대로 따른다.
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- 예제마다 사람이 볼 수 있는 SELECT(조회용)와, sql_example_result에 정확히
-- 1행을 남기는 INSERT(검증용)를 함께 둔다. 순수 리터럴 논리(TRUE/FALSE/
-- UNKNOWN, IN/NOT IN)를 보여줄 때는 Oracle의 1행짜리 더미 테이블 DUAL을 쓴다.

DELETE FROM sql_example_result WHERE example_id LIKE 'N%';
COMMIT;

-- =====================================================================
-- N01. NULL, 0, 공백, 빈 문자열 구분
--   CUSTOMER_NOTE: 실제 고객 4명 ('VIP GOOD',NULL,'','  ')
-- 예상 결과: Oracle은 ''도 NULL로 저장되므로 IS NULL count=2(2,3행)
-- =====================================================================
SELECT customer_id, note_text FROM customer_note;

INSERT INTO sql_example_result
SELECT 'N01', 1, COUNT(*), NULL, SYSDATE FROM customer_note WHERE note_text IS NULL;

-- =====================================================================
-- N02. Oracle 빈 문자열과 NULL
--   NOTE_TEXT=''는 "컬럼=NULL"과 같아져 결코 TRUE가 될 수 없다(UNKNOWN).
-- 예상 결과: 0건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N02', 1, COUNT(*), NULL, SYSDATE FROM customer_note WHERE note_text = '';

-- =====================================================================
-- N03. 공백 문자열 길이 (Oracle LENGTH는 공백도 그대로 센다)
-- 예상 결과: LENGTH(' ')=1
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N03', 1, LENGTH(note_text), NULL, SYSDATE
FROM customer_note WHERE customer_id = '0055e9b290953716739bd94a256a4144';

-- =====================================================================
-- N03B. Oracle에는 SQL Server의 DATALENGTH 같은 별도 구분이 없다
--   (LENGTH 하나로 문자 길이=바이트 길이를 겸한다, 단일 바이트 문자 기준)
-- 예상 결과: 1 (N03과 동일 값)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N03B', 1, LENGTH(note_text), NULL, SYSDATE
FROM customer_note WHERE customer_id = '0055e9b290953716739bd94a256a4144';

-- =====================================================================
-- N04. = NULL (항상 UNKNOWN)
-- 예상 결과: 0건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N04', 1, COUNT(*), NULL, SYSDATE FROM customer_order_summary WHERE total_spent = NULL;

-- =====================================================================
-- N05. <> NULL (항상 UNKNOWN)
-- 예상 결과: 0건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N05', 1, COUNT(*), NULL, SYSDATE FROM customer_order_summary WHERE total_spent <> NULL;

-- =====================================================================
-- N06. IS NULL
-- 예상 결과: 1건 (2행)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N06', 1, COUNT(*), NULL, SYSDATE FROM customer_order_summary WHERE total_spent IS NULL;

-- =====================================================================
-- N07. IS NOT NULL
-- 예상 결과: 2건 (1,3행)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N07', 1, COUNT(*), NULL, SYSDATE FROM customer_order_summary WHERE total_spent IS NOT NULL;

-- =====================================================================
-- N08/N08B/N08C. TRUE/FALSE/UNKNOWN
--   WHERE는 TRUE만 통과시킨다. FALSE와 UNKNOWN은 결과상 구분이 안 된다는
--   것 자체가 핵심 — 그래서 세 케이스 모두 COUNT(*)로 확인한다.
-- 예상 결과: N08(1=1,TRUE)=1건, N08B(1=2,FALSE)=0건, N08C(NULL=NULL,UNKNOWN)=0건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N08', 1, COUNT(*), NULL, SYSDATE FROM dual WHERE 1 = 1;

INSERT INTO sql_example_result
SELECT 'N08B', 1, COUNT(*), NULL, SYSDATE FROM dual WHERE 1 = 2;

INSERT INTO sql_example_result
SELECT 'N08C', 1, COUNT(*), NULL, SYSDATE FROM dual WHERE NULL = NULL;

-- =====================================================================
-- N09. LIKE와 NULL
-- 예상 결과: 1건 ('VIP GOOD'만 'VIP%' 매칭, NULL은 UNKNOWN이라 매칭 안됨)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N09', 1, COUNT(*), NULL, SYSDATE FROM customer_note WHERE note_text LIKE 'VIP%';

-- =====================================================================
-- N10. 산술 연산 NULL 전파
-- 예상 결과: TOTAL_SPENT+10 WHERE 2행 -> NULL (플래그 1로 확인)
-- =====================================================================
SELECT customer_id, total_spent, total_spent + 10 AS result
FROM customer_order_summary WHERE customer_id = '00104a47c29da701ce41ee52077587d9';

INSERT INTO sql_example_result
SELECT 'N10', 1,
       CASE WHEN (total_spent + 10) IS NULL THEN 1 ELSE 0 END,
       NULL, SYSDATE
FROM customer_order_summary WHERE customer_id = '00104a47c29da701ce41ee52077587d9';

-- =====================================================================
-- N11~N17. 집계 함수의 NULL 처리 - CUSTOMER_ORDER_SUMMARY(10, NULL, 20)
-- 예상값: COUNT(*)=3, COUNT(TOTAL_SPENT)=2, SUM=30, AVG=15, MIN=10, MAX=20
-- =====================================================================
SELECT COUNT(*) AS cnt_star, COUNT(total_spent) AS cnt_col, SUM(total_spent), AVG(total_spent),
       MIN(total_spent), MAX(total_spent)
FROM customer_order_summary;

INSERT INTO sql_example_result SELECT 'N11', 1, COUNT(*), NULL, SYSDATE FROM customer_order_summary;
INSERT INTO sql_example_result SELECT 'N12', 1, COUNT(total_spent), NULL, SYSDATE FROM customer_order_summary;
INSERT INTO sql_example_result SELECT 'N13', 1, COUNT(DISTINCT total_spent), NULL, SYSDATE FROM customer_order_summary_dup;
INSERT INTO sql_example_result SELECT 'N14', 1, SUM(total_spent), NULL, SYSDATE FROM customer_order_summary;
INSERT INTO sql_example_result SELECT 'N15', 1, AVG(total_spent), NULL, SYSDATE FROM customer_order_summary;
INSERT INTO sql_example_result SELECT 'N16', 1, MIN(total_spent), NULL, SYSDATE FROM customer_order_summary;
INSERT INTO sql_example_result SELECT 'N17', 1, MAX(total_spent), NULL, SYSDATE FROM customer_order_summary;

-- =====================================================================
-- N18. NULL과 0의 평균 차이 - CUSTOMER_ORDER_SUMMARY_ZERO(10,20,0)
-- 예상 결과: AVG=10 (N15의 15와 다름 - NULL은 분모 제외, 0은 분모 포함)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N18', 1, AVG(total_spent), NULL, SYSDATE FROM customer_order_summary_zero;

-- =====================================================================
-- N19. 0행 집계 결과 - WHERE로 0행이 되어도 집계는 1행을 반환한다
-- 예상 결과: COUNT(*)=0, COUNT(TOTAL_SPENT)=0, SUM/AVG/MAX/MIN=NULL (여전히 1행)
-- =====================================================================
SELECT COUNT(*), COUNT(total_spent), SUM(total_spent), AVG(total_spent), MAX(total_spent), MIN(total_spent)
FROM customer_order_summary WHERE total_spent > 1000;

INSERT INTO sql_example_result
SELECT 'N19', 1, COUNT(*), NULL, SYSDATE FROM customer_order_summary WHERE total_spent > 1000;

-- =====================================================================
-- N20/N20B/N20C. IN과 NULL
-- 예상 결과: N20(1 IN (1,NULL))=1건(TRUE), N20B(2 IN (1,3))=0건(FALSE),
--            N20C(2 IN (1,NULL))=0건(UNKNOWN)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N20', 1, COUNT(*), NULL, SYSDATE FROM dual WHERE 1 IN (1, NULL);

INSERT INTO sql_example_result
SELECT 'N20B', 1, COUNT(*), NULL, SYSDATE FROM dual WHERE 2 IN (1, 3);

INSERT INTO sql_example_result
SELECT 'N20C', 1, COUNT(*), NULL, SYSDATE FROM dual WHERE 2 IN (1, NULL);

-- =====================================================================
-- N21/N21B/N21C. NOT IN과 NULL
-- 예상 결과: N21(1 NOT IN (1,NULL))=0건(FALSE), N21B(2 NOT IN (1,NULL))=0건(UNKNOWN),
--            N21C(2 NOT IN (1,3))=1건(TRUE)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N21', 1, COUNT(*), NULL, SYSDATE FROM dual WHERE 1 NOT IN (1, NULL);

INSERT INTO sql_example_result
SELECT 'N21B', 1, COUNT(*), NULL, SYSDATE FROM dual WHERE 2 NOT IN (1, NULL);

INSERT INTO sql_example_result
SELECT 'N21C', 1, COUNT(*), NULL, SYSDATE FROM dual WHERE 2 NOT IN (1, 3);

-- =====================================================================
-- N22. 서브쿼리 NOT IN과 NULL - 유명한 함정
--   CUSTOMER_FLAG_CHECK(실제 고객 3명, flag_val=1,2,3)
--   CUSTOMER_FLAG_EXCLUDE(flag_val=1,3,NULL)
--   flag_val=2는 EXCLUDE의 비NULL 값(1,3)과 일치하지 않지만, 목록에 NULL이
--   있어 "2<>NULL"이 UNKNOWN이 되고 AND로 묶인 전체 조건도 UNKNOWN이 된다.
-- 예상 결과: 0행 (직관과 달리 flag_val=2 고객도 나오지 않는다)
-- =====================================================================
SELECT * FROM customer_flag_check WHERE flag_val NOT IN (SELECT flag_val FROM customer_flag_exclude);

INSERT INTO sql_example_result
SELECT 'N22', COUNT(*), NULL, NULL, SYSDATE
FROM customer_flag_check WHERE flag_val NOT IN (SELECT flag_val FROM customer_flag_exclude);

-- =====================================================================
-- N23. COALESCE
-- 예상 결과: COALESCE(TOTAL_SPENT,-1) WHERE 2행 -> -1
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N23', 1, COALESCE(total_spent, -1), NULL, SYSDATE
FROM customer_order_summary WHERE customer_id = '00104a47c29da701ce41ee52077587d9';

-- =====================================================================
-- N24. NVL (Oracle 전용 함수)
-- 예상 결과: NVL(TOTAL_SPENT,-1) WHERE 2행 -> -1
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N24', 1, NVL(total_spent, -1), NULL, SYSDATE
FROM customer_order_summary WHERE customer_id = '00104a47c29da701ce41ee52077587d9';

-- =====================================================================
-- N25. ISNULL 대응
--   *** Oracle에는 ISNULL 함수가 없다(SQL Server 전용). 같은 자리를
--   NVL로 채운다 - 문법 자체가 다르다는 점이 이 예제의 핵심이다. ***
-- 예상 결과: -1 (NVL로 동일 효과)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N25', 1, NVL(total_spent, -1), NULL, SYSDATE
FROM customer_order_summary WHERE customer_id = '00104a47c29da701ce41ee52077587d9';

-- =====================================================================
-- N26/N26B. NULLIF
-- 예상 결과: NULLIF(10,10) IS NULL 플래그=1(N26), NULLIF(10,20)=10(N26B)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N26', 1, CASE WHEN NULLIF(10, 10) IS NULL THEN 1 ELSE 0 END, NULL, SYSDATE FROM dual;

INSERT INTO sql_example_result
SELECT 'N26B', 1, NULLIF(10, 20), NULL, SYSDATE FROM dual;

-- =====================================================================
-- N27/N27B. 0 나누기 방지 (NULLIF로 분모를 NULL로 바꿔 오류 대신 NULL)
-- 예상 결과: N27(분모 0) -> IS NULL 플래그=1, N27B(분모 5) -> 20
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N27', 1, CASE WHEN (100 / NULLIF(0, 0)) IS NULL THEN 1 ELSE 0 END, NULL, SYSDATE FROM dual;

INSERT INTO sql_example_result
SELECT 'N27B', 1, 100 / NULLIF(5, 0), NULL, SYSDATE FROM dual;

-- =====================================================================
-- N28. OUTER JOIN으로 생성된 NULL
--   CUSTOMER_LEFT(3명), CUSTOMER_RIGHT_ORDER(2명) -> LEFT JOIN 후 r이
--   NULL인 행 탐지
-- 예상 결과: 1건 (주문 없는 고객 1명)
-- =====================================================================
SELECT l.customer_id
FROM customer_left l LEFT OUTER JOIN customer_right_order r ON l.customer_id = r.customer_id
WHERE r.customer_id IS NULL;

INSERT INTO sql_example_result
SELECT 'N28', 1, COUNT(*), NULL, SYSDATE
FROM customer_left l LEFT OUTER JOIN customer_right_order r ON l.customer_id = r.customer_id
WHERE r.customer_id IS NULL;

-- =====================================================================
-- N29. OUTER JOIN 이후 COUNT 차이
-- 예상 결과: COUNT(*)=3(row_count), COUNT(r.customer_id)=2(numeric, 미매칭 1건 NULL 제외)
-- =====================================================================
SELECT COUNT(*) AS cnt_star, COUNT(r.customer_id) AS cnt_col
FROM customer_left l LEFT OUTER JOIN customer_right_order r ON l.customer_id = r.customer_id;

INSERT INTO sql_example_result
SELECT 'N29', COUNT(*), COUNT(r.customer_id), NULL, SYSDATE
FROM customer_left l LEFT OUTER JOIN customer_right_order r ON l.customer_id = r.customer_id;

-- =====================================================================
-- N30/N30B. GROUP BY의 NULL - CUSTOMER_REGION(Nordeste,NULL,NULL)
-- 예상 결과: N30(그룹 수)=2(Nordeste,NULL), N30B(NULL 그룹 크기)=2건
-- =====================================================================
SELECT region, COUNT(*) FROM customer_region GROUP BY region;

INSERT INTO sql_example_result
SELECT 'N30', 1, COUNT(*), NULL, SYSDATE
FROM (SELECT region FROM customer_region GROUP BY region);

INSERT INTO sql_example_result
SELECT 'N30B', 1, COUNT(*), NULL, SYSDATE FROM customer_region WHERE region IS NULL;

-- =====================================================================
-- N31. DISTINCT의 NULL - CUSTOMER_VAL(1,1,NULL,NULL)
-- 예상 결과: DISTINCT VAL -> {1, NULL} 2건
-- =====================================================================
SELECT DISTINCT val FROM customer_val;

INSERT INTO sql_example_result
SELECT 'N31', 1, COUNT(*), NULL, SYSDATE FROM (SELECT DISTINCT val FROM customer_val);

-- =====================================================================
-- N32/N32B. ORDER BY의 NULL 위치 - CUSTOMER_ORDERVAL(10, NULL, 5)
--   Oracle 기본: ASC는 NULL 마지막, DESC는 NULL 처음.
-- 예상 결과: N32(ASC 기준 NULL행 순위)=3번째, N32B(DESC 기준 NULL행 순위)=1번째
-- =====================================================================
SELECT customer_id, val, ROW_NUMBER() OVER (ORDER BY val ASC) AS rn_asc
FROM customer_orderval ORDER BY rn_asc;

INSERT INTO sql_example_result
SELECT 'N32', 1, rn, NULL, SYSDATE
FROM (SELECT customer_id, ROW_NUMBER() OVER (ORDER BY val ASC) AS rn FROM customer_orderval)
WHERE customer_id = '0031abfb953b66e998f67b09e7b11375';

INSERT INTO sql_example_result
SELECT 'N32B', 1, rn, NULL, SYSDATE
FROM (SELECT customer_id, ROW_NUMBER() OVER (ORDER BY val DESC) AS rn FROM customer_orderval)
WHERE customer_id = '0031abfb953b66e998f67b09e7b11375';

-- =====================================================================
-- N33. PRIMARY KEY - 제약조건 메타데이터로 존재 확인
-- 예상 결과: 1건 (CUSTOMER_META에 PK 제약 1개)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N33', 1, COUNT(*), NULL, SYSDATE
FROM user_constraints
WHERE table_name = 'CUSTOMER_META' AND constraint_type = 'P';

-- =====================================================================
-- N34. NOT NULL - REQ_VAL이 NOT NULL로 정의됐는지 확인
-- 예상 결과: 1건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N34', 1, COUNT(*), NULL, SYSDATE
FROM user_tab_columns
WHERE table_name = 'CUSTOMER_META' AND column_name = 'REQ_VAL' AND nullable = 'N';

-- =====================================================================
-- N35. UNIQUE와 NULL - Oracle은 UNIQUE 컬럼에 NULL을 여러 개 허용한다
-- 예상 결과: 3행 (2,3행의 CODE가 둘 다 NULL이어도 유일성 위반이 아님)
-- =====================================================================
SELECT * FROM customer_code;

INSERT INTO sql_example_result
SELECT 'N35', COUNT(*), NULL, NULL, SYSDATE FROM customer_code;

-- =====================================================================
-- N36. FOREIGN KEY와 NULL - 선택적 관계는 NULL을 허용한다
-- 예상 결과: 1건 (등급 미배정 고객 1명, TIER_ID가 NULL)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N36', 1, COUNT(*), NULL, SYSDATE FROM customer_membership WHERE tier_id IS NULL;

COMMIT;
