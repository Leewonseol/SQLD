-- JOIN×NULL 통합 예제 실행 (Oracle)
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- 규칙: 모든 INSERT는 "SELECT 'ID', 1, <검증할 핵심 수치>, <문자열 또는 NULL>,
-- SYSDATE FROM ..."  형태다. actual_row_count는 항상 리터럴 1(이 INSERT가
-- sql_example_result에 남기는 물리적 행 수)이고, 실제로 비교하려는 COUNT/그룹수/
-- 합계는 항상 actual_numeric_value에 담는다. COUNT(*) 값 자체를 actual_row_count에
-- 넣는 이전 방식은 쓰지 않는다(섹션 7 규칙, README 참고).

DELETE FROM sql_example_result WHERE example_id LIKE 'JN%';
COMMIT;

-- #######################################################################
-- A. 조인 키 자체가 NULL인 경우
-- 문제 상황: "권역별 담당 매니저를 붙여서 고객 목록을 뽑아라"는 흔한 요구사항을
--   등가조인(CUSTOMERS.SALES_REGION = REGIONS.SALES_REGION)으로 구현한다.
-- 잘못 이해하기 쉬운 직관: "SALES_REGION이 NULL인 고객은 그냥 매니저가 NULL로
--   나오겠지"(OUTER JOIN을 안 썼다는 사실을 잊고 INNER JOIN 결과에도 나올
--   거라 착각). 그리고 "REGIONS 쪽에도 NULL인 행(R4)이 있으니 그 NULL끼리는
--   서로 매칭되지 않을까?"라는 착각도 흔하다.
-- 3값 논리 평가: C5.SALES_REGION(NULL) = R4.SALES_REGION(NULL) 비교는
--   "NULL = NULL"이며 결과는 UNKNOWN이다(TRUE가 아니다). WHERE/ON 모두
--   UNKNOWN인 조건은 그 행을 통과시키지 않는다.
-- 관련 참조: ../NULL/Oracle/02_examples.sql N04(`= NULL`은 항상 UNKNOWN),
--   ../JOIN-표준JOIN/Oracle/02_examples.sql J06(등가 조인 자체는 이미 그 폴더에서 다룸).
-- 판단 규칙: 등가조인에서 NULL은 어떤 값과도, 심지어 다른 NULL과도 참이 되지 않는다.
-- #######################################################################

-- JN01A. INNER JOIN - 등가조인 키가 NULL이면 매칭 자체가 성립하지 않아 제외된다.
-- 조회용 SELECT (사람이 직접 확인):
SELECT c.customer_id, c.sales_region, r.manager_name
FROM customers c JOIN regions r ON c.sales_region = r.sales_region;
-- 단계별: ①SUL(C1,C2) x R1 → 2행 ②SUDESTE(C3,C4,C7) x R2 → 3행
--         ③C5/C6(NULL) → 어떤 R.sales_region과 비교해도 UNKNOWN → 매칭 0행
-- 예상 행 수: 5행
INSERT INTO sql_example_result
SELECT 'JN01A', 1, COUNT(*), NULL, SYSDATE
FROM customers c JOIN regions r ON c.sales_region = r.sales_region;

-- JN01B. LEFT OUTER JOIN - 같은 조건, 이번엔 왼쪽(CUSTOMERS) 전체를 보존한다.
--   C5,C6은 매칭 후보가 없으므로(R4도 NULL이라 매칭 안 됨) REGIONS 쪽 열이
--   NULL로 채워진 채로 "미매칭 보존행"으로 남는다 - INNER에서 사라졌던
--   2명이 그대로 다시 나타난다는 것이 이 예제의 핵심.
SELECT c.customer_id, c.sales_region, r.manager_name
FROM customers c LEFT OUTER JOIN regions r ON c.sales_region = r.sales_region;
-- 예상 행 수: 7행 (매칭 5 + C5,C6 미매칭 보존 2)
INSERT INTO sql_example_result
SELECT 'JN01B', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN regions r ON c.sales_region = r.sales_region;

-- #######################################################################
-- B. OUTER JOIN이 새로 만드는 NULL
-- 문제 상황: LEFT JOIN 결과에서 NULL이 보이면 "원래 그 값이 NULL이었다"와
--   "매칭되는 행이 아예 없어서 OUTER JOIN이 채워 넣은 NULL이다"를 구분해야
--   실무에서 "왜 주문이 없다고 나오지, 얘는 주문했는데?"류의 오탐을 막을 수 있다.
-- 잘못 이해하기 쉬운 직관: LEFT JOIN 결과의 NULL은 전부 "그 행이 존재하지 않는다"는
--   뜻이라고 뭉뚱그려 생각하기 쉽다. 하지만 ORDERS.AMOUNT가 원래부터 NULL로
--   저장된 행(O2, O7)도 있다 - 이 행은 주문 자체는 "존재"하며 order_id도
--   NULL이 아니다.
-- 식별 방법: 오른쪽 테이블의 PK(order_id, NOT NULL 보장)를 검사한다.
--   order_id가 NULL이면 그 행 자체가 OUTER JOIN이 만든 패딩이고, order_id가
--   NULL이 아닌데 다른 열(amount)이 NULL이면 그건 원본에 저장된 진짜 NULL이다.
-- 관련 참조: ../NULL/Oracle/02_examples.sql N28(OUTER JOIN으로 생성된 NULL,
--   식별 자체는 유사), 이 예제는 거기서 한 걸음 더 나가 "패딩 NULL 대 원본 NULL"을
--   같은 결과집합 안에서 직접 나눠서 센다는 점이 다르다.
-- 판단 규칙: LEFT JOIN 결과의 NULL을 보면 먼저 오른쪽 PK부터 확인하라.
-- #######################################################################

-- JN02A. 패딩 NULL - order_id가 NULL인 행은 "주문 자체가 없다"는 뜻이다.
SELECT c.customer_id, o.order_id, o.amount
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
-- 예상 행 수: 2행 (C5, C7 - 주문이 아예 없는 고객)
INSERT INTO sql_example_result
SELECT 'JN02A', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- JN02B. 원본 NULL - order_id는 존재(NOT NULL)하지만 amount만 NULL인 행.
SELECT c.customer_id, o.order_id, o.amount
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NOT NULL AND o.amount IS NULL;
-- 예상 행 수: 2행 (O2/C1, O7/C6 - 주문은 있지만 금액이 아직 확정되지 않음)
INSERT INTO sql_example_result
SELECT 'JN02B', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NOT NULL AND o.amount IS NULL;

-- #######################################################################
-- C. ON 필터와 WHERE 필터의 차이 (null-rejecting predicate)
-- 문제 상황: "100원 넘게 결제한 주문만 보여줘, 그런 주문이 없는 고객도 목록에는
--   남겨줘"라는 요구를 LEFT JOIN으로 구현할 때, amount>100 조건을 ON에 쓰느냐
--   WHERE에 쓰느냐로 결과가 완전히 달라진다.
-- 잘못 이해하기 쉬운 직관: "LEFT JOIN을 썼으니 조건을 ON에 쓰든 WHERE에
--   쓰든 왼쪽 테이블(CUSTOMERS)은 항상 다 보존되겠지"라는 착각.
-- 3값 논리 평가: WHERE는 LEFT JOIN이 만든 최종 결과 집합 전체에 대해 한 번 더
--   평가된다. 미매칭 보존행은 o.amount가 NULL이므로 "NULL > 100"은 UNKNOWN이고,
--   UNKNOWN은 WHERE를 통과하지 못해 행 자체가 사라진다. 반면 ON 안의 조건은
--   "이 오른쪽 행을 매칭 후보로 인정할지"만 결정할 뿐, 매칭 후보가 하나도 없어도
--   LEFT JOIN은 왼쪽 행을 NULL로 채워 그대로 보존한다.
-- 안전한 대체: 왼쪽 행을 반드시 보존해야 한다면 조건을 ON에 넣는다. WHERE에서
--   오른쪽 열을 걸러야 한다면 그 순간부터는 사실상 INNER JOIN과 같아진다는
--   것을 인지하고 써야 한다.
-- 관련 참조: 이 개념은 ../JOIN-표준JOIN/README.md의 "6. JOIN 뒤에 추가 WHERE
--   조건이 있는가"(J19)와 같은 뿌리이지만, J19는 결과 행 수 자체만 보여줄 뿐
--   ON과 WHERE를 나란히 비교하지 않는다 - 이 예제가 그 비교를 완성한다.
-- 판단 규칙: ON은 매칭을 제한하고 WHERE는 결과 행을 제한한다.
-- #######################################################################

-- JN03A. 조건을 ON 안에 둔다 - 매칭 후보만 줄어들 뿐, 왼쪽 7명은 전부 남는다.
SELECT c.customer_id, o.order_id, o.amount
FROM customers c LEFT OUTER JOIN orders o
  ON c.customer_id = o.customer_id AND o.amount > 100;
-- 단계별: C2(O3=200)와 C4(O4=150)만 매칭후보 통과, 나머지 5명(C1,C3,C5,C6,C7)은
--   자신의 주문이 조건을 만족하지 못해(또는 주문이 없어) 매칭 0건 -> NULL로 보존.
--   즉 "매칭되는 주문이 없는 고객"으로 취급되지만 행 자체는 사라지지 않는다.
-- 예상 행 수: 7행 (고객 수와 동일)
INSERT INTO sql_example_result
SELECT 'JN03A', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN orders o
  ON c.customer_id = o.customer_id AND o.amount > 100;

-- JN03B. 같은 조건을 WHERE로 옮긴다 - LEFT JOIN이 보존한 행까지 다시 제거된다.
SELECT c.customer_id, o.order_id, o.amount
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.amount > 100;
-- 단계별: 먼저 순수 등가조인(ON)만으로 8행짜리 LEFT JOIN 결과(JN04A)를 만든 뒤,
--   WHERE o.amount>100을 그 8행 전체에 적용한다. NULL이거나 100 이하인 행은
--   전부 UNKNOWN/FALSE로 걸러진다 - 결국 O3(200), O4(150) 두 건만 남고,
--   LEFT JOIN이 애써 보존했던 미매칭 고객(C5,C7)과 금액NULL 주문(O2,O7)까지
--   전부 사라진다. amount>100은 "null-rejecting predicate"(NULL이 낀 행을
--   항상 걸러내는 조건)의 전형적인 예다.
-- 예상 행 수: 2행 -> ON(7행)보다 반드시 작아야 한다(메타모픽 검증, 03_verify.sql)
INSERT INTO sql_example_result
SELECT 'JN03B', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.amount > 100;

-- #######################################################################
-- D. COUNT(*)와 COUNT(우측열)
-- 문제 상황: "고객당 주문 몇 건?"을 LEFT JOIN 뒤 COUNT로 셀 때, COUNT(*)와
--   COUNT(특정 열)이 서로 다른 답을 낸다는 것, 그리고 그 열이 NOT NULL이
--   보장되는 키인지 아닌지에 따라서도 또 달라진다는 것을 보여준다.
-- 잘못 이해하기 쉬운 직관: "LEFT JOIN 결과 행 수만큼 다 세어지겠지"라는 생각으로
--   COUNT(*)와 COUNT(아무 열)을 같은 값으로 착각하기 쉽다.
-- 3값 논리 평가: COUNT(*)는 NULL 여부와 무관하게 행 자체를 센다. COUNT(열)은
--   그 열 값이 NULL이 아닌 행만 센다 - 이때 "그 열이 왜 NULL인가"(패딩이라서
--   NULL, 아니면 원본이 NULL이라서 NULL)는 구분하지 않고 무조건 제외한다.
-- 관련 참조: ../NULL/Oracle/02_examples.sql N11/N12(COUNT(*)/COUNT(열) 기본),
--   ../JOIN-표준JOIN/Oracle/02_examples.sql J21/J21B(LEFT JOIN 뒤 COUNT 차이,
--   단 그 예제는 order_id 하나만 비교하고 nullable 일반 열과의 3중 대비는 없다).
--   이 예제가 order_id(NOT NULL 보장 키)와 amount(nullable 일반 열)를 함께
--   대비해 "같은 LEFT JOIN 결과에서도 어떤 열을 세느냐로 의미가 또 갈린다"는
--   점을 추가한다.
-- 판단 규칙: COUNT(*) >= COUNT(NOT NULL 키) >= COUNT(nullable 일반열)이 항상 성립한다.
-- #######################################################################

SELECT COUNT(*) AS cnt_star, COUNT(o.order_id) AS cnt_key, COUNT(o.amount) AS cnt_col
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id;

-- JN04A. COUNT(*) - 패딩행까지 전부 센다.
-- 예상 값: 8 (2+1+1+1+1+1+1, C1만 주문 2건이라 2행)
INSERT INTO sql_example_result
SELECT 'JN04A', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id;

-- JN04B. COUNT(o.order_id) - NOT NULL이 보장된 오른쪽 PK, 패딩행(C5,C7)만 제외.
-- 예상 값: 6
INSERT INTO sql_example_result
SELECT 'JN04B', 1, COUNT(o.order_id), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id;

-- JN04C. COUNT(o.amount) - nullable 일반 열, 패딩행 2건 + 원본 NULL(O2,O7) 2건 제외.
-- 예상 값: 4 -> COUNT(*)=8 >= COUNT(order_id)=6 >= COUNT(amount)=4
INSERT INTO sql_example_result
SELECT 'JN04C', 1, COUNT(o.amount), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id;

-- #######################################################################
-- E. 안전한 안티조인 3종 비교 ("주문이 없는 고객은 누구인가")
-- 문제 상황: 같은 질문에 대해 서로 다른 SQL 패턴 3개를 나란히 실행한다.
-- 잘못 이해하기 쉬운 직관: 세 방법 모두 "논리적으로 같은 걸 물어보니 결과도
--   당연히 같겠지"라고 생각하기 쉽다. 실제로는 ORDERS에 고아 주문(O5, O8 -
--   customer_id가 NULL)이 섞여 있다는 사실 하나만으로 NOT IN이 완전히
--   다른(틀린) 답을 낸다.
-- 3값 논리 평가: NOT IN은 내부적으로 여러 개의 `<>`를 AND로 묶은 것과 같다.
--   목록에 NULL이 하나라도 있으면 그 NULL과의 `<>` 비교가 UNKNOWN이 되고,
--   AND로 묶인 전체 조건도 UNKNOWN이 되어 버려 어떤 행도 통과하지 못한다.
--   NOT EXISTS는 상관 서브쿼리의 존재 여부만 boolean으로 확인하므로 이 함정에
--   걸리지 않는다.
-- 안전한 대체: NOT IN을 꼭 써야 한다면 서브쿼리에 `WHERE 열 IS NOT NULL`을
--   추가해 NULL을 미리 제거한다(JN05D).
-- 관련 참조: ../NULL/Oracle/02_examples.sql N22(서브쿼리 NOT IN과 NULL 함정,
--   단 그 예제는 JOIN 없이 단일 목록 비교만 다룬다) - 여기서는 그 함정이
--   "주문 없는 고객 찾기"라는 실제 안티조인 업무에서 어떻게 재현되는지,
--   그리고 LEFT JOIN+IS NULL·NOT EXISTS라는 안전한 대안과 나란히 비교한다는
--   점이 다르다.
-- 판단 규칙: 서브쿼리에 NULL 가능성이 있으면 NOT IN보다 NOT EXISTS(또는
--   LEFT JOIN+IS NULL)가 안전하다.
-- #######################################################################

-- JN05A. LEFT JOIN + IS NULL(정상) - JN02A와 같은 쿼리, 이번엔 "안티조인
-- 기법으로서" 다시 확인한다.
SELECT c.customer_id
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
-- 예상 행 수: 2 (C5, C7)
INSERT INTO sql_example_result
SELECT 'JN05A', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- JN05B. NOT EXISTS(정상) - 상관 서브쿼리라 목록에 NULL이 있어도 영향받지 않는다.
SELECT c.customer_id
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
-- 예상 행 수: 2 (JN05A와 반드시 같아야 한다 - 메타모픽 검증)
INSERT INTO sql_example_result
SELECT 'JN05B', 1, COUNT(*), NULL, SYSDATE
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);

-- JN05C. NOT IN(함정) - 서브쿼리 목록에 O5/O8의 NULL customer_id가 섞여 있다.
SELECT c.customer_id
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM orders o);
-- 예상 행 수: 0 (직관과 달리 C5,C7도 나오지 않는다 - JN05A/B의 2행과 반드시
--   달라야 한다는 것이 이 예제의 핵심 대조)
INSERT INTO sql_example_result
SELECT 'JN05C', 1, COUNT(*), NULL, SYSDATE
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM orders o);

-- JN05D. NOT IN 안전 대안 - 서브쿼리에서 NULL을 먼저 제거한다.
SELECT c.customer_id
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM orders o WHERE o.customer_id IS NOT NULL);
-- 예상 행 수: 2 (NULL을 치우면 NOT IN도 다시 정상 동작한다)
INSERT INTO sql_example_result
SELECT 'JN05D', 1, COUNT(*), NULL, SYSDATE
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM orders o WHERE o.customer_id IS NOT NULL);

-- #######################################################################
-- F. 안티조인에서 검사 열을 잘못 선택하는 경우
-- 문제 상황: LEFT JOIN + IS NULL 패턴 자체는 맞게 썼어도, IS NULL로 검사하는
--   열을 잘못 고르면 또 다른 함정에 빠진다.
-- 잘못 이해하기 쉬운 직관: "오른쪽 테이블 아무 열이나 IS NULL로 검사하면 되겠지"
--   -- amount처럼 nullable한 일반 열을 검사 대상으로 고르는 실수.
-- 3값 논리 평가는 A~E와 다르지 않지만, 여기서 갈리는 것은 "어떤 행 집합이
--   그 조건을 만족하느냐"다. order_id는 오른쪽 테이블의 PK(NOT NULL 보장)라서
--   IS NULL이면 "그 행 자체가 패딩"이라는 뜻이 명확하다. amount는 매칭된
--   진짜 주문에서도 NULL일 수 있으므로(O2, O7), "주문이 없다"와 "주문은
--   있는데 금액만 모른다"가 뒤섞여 버린다.
-- 관련 참조: B(JN02A/JN02B)에서 이미 나눠뒀던 "패딩 NULL 대 원본 NULL" 구분을
--   그대로 재사용해, 검사 열을 잘못 고르면 그 구분이 무너진다는 것을 보여준다.
-- 판단 규칙: 안티조인에서는 항상 우측의 NOT NULL 보장 키(대개 PK)를 검사한다.
-- #######################################################################

-- JN06A. 올바른 검사열 - order_id IS NULL.
SELECT c.customer_id
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
-- 예상 행 수: 2 (C5, C7만 - JN02A/JN05A와 동일)
INSERT INTO sql_example_result
SELECT 'JN06A', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- JN06B. 잘못된 검사열 - amount IS NULL.
SELECT c.customer_id, o.order_id, o.amount
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.amount IS NULL;
-- 단계별: 이 조건을 만족하는 행은 4개 - C5/C7(패딩, order_id도 NULL) +
--   C1(O2, order_id는 있지만 amount만 NULL) + C6(O7, 마찬가지). C1은 사실
--   O1이라는 100원짜리 정상 주문도 있는 고객인데도 "주문 없는 고객" 후보에
--   섞여 나온다 - nullable 일반 열 검사의 대표적 오류.
-- 예상 행 수: 4 (JN06A의 2행과 반드시 달라야 한다)
INSERT INTO sql_example_result
SELECT 'JN06B', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.amount IS NULL;

-- #######################################################################
-- G. 집계와 OUTER JOIN
-- 문제 상황: 고객별 총 구매액을 LEFT JOIN + SUM으로 집계할 때, "구매는 했지만
--   총액이 0원(환불 등)인 고객"과 "아예 주문이 없는 고객"을 구분해야 한다.
-- 잘못 이해하기 쉬운 직관: "주문이 없으면 합계도 0이겠지" - SUM은 매칭되는
--   행이 하나도 없으면 0이 아니라 NULL을 반환한다는 사실을 놓치기 쉽다.
-- 3값 논리 평가: SUM은 그룹 안의 NULL이 아닌 값만 더한다. 그룹 자체가
--   비어 있으면(매칭 행이 0개) 더할 값이 없으므로 결과는 NULL이다. C3처럼
--   실제 주문 금액이 0인 경우와는 완전히 다른 상황이지만, NVL/COALESCE로
--   기본값 0을 채우고 나면 최종 표시값(0)만으로는 둘을 구분할 수 없다 -
--   그래서 이 예제는 최종값뿐 아니라 "원본 SUM이 NULL이었는지" 자체도 함께 검증한다.
-- 관련 참조: ../NULL/Oracle/02_examples.sql N14/N15(SUM/AVG의 NULL 제외),
--   N19(0행 집계는 NULL을 가진 1행을 반환) - 그 예제들은 JOIN 없이 단일
--   테이블의 집계만 다룬다. 여기서는 그 NULL이 "OUTER JOIN이 매칭 행을 하나도
--   못 찾아서" 생긴다는 점이 다르다.
-- 판단 규칙: LEFT JOIN 뒤 집계값이 NULL이면 "매칭 행이 0개"라는 뜻이지,
--   실제 값이 0이라는 뜻이 아니다.
-- #######################################################################

-- JN07A. 실제 합계가 0원인 고객(C3) - 원본 SUM부터 NULL이 아니다.
SELECT c.customer_id, SUM(o.amount) AS raw_sum, NVL(SUM(o.amount), 0) AS safe_sum
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '0054556ea954a76ad6f9c4ba79d34a98' -- C3
GROUP BY c.customer_id;
-- 예상 값: safe_sum=0, 그리고 raw_sum도 이미 0(NULL 아님) -> text_value='RAW_ZERO'
INSERT INTO sql_example_result
SELECT 'JN07A', 1, NVL(SUM(o.amount), 0),
       CASE WHEN SUM(o.amount) IS NULL THEN 'RAW_NULL' ELSE 'RAW_ZERO' END, SYSDATE
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '0054556ea954a76ad6f9c4ba79d34a98'
GROUP BY c.customer_id;

-- JN07B. 주문이 없어 합계가 NULL인 고객(C5) - NVL로 0을 채우면 표시값은
--   JN07A와 똑같이 0이 되지만, 원본은 NULL이었다는 것을 text_value로 구분한다.
SELECT c.customer_id, SUM(o.amount) AS raw_sum, NVL(SUM(o.amount), 0) AS safe_sum
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '006496598c918064dc19eef95e5e47f8' -- C5
GROUP BY c.customer_id;
-- 예상 값: safe_sum=0(JN07A와 같은 값), raw_sum은 NULL -> text_value='RAW_NULL'
INSERT INTO sql_example_result
SELECT 'JN07B', 1, NVL(SUM(o.amount), 0),
       CASE WHEN SUM(o.amount) IS NULL THEN 'RAW_NULL' ELSE 'RAW_ZERO' END, SYSDATE
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = '006496598c918064dc19eef95e5e47f8'
GROUP BY c.customer_id;

-- #######################################################################
-- H. JOIN 결과의 GROUP BY NULL
-- 문제 상황: LEFT JOIN 결과를 GROUP BY할 때, 왼쪽 테이블의 키로 묶느냐
--   오른쪽 테이블의 키로 묶느냐에 따라 그룹 수 자체가 달라진다.
-- 잘못 이해하기 쉬운 직관: "고객별로 묶으나 주문의 고객ID로 묶으나 결국
--   같은 고객 기준 아닌가?"라는 착각. 왼쪽 키(c.customer_id)는 PK라서 NULL이
--   없지만, 오른쪽 키(o.customer_id)는 미매칭 보존행에서 NULL이 되고, GROUP BY는
--   여러 NULL을 "하나의 그룹"으로 묶어버린다 - 서로 다른 고객(C5, C7)의
--   미매칭행이 하나의 NULL 그룹으로 합쳐진다.
-- 관련 참조: ../NULL/Oracle/02_examples.sql N30/N30B(GROUP BY의 NULL, 단일
--   테이블) - 여기서는 그 병합이 "LEFT JOIN이 만든 미매칭 보존행들끼리"
--   일어난다는 점, 그리고 왼쪽 키로 묶으면 애초에 병합이 일어나지 않는다는
--   대조가 추가된다.
-- 판단 규칙: LEFT JOIN 뒤 GROUP BY는 반드시 왼쪽(보존되는 쪽) 키로 묶어야
--   고객 수만큼 그룹이 나온다. 오른쪽 키로 묶으면 미매칭 행들이 하나의
--   NULL 그룹으로 합쳐진다.
-- #######################################################################

-- JN08A. 왼쪽 고객별 그룹 - c.customer_id로 GROUP BY.
SELECT c.customer_id, COUNT(*) AS cnt
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;
-- 예상 그룹 수: 7 (고객 수와 정확히 같다, 미매칭 고객도 자기 그룹 유지)
INSERT INTO sql_example_result
SELECT 'JN08A', 1, COUNT(*), NULL, SYSDATE
FROM (
    SELECT c.customer_id
    FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
);

-- JN08B. 우측 조인키별 그룹 - o.customer_id로 GROUP BY(NULL 그룹 병합 발생).
SELECT o.customer_id, COUNT(*) AS cnt
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY o.customer_id;
-- 예상 그룹 수: 6 (실제 주문고객 5그룹 + 미매칭 NULL 병합그룹 1개)
INSERT INTO sql_example_result
SELECT 'JN08B', 1, COUNT(*), NULL, SYSDATE
FROM (
    SELECT o.customer_id
    FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY o.customer_id
);

-- JN08C. 병합된 NULL 그룹의 실제 크기 - C5와 C7이 한 그룹에 몇 행으로 뭉쳤는가.
SELECT COUNT(*) AS null_group_size
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
-- 예상 값: 2 (서로 다른 고객 C5, C7의 미매칭행이 여기 함께 들어있다)
INSERT INTO sql_example_result
SELECT 'JN08C', 1, COUNT(*), NULL, SYSDATE
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

-- #######################################################################
-- I. FULL OUTER JOIN과 통합 키
-- 문제 상황: CUSTOMERS와 REGIONS를 SALES_REGION으로 FULL OUTER JOIN하면
--   왼쪽 전용(C5,C6), 공통(SUL/SUDESTE 매칭), 오른쪽 전용(R3,R4) 행이 함께
--   나온다. 이후 분석에서 "권역값 하나"로 다루려면 COALESCE로 통합 키를
--   만들어야 한다.
-- 잘못 이해하기 쉬운 직관: "통합 키는 항상 NULL이 아니겠지"(왼쪽이 NULL이면
--   오른쪽 값을, 오른쪽이 NULL이면 왼쪽 값을 쓰니까) - 그러나 양쪽 다 그
--   행의 SALES_REGION 자체가 NULL인 경우(C5,C6 그리고 R4)는 COALESCE도
--   NULL을 반환한다. 이 행들은 서로 매칭도 되지 않아 별도의 행으로 남는다.
-- 3값 논리 평가: FULL OUTER JOIN은 등가조인 조건이 UNKNOWN인 행도(양쪽 다
--   보존 대상이라면) 각각 별도 행으로 남긴다 - NULL과 NULL이 서로 짝이 되어
--   합쳐지는 일은 없다.
-- 관련 참조: ../JOIN-표준JOIN/Oracle/02_examples.sql J13/J13B(FULL OUTER
--   JOIN 기본 동작, NULL 없는 데이터) - 여기서는 조인 키 자체가 NULL인
--   행들이 FULL OUTER JOIN에서 어떻게 되는지가 추가된다.
-- 판단 규칙: FULL OUTER JOIN + COALESCE 통합키를 쓸 때도, 원본 조인 키가
--   NULL인 행은 통합 키 역시 NULL로 남을 수 있다는 것을 잊지 말아야 한다.
-- #######################################################################

SELECT COALESCE(c.sales_region, r.sales_region) AS unified_region,
       c.customer_id, c.sales_region AS c_region, r.region_id, r.sales_region AS r_region
FROM customers c FULL OUTER JOIN regions r ON c.sales_region = r.sales_region;

-- JN09. FULL OUTER JOIN 전체 행 수.
-- 예상 행 수: 9 (매칭 5 + 왼쪽전용 C5,C6=2 + 오른쪽전용 R3,R4=2)
INSERT INTO sql_example_result
SELECT 'JN09', 1, COUNT(*), NULL, SYSDATE
FROM customers c FULL OUTER JOIN regions r ON c.sales_region = r.sales_region;

-- JN09B. 통합 키(COALESCE)가 NULL인 행 - 매칭도 안 되고 통합도 안 된 케이스.
-- 예상 값: 3 (C5, C6, R4 - 셋 다 SALES_REGION 자체가 NULL이라 서로 짝짓지
--   못하고 각자 별도 행으로 남으며, 통합 키도 NULL이다. R3(NORDESTE)는
--   오른쪽 전용이지만 그 값 자체는 NULL이 아니므로 통합 키도 NULL이 아니다.)
INSERT INTO sql_example_result
SELECT 'JN09B', 1, COUNT(*), NULL, SYSDATE
FROM customers c FULL OUTER JOIN regions r ON c.sales_region = r.sales_region
WHERE COALESCE(c.sales_region, r.sales_region) IS NULL;

-- #######################################################################
-- J. USING과 NULL
-- 문제 상황: CUSTOMERS와 REGIONS는 조인 열 이름이 둘 다 SALES_REGION으로
--   같으므로 USING (sales_region)을 쓸 수 있다.
-- 핵심: USING도 결국 내부적으로는 등가조인(=)이다. 문법이 짧아졌을 뿐 NULL을
--   대하는 규칙은 조금도 달라지지 않는다 - JN01A(ON 버전)와 정확히 같은
--   5행이 나와야 한다.
-- 관련 참조: ../JOIN-표준JOIN/Oracle/02_examples.sql J15(USING 기본 문법,
--   NULL 없는 데이터) - 여기서는 USING의 조인 열에 NULL이 있을 때도 동작이
--   똑같다는 것만 추가로 확인한다.
-- Oracle/SQL Server 차이: SQL Server는 USING을 지원하지 않는다. 같은 결과를
--   ON customers.sales_region = regions.sales_region으로 재현한다
--   (SQLServer/02_examples.sql JN10 참고).
-- 판단 규칙: USING은 문법일 뿐, NULL 키를 등가조인이 배제한다는 규칙은
--   ON을 쓰든 USING을 쓰든 동일하다.
-- #######################################################################

SELECT customer_id, sales_region, manager_name
FROM customers JOIN regions USING (sales_region);
-- 예상 행 수: 5 (JN01A와 완전히 동일해야 한다 - 메타모픽 검증)
INSERT INTO sql_example_result
SELECT 'JN10', 1, COUNT(*), NULL, SYSDATE
FROM customers JOIN regions USING (sales_region);

-- #######################################################################
-- K. 비등가 조인과 NULL (BETWEEN, 경계값)
-- 문제 상황: 고객 누적 구매액(TOTAL_SPENT)을 구간표(SPEND_BAND)에 BETWEEN으로
--   매칭한다. 경계값(구간 최솟값/최댓값/다음 구간 시작값)과 범위 밖 값, NULL을
--   모두 포함해 INNER/LEFT 결과를 비교한다.
-- 잘못 이해하기 쉬운 직관: "TOTAL_SPENT가 NULL이면 어느 구간에도 안 걸릴
--   테니 그냥 첫 구간(B1)에 들어가거나 별도 처리가 되겠지"라는 착각 -
--   실제로는 "NULL BETWEEN lo AND hi"도 다른 비교와 마찬가지로 UNKNOWN이라
--   INNER JOIN에서 조용히 사라질 뿐, 어떤 예외 처리도 자동으로 일어나지 않는다.
--   범위를 완전히 벗어난 값(2500)도 매칭되지 않는다는 점에서는 NULL과
--   결과가 같아 보이지만 원인은 다르다(하나는 FALSE, 하나는 UNKNOWN).
-- 3값 논리 평가: 경계값 300(B1 상한)과 301(B2 하한)은 각각 정확히 한 구간에만
--   속하도록(겹치지 않게) 설계했으므로 <=, >= 경계가 올바르게 동작하는지도
--   함께 확인된다. NULL은 그 어떤 경계 비교에서도 UNKNOWN이다.
-- 관련 참조: ../JOIN-표준JOIN/Oracle/02_examples.sql J07(비등가조인 기본,
--   NULL 없는 데이터) - 여기서는 경계값과 NULL을 함께 넣어 INNER/LEFT
--   결과가 갈리는 지점까지 본다는 점이 다르다.
-- 판단 규칙: 비등가조인에서도 NULL은 예외 없이 UNKNOWN이며, 범위 밖 값과는
--   결과(매칭 안 됨)는 같아도 원인이 다르다.
-- #######################################################################

-- JN11A. INNER JOIN(BETWEEN) - 경계값 포함, NULL과 범위 밖 값은 제외.
SELECT s.customer_id, s.total_spent, b.band
FROM customer_spend s JOIN spend_band b ON s.total_spent BETWEEN b.lo AND b.hi;
-- 예상 행 수: 5 (C1=0, C2=300, C3=301, C6=1000, C7=1001 매칭 / C4=2500 범위밖,
--   C5=NULL 제외)
INSERT INTO sql_example_result
SELECT 'JN11A', 1, COUNT(*), NULL, SYSDATE
FROM customer_spend s JOIN spend_band b ON s.total_spent BETWEEN b.lo AND b.hi;

-- JN11B. LEFT JOIN(BETWEEN) - 매칭 안 되는 고객(C4, C5)도 band 열이 NULL로 보존.
SELECT s.customer_id, s.total_spent, b.band
FROM customer_spend s LEFT OUTER JOIN spend_band b ON s.total_spent BETWEEN b.lo AND b.hi;
-- 예상 행 수: 7 (고객 수와 동일 - INNER에서 사라졌던 C4, C5가 다시 보존됨)
INSERT INTO sql_example_result
SELECT 'JN11B', 1, COUNT(*), NULL, SYSDATE
FROM customer_spend s LEFT OUTER JOIN spend_band b ON s.total_spent BETWEEN b.lo AND b.hi;

-- #######################################################################
-- L. 복합 조인 키 일부가 NULL인 경우
-- 문제 상황: "같은 고객, 같은 날짜에 발생한 이벤트를 주문에 붙인다"는
--   복합 조인(ON a.customer_id=b.customer_id AND a.event_date=b.event_date)을
--   ORDERS·ORDER_EVENTS 사이에 건다.
-- 잘못 이해하기 쉬운 직관: "두 열 중 하나만 NULL이면 나머지 한 열이라도 맞으면
--   부분적으로 매칭되지 않을까?"라는 착각, 그리고 "양쪽 다 NULL이면 그 자체가
--   특별한 '미상 대 미상'의 매칭 아닐까?"라는 착각.
-- 3값 논리 평가: AND로 묶인 조건은 두 비교 중 하나라도 UNKNOWN이면 전체가
--   TRUE가 될 수 없다(UNKNOWN AND TRUE = UNKNOWN, UNKNOWN AND UNKNOWN =
--   UNKNOWN). E2(고객 일치, 날짜 NULL)와 E3(날짜 일치, 고객 NULL)는 각각
--   한 쪽 비교가 UNKNOWN이라 실패하고, E4/O8(둘 다 NULL)은 같은 위치의 값이
--   똑같이 NULL이어도 "NULL=NULL"이 UNKNOWN이므로 역시 실패한다.
-- 관련 참조: A(JN01)의 단일 열 NULL 배제 규칙이 복합키에서도 "AND로 묶인
--   각 비교마다" 그대로 적용된다는 것을 보여준다 - 새로운 규칙이 아니라
--   같은 규칙의 확장이다.
-- 판단 규칙: 복합 조인 조건 중 하나라도 UNKNOWN이면 AND 전체는 TRUE가 아니다.
-- #######################################################################

-- JN12. 복합키 INNER JOIN - 두 열이 모두 일치하는 O1/E1만 남는다.
SELECT o.order_id, o.customer_id, o.order_date, e.event_id, e.event_type
FROM orders o JOIN order_events e
  ON o.customer_id = e.customer_id AND o.order_date = e.event_date;
-- 예상 행 수: 1 (O1-E1만; O2/E3는 날짜만 같고 고객 NULL, O3/E2는 고객만
--   같고 날짜 NULL, O8/E4는 두 열 다 NULL이라 전부 매칭 실패)
INSERT INTO sql_example_result
SELECT 'JN12', 1, COUNT(*), NULL, SYSDATE
FROM orders o JOIN order_events e
  ON o.customer_id = e.customer_id AND o.order_date = e.event_date;

-- JN12B. 복합키 LEFT JOIN - ORDERS 8건 전부 보존, O1만 이벤트와 결합.
SELECT o.order_id, e.event_id
FROM orders o LEFT OUTER JOIN order_events e
  ON o.customer_id = e.customer_id AND o.order_date = e.event_date;
-- 예상 행 수: 8 (주문 8건 전부, O1 1건만 이벤트 매칭, 나머지 7건은 이벤트열 NULL)
INSERT INTO sql_example_result
SELECT 'JN12B', 1, COUNT(*), NULL, SYSDATE
FROM orders o LEFT OUTER JOIN order_events e
  ON o.customer_id = e.customer_id AND o.order_date = e.event_date;

-- #######################################################################
-- M. CROSS JOIN과 NULL (조인 조건 존재 여부에 대한 대조 예제)
-- 이 예제는 CROSS JOIN 문법 자체를 새로 가르치지 않는다(그건 ../JOIN-표준JOIN
-- J02/J04/J05가 이미 다룬다). 여기서는 오직 "등가조인은 조인 조건이 있어서
-- NULL 키를 배제하지만, CROSS JOIN은 애초에 조건이 없어 NULL과 무관하게
-- 카티션 곱을 그대로 유지한다"는 대조만 확인한다.
-- 판단 규칙: 조인 조건이 없으면 NULL도 결과에서 배제될 이유가 없다.
-- #######################################################################

-- JN13. CROSS JOIN - CUSTOMERS(7) x REGIONS(4) = 28, JN01A(5행)와 대조.
SELECT COUNT(*) AS cnt FROM customers CROSS JOIN regions;
INSERT INTO sql_example_result
SELECT 'JN13', 1, COUNT(*), NULL, SYSDATE FROM customers CROSS JOIN regions;

-- #######################################################################
-- N. Oracle (+)와 SQL Server 대응 (반대편 필터에 (+) 누락 시 무력화)
-- 문제 상황: c.customer_id = o.customer_id(+)는 CUSTOMERS를 기준으로 보존하려
--   하지만, 뒤이은 AND o.amount > 100에는 (+)가 없다.
-- "왜"의 정확한 설명: "(+)가 빠져서"라고만 말하면 틀리지는 않지만 왜 그런지는
--   설명하지 않는다. 실제로 벌어지는 일은 C에서 본 것과 완전히 같다 - Oracle의
--   구문형 OUTER JOIN도 결국 WHERE 절 안에서 평가되고, o.amount(+)가 아닌
--   o.amount > 100은 미매칭으로 NULL 패딩된 행에 대해 "NULL > 100" =
--   UNKNOWN을 만들어 그 행을 걸러낸다. (+)는 "이 비교식에서 오른쪽 행이
--   없어도 보존하라"는 표시일 뿐, AND로 추가된 다른 비교식까지 저절로
--   보호해주지 않는다.
-- 관련 참조: 이 예제는 C(JN03B)와 정확히 같은 결과(2행)를 내야 한다 -
--   문법만 옛 스타일(Oracle (+))일 뿐 메커니즘은 WHERE의 null-rejecting
--   predicate와 동일하다는 것이 메타모픽 검증 대상이다.
-- Oracle/SQL Server 차이: SQL Server는 (+) 문법 자체가 없다. 동일한 함정을
--   ANSI LEFT JOIN + WHERE로 재현한다(SQLServer/02_examples.sql JN14 참고,
--   그 쿼리는 사실상 JN03B와 동일한 SQL이 된다).
-- 판단 규칙: (+)가 있어도, 뒤에 AND로 추가된 오른쪽 열 조건에 (+)가 없으면
--   그 조건이 미매칭 보존행을 UNKNOWN으로 만들어 다시 제거한다.
-- #######################################################################

SELECT c.customer_id, o.amount
FROM customers c, orders o
WHERE c.customer_id = o.customer_id(+)
  AND o.amount > 100;
-- 예상 행 수: 2 (JN03B와 동일)
INSERT INTO sql_example_result
SELECT 'JN14', 1, COUNT(*), NULL, SYSDATE
FROM customers c, orders o
WHERE c.customer_id = o.customer_id(+)
  AND o.amount > 100;

COMMIT;
