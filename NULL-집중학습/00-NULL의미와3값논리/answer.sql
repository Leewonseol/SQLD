-- 00. NULL의 의미와 3값 논리 — 정답 및 해설

-- =====================================================================
-- Q1 정답: ③
--
-- 해설: NOT UNKNOWN의 결과는 UNKNOWN이다(TRUE가 아니다). NOT은 UNKNOWN을
-- 절대 TRUE나 FALSE로 바꾸지 못한다 — "부정하면 반대가 된다"는 2값 논리의
-- 직관이 NULL 앞에서는 깨진다는 것이 이 문제의 핵심.
-- 나머지 선지는 모두 옳다: ①TRUE AND UNKNOWN=UNKNOWN, ②FALSE OR UNKNOWN
-- =UNKNOWN, ④FALSE AND UNKNOWN=FALSE(AND는 FALSE가 하나라도 있으면
-- 무조건 FALSE, 단축 평가).
-- =====================================================================


-- =====================================================================
-- Q2 정답: ③ WHERE score IS NULL
--
-- 해설: ① `score = NULL`, ② `score <> NULL`은 NULL이 비교 연산자에 관여하는
-- 순간 결과가 항상 UNKNOWN이 되어 WHERE에서 어떤 행도 통과시키지 못한다
-- (0행). ④ `NOT score`는애초에 score가 숫자형이라 불리언으로 쓸 수 없어
-- 문법 오류(또는 DBMS에 따라 타입 오류)다. NULL을 판정하는 유일하게 올바른
-- 방법은 `IS NULL`/`IS NOT NULL`뿐이다.
-- =====================================================================


-- =====================================================================
-- Q3 정답: A=UNKNOWN, B=FALSE, C=TRUE, D=UNKNOWN
--
-- 해설:
--   TRUE  AND UNKNOWN = UNKNOWN  (AND는 둘 다 TRUE라야 TRUE, 하나가
--                                  UNKNOWN이면 FALSE를 확정 못 함)
--   FALSE AND UNKNOWN = FALSE    (AND는 FALSE가 하나라도 있으면 다른 값과
--                                  무관하게 무조건 FALSE — 단축 평가)
--   TRUE  OR  UNKNOWN = TRUE     (OR는 TRUE가 하나라도 있으면 다른 값과
--                                  무관하게 무조건 TRUE — 단축 평가)
--   FALSE OR  UNKNOWN = UNKNOWN  (OR는 둘 다 FALSE라야 FALSE, 하나가
--                                  UNKNOWN이면 FALSE를 확정 못 함)
-- =====================================================================


-- =====================================================================
-- Q4 정답
-- =====================================================================
SELECT customer_id, score FROM null_lab_customer
WHERE customer_id NOT IN (
    SELECT customer_id FROM null_lab_customer WHERE score > 80
    UNION ALL
    SELECT customer_id FROM null_lab_customer WHERE score <= 80
);
-- 결과: customer_id 3, 9 (2행) — score가 NULL인 행. `score > 80`도
-- `score <= 80`도 이 두 행에서는 UNKNOWN이라 어느 쪽에도 걸리지 않는다.
-- (이 NOT IN은 부분집합이 NULL 없는 customer_id 목록이라 안전하다 —
-- NOT IN 자체의 NULL 함정은 08 폴더에서 별도로 다룬다.)

-- =====================================================================
-- Q5 정답
-- =====================================================================
SELECT customer_id, score FROM null_lab_customer WHERE score > 80
UNION ALL
SELECT customer_id, score FROM null_lab_customer WHERE score <= 80
UNION ALL
SELECT customer_id, score FROM null_lab_customer WHERE score IS NULL;
-- 12행이 정확히 모두 나온다. "조건 OR NOT(조건)"이 아니라 "조건 OR 조건의
-- 반대 OR 컬럼 IS NULL" 세 조각으로 나눠야 UNKNOWN 몫까지 빠짐없이
-- 커버된다는 것이 이 폴더 전체의 결론이다.
