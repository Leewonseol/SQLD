-- NULL 예제 실행 (SQL Server)
-- 대상: 깨우침/NULL 정리.md 의 36개 개념 순서를 그대로 따른다.
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- Oracle/02_examples.sql과 example_id는 모두 동일하다. 순수 리터럴 논리를
-- 보여줄 때 SQL Server에는 Oracle의 DUAL이 없으므로 `(SELECT 1 AS dummy) d`
-- 파생 테이블로 대체한다.

DELETE FROM sql_example_result WHERE example_id LIKE 'N%';

-- =====================================================================
-- N01. NULL, 0, 공백, 빈 문자열 구분
--   CUSTOMER_NOTE: 실제 고객 4명 ('VIP GOOD',NULL,'',' ')
-- 예상 결과: SQL Server는 ''를 NULL과 구분하므로 IS NULL count=1(2행만)
-- =====================================================================
SELECT customer_id, note_text FROM customer_note;

INSERT INTO sql_example_result
SELECT 'N01', 1, COUNT(*), NULL, GETDATE() FROM customer_note WHERE note_text IS NULL;

-- =====================================================================
-- N02. SQL Server 빈 문자열과 NULL
--   NOTE_TEXT=''는 진짜 빈 문자열과 비교하므로 3행에서 TRUE가 된다.
-- 예상 결과: 1건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N02', 1, COUNT(*), NULL, GETDATE() FROM customer_note WHERE note_text = '';

-- =====================================================================
-- N03. 공백 문자열 길이 (SQL Server LEN은 뒤쪽 공백을 잘라내고 센다)
-- 예상 결과: LEN(' ')=0
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N03', 1, LEN(note_text), NULL, GETDATE()
FROM customer_note WHERE customer_id = '0055e9b290953716739bd94a256a4144';

-- =====================================================================
-- N03B. SQL Server DATALENGTH는 실제 바이트 수를 그대로 센다
-- 예상 결과: DATALENGTH(' ')=1 (N03의 LEN=0과 다름)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N03B', 1, DATALENGTH(note_text), NULL, GETDATE()
FROM customer_note WHERE customer_id = '0055e9b290953716739bd94a256a4144';

-- =====================================================================
-- N04. = NULL (항상 UNKNOWN)
-- 예상 결과: 0건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N04', 1, COUNT(*), NULL, GETDATE() FROM customer_order_summary WHERE total_spent = NULL;

-- =====================================================================
-- N05. <> NULL (항상 UNKNOWN)
-- 예상 결과: 0건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N05', 1, COUNT(*), NULL, GETDATE() FROM customer_order_summary WHERE total_spent <> NULL;

-- =====================================================================
-- N06. IS NULL
-- 예상 결과: 1건 (2행)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N06', 1, COUNT(*), NULL, GETDATE() FROM customer_order_summary WHERE total_spent IS NULL;

-- =====================================================================
-- N07. IS NOT NULL
-- 예상 결과: 2건 (1,3행)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N07', 1, COUNT(*), NULL, GETDATE() FROM customer_order_summary WHERE total_spent IS NOT NULL;

-- =====================================================================
-- N08/N08B/N08C. TRUE/FALSE/UNKNOWN
-- 예상 결과: N08(1=1,TRUE)=1건, N08B(1=2,FALSE)=0건, N08C(NULL=NULL,UNKNOWN)=0건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N08', 1, COUNT(*), NULL, GETDATE() FROM (SELECT 1 AS dummy) d WHERE 1 = 1;

INSERT INTO sql_example_result
SELECT 'N08B', 1, COUNT(*), NULL, GETDATE() FROM (SELECT 1 AS dummy) d WHERE 1 = 2;

INSERT INTO sql_example_result
SELECT 'N08C', 1, COUNT(*), NULL, GETDATE() FROM (SELECT 1 AS dummy) d WHERE NULL = NULL;

-- =====================================================================
-- N09. LIKE와 NULL
-- 예상 결과: 1건 ('VIP GOOD'만 'VIP%' 매칭)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N09', 1, COUNT(*), NULL, GETDATE() FROM customer_note WHERE note_text LIKE 'VIP%';

-- =====================================================================
-- N10. 산술 연산 NULL 전파
-- 예상 결과: TOTAL_SPENT+10 WHERE 2행 -> NULL (플래그 1로 확인)
-- =====================================================================
SELECT customer_id, total_spent, total_spent + 10 AS result
FROM customer_order_summary WHERE customer_id = '00104a47c29da701ce41ee52077587d9';

INSERT INTO sql_example_result
SELECT 'N10', 1,
       CASE WHEN (total_spent + 10) IS NULL THEN 1 ELSE 0 END,
       NULL, GETDATE()
FROM customer_order_summary WHERE customer_id = '00104a47c29da701ce41ee52077587d9';

-- =====================================================================
-- N11~N17. 집계 함수의 NULL 처리 - CUSTOMER_ORDER_SUMMARY(10, NULL, 20)
-- 예상값: COUNT(*)=3, COUNT(TOTAL_SPENT)=2, SUM=30, AVG=15, MIN=10, MAX=20
-- =====================================================================
SELECT COUNT(*) AS cnt_star, COUNT(total_spent) AS cnt_col, SUM(total_spent) AS sum_val,
       AVG(total_spent) AS avg_val, MIN(total_spent) AS min_val, MAX(total_spent) AS max_val
FROM customer_order_summary;

INSERT INTO sql_example_result SELECT 'N11', 1, COUNT(*), NULL, GETDATE() FROM customer_order_summary;
INSERT INTO sql_example_result SELECT 'N12', 1, COUNT(total_spent), NULL, GETDATE() FROM customer_order_summary;
INSERT INTO sql_example_result SELECT 'N13', 1, COUNT(DISTINCT total_spent), NULL, GETDATE() FROM customer_order_summary_dup;
INSERT INTO sql_example_result SELECT 'N14', 1, SUM(total_spent), NULL, GETDATE() FROM customer_order_summary;
INSERT INTO sql_example_result SELECT 'N15', 1, AVG(total_spent), NULL, GETDATE() FROM customer_order_summary;
INSERT INTO sql_example_result SELECT 'N16', 1, MIN(total_spent), NULL, GETDATE() FROM customer_order_summary;
INSERT INTO sql_example_result SELECT 'N17', 1, MAX(total_spent), NULL, GETDATE() FROM customer_order_summary;

-- =====================================================================
-- N18. NULL과 0의 평균 차이 - CUSTOMER_ORDER_SUMMARY_ZERO(10,20,0)
-- 예상 결과: AVG=10
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N18', 1, AVG(total_spent), NULL, GETDATE() FROM customer_order_summary_zero;

-- =====================================================================
-- N19. 0행 집계 결과
-- 예상 결과: COUNT(*)=0, COUNT(TOTAL_SPENT)=0, SUM/AVG/MAX/MIN=NULL (여전히 1행)
-- =====================================================================
SELECT COUNT(*), COUNT(total_spent), SUM(total_spent), AVG(total_spent), MAX(total_spent), MIN(total_spent)
FROM customer_order_summary WHERE total_spent > 1000;

INSERT INTO sql_example_result
SELECT 'N19', 1, COUNT(*), NULL, GETDATE() FROM customer_order_summary WHERE total_spent > 1000;

-- =====================================================================
-- N20/N20B/N20C. IN과 NULL
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N20', 1, COUNT(*), NULL, GETDATE() FROM (SELECT 1 AS dummy) d WHERE 1 IN (1, NULL);

INSERT INTO sql_example_result
SELECT 'N20B', 1, COUNT(*), NULL, GETDATE() FROM (SELECT 1 AS dummy) d WHERE 2 IN (1, 3);

INSERT INTO sql_example_result
SELECT 'N20C', 1, COUNT(*), NULL, GETDATE() FROM (SELECT 1 AS dummy) d WHERE 2 IN (1, NULL);

-- =====================================================================
-- N21/N21B/N21C. NOT IN과 NULL
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N21', 1, COUNT(*), NULL, GETDATE() FROM (SELECT 1 AS dummy) d WHERE 1 NOT IN (1, NULL);

INSERT INTO sql_example_result
SELECT 'N21B', 1, COUNT(*), NULL, GETDATE() FROM (SELECT 1 AS dummy) d WHERE 2 NOT IN (1, NULL);

INSERT INTO sql_example_result
SELECT 'N21C', 1, COUNT(*), NULL, GETDATE() FROM (SELECT 1 AS dummy) d WHERE 2 NOT IN (1, 3);

-- =====================================================================
-- N22. 서브쿼리 NOT IN과 NULL - 유명한 함정
-- 예상 결과: 0행
-- =====================================================================
SELECT * FROM customer_flag_check WHERE flag_val NOT IN (SELECT flag_val FROM customer_flag_exclude);

INSERT INTO sql_example_result
SELECT 'N22', COUNT(*), NULL, NULL, GETDATE()
FROM customer_flag_check WHERE flag_val NOT IN (SELECT flag_val FROM customer_flag_exclude);

-- =====================================================================
-- N23. COALESCE
-- 예상 결과: -1
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N23', 1, COALESCE(total_spent, -1), NULL, GETDATE()
FROM customer_order_summary WHERE customer_id = '00104a47c29da701ce41ee52077587d9';

-- =====================================================================
-- N24. NVL 대응
--   *** SQL Server에는 NVL 함수가 없다(Oracle 전용). 같은 자리를 ISNULL로
--   채운다 - 함수 목록 자체가 다르다는 점이 이 예제의 핵심이다. ***
-- 예상 결과: -1 (ISNULL로 동일 효과)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N24', 1, ISNULL(total_spent, -1), NULL, GETDATE()
FROM customer_order_summary WHERE customer_id = '00104a47c29da701ce41ee52077587d9';

-- =====================================================================
-- N25. ISNULL (SQL Server 전용 함수)
-- 예상 결과: -1
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N25', 1, ISNULL(total_spent, -1), NULL, GETDATE()
FROM customer_order_summary WHERE customer_id = '00104a47c29da701ce41ee52077587d9';

-- =====================================================================
-- N26/N26B. NULLIF
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N26', 1, CASE WHEN NULLIF(10, 10) IS NULL THEN 1 ELSE 0 END, NULL, GETDATE()
FROM (SELECT 1 AS dummy) d;

INSERT INTO sql_example_result
SELECT 'N26B', 1, NULLIF(10, 20), NULL, GETDATE()
FROM (SELECT 1 AS dummy) d;

-- =====================================================================
-- N27/N27B. 0 나누기 방지
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N27', 1, CASE WHEN (100 / NULLIF(0, 0)) IS NULL THEN 1 ELSE 0 END, NULL, GETDATE()
FROM (SELECT 1 AS dummy) d;

INSERT INTO sql_example_result
SELECT 'N27B', 1, 100 / NULLIF(5, 0), NULL, GETDATE()
FROM (SELECT 1 AS dummy) d;

-- =====================================================================
-- N28. OUTER JOIN으로 생성된 NULL
-- 예상 결과: 1건 (주문 없는 고객 1명)
-- =====================================================================
SELECT l.customer_id
FROM customer_left l LEFT OUTER JOIN customer_right_order r ON l.customer_id = r.customer_id
WHERE r.customer_id IS NULL;

INSERT INTO sql_example_result
SELECT 'N28', 1, COUNT(*), NULL, GETDATE()
FROM customer_left l LEFT OUTER JOIN customer_right_order r ON l.customer_id = r.customer_id
WHERE r.customer_id IS NULL;

-- =====================================================================
-- N29. OUTER JOIN 이후 COUNT 차이
-- 예상 결과: COUNT(*)=3(row_count), COUNT(r.customer_id)=2(numeric)
-- =====================================================================
SELECT COUNT(*) AS cnt_star, COUNT(r.customer_id) AS cnt_col
FROM customer_left l LEFT OUTER JOIN customer_right_order r ON l.customer_id = r.customer_id;

INSERT INTO sql_example_result
SELECT 'N29', COUNT(*), COUNT(r.customer_id), NULL, GETDATE()
FROM customer_left l LEFT OUTER JOIN customer_right_order r ON l.customer_id = r.customer_id;

-- =====================================================================
-- N30/N30B. GROUP BY의 NULL - CUSTOMER_REGION(Nordeste,NULL,NULL)
-- =====================================================================
SELECT region, COUNT(*) FROM customer_region GROUP BY region;

INSERT INTO sql_example_result
SELECT 'N30', 1, COUNT(*), NULL, GETDATE()
FROM (SELECT region FROM customer_region GROUP BY region) g;

INSERT INTO sql_example_result
SELECT 'N30B', 1, COUNT(*), NULL, GETDATE() FROM customer_region WHERE region IS NULL;

-- =====================================================================
-- N31. DISTINCT의 NULL - CUSTOMER_VAL(1,1,NULL,NULL)
-- 예상 결과: {1, NULL} 2건
-- =====================================================================
SELECT DISTINCT val FROM customer_val;

INSERT INTO sql_example_result
SELECT 'N31', 1, COUNT(*), NULL, GETDATE() FROM (SELECT DISTINCT val FROM customer_val) d;

-- =====================================================================
-- N32/N32B. ORDER BY의 NULL 위치
--   SQL Server 기본: ASC는 NULL 처음, DESC는 NULL 마지막(Oracle과 정반대).
-- 예상 결과: N32(ASC 기준 NULL행 순위)=1번째, N32B(DESC 기준 NULL행 순위)=3번째
-- =====================================================================
SELECT customer_id, val, ROW_NUMBER() OVER (ORDER BY val ASC) AS rn_asc
FROM customer_orderval ORDER BY rn_asc;

INSERT INTO sql_example_result
SELECT 'N32', 1, rn, NULL, GETDATE()
FROM (SELECT customer_id, ROW_NUMBER() OVER (ORDER BY val ASC) AS rn FROM customer_orderval) t
WHERE customer_id = '0031abfb953b66e998f67b09e7b11375';

INSERT INTO sql_example_result
SELECT 'N32B', 1, rn, NULL, GETDATE()
FROM (SELECT customer_id, ROW_NUMBER() OVER (ORDER BY val DESC) AS rn FROM customer_orderval) t
WHERE customer_id = '0031abfb953b66e998f67b09e7b11375';

-- =====================================================================
-- N33. PRIMARY KEY - 제약조건 메타데이터로 존재 확인
-- 예상 결과: 1건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N33', 1, COUNT(*), NULL, GETDATE()
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'customer_meta' AND CONSTRAINT_TYPE = 'PRIMARY KEY';

-- =====================================================================
-- N34. NOT NULL - REQ_VAL이 NOT NULL로 정의됐는지 확인
-- 예상 결과: 1건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N34', 1, COUNT(*), NULL, GETDATE()
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customer_meta' AND COLUMN_NAME = 'req_val' AND IS_NULLABLE = 'NO';

-- =====================================================================
-- N35. UNIQUE와 NULL - SQL Server는 UNIQUE 컬럼에 NULL을 1개만 허용한다
-- 예상 결과: 2행 (Oracle 버전은 3행 - N35 note 참고)
-- =====================================================================
SELECT * FROM customer_code;

INSERT INTO sql_example_result
SELECT 'N35', COUNT(*), NULL, NULL, GETDATE() FROM customer_code;

-- =====================================================================
-- N36. FOREIGN KEY와 NULL - 선택적 관계는 NULL을 허용한다
-- 예상 결과: 1건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N36', 1, COUNT(*), NULL, GETDATE() FROM customer_membership WHERE tier_id IS NULL;
