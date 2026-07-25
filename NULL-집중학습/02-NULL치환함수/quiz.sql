-- 02. NULL 치환 함수 — 연습문제
-- null_lab_customer: purchase_amt NULL(5,11) / nickname NULL(2,8, Oracle은 3도)
-- / score NULL(3,9) / age NULL(5) / membership_code VARCHAR(2)(5) / dept_code
-- VARCHAR(2)(5), 'D01'은 숫자 변환 불가 / join_date NULL(3,11)

-- =====================================================================
-- Q1. (객관식) 다음 중 SQL Server의 ISNULL과 COALESCE에 대한 설명으로
-- 옳은 것은?
--
--   ① 둘 다 반환형이 두 번째 인수 기준으로 고정된다.
--   ② ISNULL은 반환형이 첫 번째 인수 기준으로 고정되고, COALESCE는 인수들
--      중 데이터 타입 우선순위가 가장 높은 타입으로 승격된다.
--   ③ COALESCE는 인수를 정확히 2개만 받을 수 있다.
--   ④ ISNULL은 Oracle과 SQL Server 모두에서 쓸 수 있는 표준 함수다.
--
-- 답: (      )
-- =====================================================================


-- =====================================================================
-- Q2. (객관식) membership_code가 VARCHAR(5) 컬럼일 때, 아래 두 쿼리 중
-- "실행 시 에러 없이 결과를 반환하지만, 그 값을 VARCHAR(5) 컬럼에 다시
-- INSERT하려고 하면 에러가 날 수 있는" 쿼리는?
--
--   (A) SELECT COALESCE(membership_code, '정보없음(장기미접속)') FROM null_lab_customer;
--   (B) INSERT INTO null_lab_memo_staging(memo)
--       SELECT COALESCE(membership_code, '정보없음(장기미접속)') FROM null_lab_customer;
--
--   ① (A)만 해당
--   ② (B)만 해당
--   ③ (A), (B) 둘 다 해당
--   ④ 둘 다 해당 없음(둘 다 항상 안전)
--
-- 답: (      )
-- =====================================================================


-- =====================================================================
-- Q3. (SQL 작성) null_lab_customer에서 age가 0인 행(실제로는 결측을 0으로
-- 잘못 입력한 것으로 간주)을 NULL로 바꿔서 age, nullif 결과를 함께
-- 조회하시오. (NULLIF 사용, Oracle/SQL Server 공통 문법으로 작성 가능)
--
-- 여기에 작성:



-- =====================================================================
-- Q4. (SQL 작성) null_lab_customer의 join_date가 NULL인 행에는 '정보없음'을,
-- 나머지 행에는 'YYYY-MM-DD' 형식 문자열을 반환하는 쿼리를 작성하시오.
-- (join_date를 COALESCE에 바로 넣으면 에러가 난다는 것을 기억할 것 —
-- Oracle은 TO_CHAR, SQL Server는 CONVERT(VARCHAR(10), ..., 120)을 먼저
-- 적용해야 한다.)
--
-- Oracle 버전 작성:



-- SQL Server 버전 작성:


