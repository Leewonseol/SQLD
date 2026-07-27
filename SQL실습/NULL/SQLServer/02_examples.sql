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
--   STR_T: (1,'APPLE'),(2,NULL),(3,''),(4,' ')
-- 예상 결과: SQL Server는 ''를 NULL과 구분하므로 IS NULL count=1(id2만)
-- =====================================================================
SELECT id, txt FROM str_t;

INSERT INTO sql_example_result
SELECT 'N01', 1, COUNT(*), NULL, GETDATE() FROM str_t WHERE txt IS NULL;

-- =====================================================================
-- N02. SQL Server 빈 문자열과 NULL
--   TXT=''는 진짜 빈 문자열과 비교하므로 id=3에서 TRUE가 된다.
-- 예상 결과: 1건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N02', 1, COUNT(*), NULL, GETDATE() FROM str_t WHERE txt = '';

-- =====================================================================
-- N03. 공백 문자열 길이 (SQL Server LEN은 뒤쪽 공백을 잘라내고 센다)
-- 예상 결과: LEN(' ')=0
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N03', 1, LEN(txt), NULL, GETDATE() FROM str_t WHERE id = 4;

-- =====================================================================
-- N03B. SQL Server DATALENGTH는 실제 바이트 수를 그대로 센다
-- 예상 결과: DATALENGTH(' ')=1 (N03의 LEN=0과 다름)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N03B', 1, DATALENGTH(txt), NULL, GETDATE() FROM str_t WHERE id = 4;

-- =====================================================================
-- N04. = NULL (항상 UNKNOWN)
-- 예상 결과: 0건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N04', 1, COUNT(*), NULL, GETDATE() FROM score_t WHERE score = NULL;

-- =====================================================================
-- N05. <> NULL (항상 UNKNOWN)
-- 예상 결과: 0건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N05', 1, COUNT(*), NULL, GETDATE() FROM score_t WHERE score <> NULL;

-- =====================================================================
-- N06. IS NULL
-- 예상 결과: 1건 (ID=2)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N06', 1, COUNT(*), NULL, GETDATE() FROM score_t WHERE score IS NULL;

-- =====================================================================
-- N07. IS NOT NULL
-- 예상 결과: 2건 (ID=1,3)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N07', 1, COUNT(*), NULL, GETDATE() FROM score_t WHERE score IS NOT NULL;

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
-- 예상 결과: 1건 (APPLE만 'A%' 매칭)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N09', 1, COUNT(*), NULL, GETDATE() FROM str_t WHERE txt LIKE 'A%';

-- =====================================================================
-- N10. 산술 연산 NULL 전파
-- 예상 결과: SCORE+10 WHERE ID=2 -> NULL (플래그 1로 확인)
-- =====================================================================
SELECT score, score + 10 AS result FROM score_t WHERE id = 2;

INSERT INTO sql_example_result
SELECT 'N10', 1,
       CASE WHEN (score + 10) IS NULL THEN 1 ELSE 0 END,
       NULL, GETDATE()
FROM score_t WHERE id = 2;

-- =====================================================================
-- N11~N17. 집계 함수의 NULL 처리 - SCORE_T(10, NULL, 20)
-- 예상값: COUNT(*)=3, COUNT(SCORE)=2, SUM=30, AVG=15, MIN=10, MAX=20
-- =====================================================================
SELECT COUNT(*) AS cnt_star, COUNT(score) AS cnt_col, SUM(score) AS sum_val,
       AVG(score) AS avg_val, MIN(score) AS min_val, MAX(score) AS max_val
FROM score_t;

INSERT INTO sql_example_result SELECT 'N11', 1, COUNT(*), NULL, GETDATE() FROM score_t;
INSERT INTO sql_example_result SELECT 'N12', 1, COUNT(score), NULL, GETDATE() FROM score_t;
INSERT INTO sql_example_result SELECT 'N13', 1, COUNT(DISTINCT score), NULL, GETDATE() FROM score_dup;
INSERT INTO sql_example_result SELECT 'N14', 1, SUM(score), NULL, GETDATE() FROM score_t;
INSERT INTO sql_example_result SELECT 'N15', 1, AVG(score), NULL, GETDATE() FROM score_t;
INSERT INTO sql_example_result SELECT 'N16', 1, MIN(score), NULL, GETDATE() FROM score_t;
INSERT INTO sql_example_result SELECT 'N17', 1, MAX(score), NULL, GETDATE() FROM score_t;

-- =====================================================================
-- N18. NULL과 0의 평균 차이 - SCORE_ZERO(10,20,0)
-- 예상 결과: AVG=10
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N18', 1, AVG(score), NULL, GETDATE() FROM score_zero;

-- =====================================================================
-- N19. 0행 집계 결과
-- 예상 결과: COUNT(*)=0, COUNT(SCORE)=0, SUM/AVG/MAX/MIN=NULL (여전히 1행)
-- =====================================================================
SELECT COUNT(*), COUNT(score), SUM(score), AVG(score), MAX(score), MIN(score)
FROM score_t WHERE score > 1000;

INSERT INTO sql_example_result
SELECT 'N19', 1, COUNT(*), NULL, GETDATE() FROM score_t WHERE score > 1000;

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
SELECT * FROM base_vals WHERE val NOT IN (SELECT val FROM exclude_list);

INSERT INTO sql_example_result
SELECT 'N22', COUNT(*), NULL, NULL, GETDATE()
FROM base_vals WHERE val NOT IN (SELECT val FROM exclude_list);

-- =====================================================================
-- N23. COALESCE
-- 예상 결과: -1
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N23', 1, COALESCE(score, -1), NULL, GETDATE() FROM score_t WHERE id = 2;

-- =====================================================================
-- N24. NVL 대응
--   *** SQL Server에는 NVL 함수가 없다(Oracle 전용). 같은 자리를 ISNULL로
--   채운다 - 함수 목록 자체가 다르다는 점이 이 예제의 핵심이다. ***
-- 예상 결과: -1 (ISNULL로 동일 효과)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N24', 1, ISNULL(score, -1), NULL, GETDATE() FROM score_t WHERE id = 2;

-- =====================================================================
-- N25. ISNULL (SQL Server 전용 함수, 반환 타입이 첫 인수 기준으로 고정됨)
-- 예상 결과: -1
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N25', 1, ISNULL(score, -1), NULL, GETDATE() FROM score_t WHERE id = 2;

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
-- 예상 결과: 1건 (ID=3)
-- =====================================================================
SELECT l.id
FROM null_left l LEFT OUTER JOIN null_right r ON l.id = r.id
WHERE r.id IS NULL;

INSERT INTO sql_example_result
SELECT 'N28', 1, COUNT(*), NULL, GETDATE()
FROM null_left l LEFT OUTER JOIN null_right r ON l.id = r.id
WHERE r.id IS NULL;

-- =====================================================================
-- N29. OUTER JOIN 이후 COUNT 차이
-- 예상 결과: COUNT(*)=3(row_count), COUNT(r.ID)=2(numeric)
-- =====================================================================
SELECT COUNT(*) AS cnt_star, COUNT(r.id) AS cnt_col
FROM null_left l LEFT OUTER JOIN null_right r ON l.id = r.id;

INSERT INTO sql_example_result
SELECT 'N29', COUNT(*), COUNT(r.id), NULL, GETDATE()
FROM null_left l LEFT OUTER JOIN null_right r ON l.id = r.id;

-- =====================================================================
-- N30/N30B. GROUP BY의 NULL - REGION_T(서울,NULL,NULL)
-- =====================================================================
SELECT region, COUNT(*) FROM region_t GROUP BY region;

INSERT INTO sql_example_result
SELECT 'N30', 1, COUNT(*), NULL, GETDATE()
FROM (SELECT region FROM region_t GROUP BY region) g;

INSERT INTO sql_example_result
SELECT 'N30B', 1, COUNT(*), NULL, GETDATE() FROM region_t WHERE region IS NULL;

-- =====================================================================
-- N31. DISTINCT의 NULL - DISTINCT_T(1,1,NULL,NULL)
-- 예상 결과: {1, NULL} 2건
-- =====================================================================
SELECT DISTINCT val FROM distinct_t;

INSERT INTO sql_example_result
SELECT 'N31', 1, COUNT(*), NULL, GETDATE() FROM (SELECT DISTINCT val FROM distinct_t) d;

-- =====================================================================
-- N32/N32B. ORDER BY의 NULL 위치
--   SQL Server 기본: ASC는 NULL 처음, DESC는 NULL 마지막(Oracle과 정반대).
-- 예상 결과: N32(ASC 기준 ID=2 순위)=1번째, N32B(DESC 기준 ID=2 순위)=3번째
-- =====================================================================
SELECT id, val, ROW_NUMBER() OVER (ORDER BY val ASC) AS rn_asc
FROM order_t ORDER BY rn_asc;

INSERT INTO sql_example_result
SELECT 'N32', 1, rn, NULL, GETDATE()
FROM (SELECT id, ROW_NUMBER() OVER (ORDER BY val ASC) AS rn FROM order_t) t
WHERE id = 2;

INSERT INTO sql_example_result
SELECT 'N32B', 1, rn, NULL, GETDATE()
FROM (SELECT id, ROW_NUMBER() OVER (ORDER BY val DESC) AS rn FROM order_t) t
WHERE id = 2;

-- =====================================================================
-- N33. PRIMARY KEY - 제약조건 메타데이터로 존재 확인
-- 예상 결과: 1건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N33', 1, COUNT(*), NULL, GETDATE()
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'notnull_test' AND CONSTRAINT_TYPE = 'PRIMARY KEY';

-- =====================================================================
-- N34. NOT NULL - REQ_COL이 NOT NULL로 정의됐는지 확인
-- 예상 결과: 1건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N34', 1, COUNT(*), NULL, GETDATE()
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'notnull_test' AND COLUMN_NAME = 'req_col' AND IS_NULLABLE = 'NO';

-- =====================================================================
-- N35. UNIQUE와 NULL - SQL Server는 UNIQUE 컬럼에 NULL을 1개만 허용한다
-- 예상 결과: 2행 (Oracle 버전은 3행 - N35 note 참고)
-- =====================================================================
SELECT * FROM unique_test;

INSERT INTO sql_example_result
SELECT 'N35', COUNT(*), NULL, NULL, GETDATE() FROM unique_test;

-- =====================================================================
-- N36. FOREIGN KEY와 NULL - 선택적 관계는 NULL을 허용한다
-- 예상 결과: 1건
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'N36', 1, COUNT(*), NULL, GETDATE() FROM fk_child WHERE parent_id IS NULL;
