---
type: sql-practice
pilot: true
category: JOIN-NULL-통합
source_note: "깨우침/JOIN·표준 JOIN 문제 풀이표.md + 깨우침/NULL 정리.md (교차 개념 A~N)"
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# JOIN×NULL 통합 실습

`../JOIN-표준JOIN`과 `../NULL`은 각각 JOIN 문법 전체와 NULL 일반 개념을
**따로** 연습하는 폴더다. 이 폴더는 그 두 폴더를 대체하지 않고 그대로 둔 채,
**JOIN과 NULL이 동시에 등장했을 때만 생기는 결과 변화·논리적 함정·안전한
대체 방법**만 다룬다. JOIN 문법을 처음부터 설명하거나 NULL 3값 논리를
처음부터 설명하는 예제는 이 폴더에 없다 - 그런 예제가 필요하면
`../JOIN-표준JOIN`, `../NULL`을 먼저 보라.

## 0. 목적

이 폴더가 다루는 것과 다루지 않는 것을 명확히 한다.

| 다룬다 | 다루지 않는다(다른 폴더 참고) |
|---|---|
| 조인 키 자체가 NULL이라 등가조인이 매칭되지 않는 것 | 등가/비등가 조인 문법 자체(`../JOIN-표준JOIN` J06/J07) |
| OUTER JOIN이 만든 NULL과 원본 NULL의 구분 | NULL 일반 개념(`= NULL`, `IS NULL`, 3값 논리 자체 - `../NULL` N04~N09) |
| ON과 WHERE에 같은 조건을 넣었을 때 결과가 달라지는 것 | JOIN 문법(ON/USING/NATURAL/구문형/`(+)`) 자체(`../JOIN-표준JOIN` J14~J18) |
| LEFT JOIN 결과에서 COUNT(*)와 COUNT(우측열)이 갈리는 것, 그리고 그 열이 NOT NULL 키인지 여부까지 | COUNT(*)/COUNT(열)의 일반 규칙(`../NULL` N11/N12) |
| NOT IN/NOT EXISTS/LEFT JOIN+IS NULL 세 안티조인의 결과 차이 | NOT IN과 NULL의 일반 규칙(`../NULL` N20~N22) |
| 집계+OUTER JOIN에서 "실제 0"과 "매칭 없어 NULL"의 구분 | SUM/AVG의 NULL 제외 규칙 자체(`../NULL` N14/N15/N19) |

## 1. 선행 학습

이 폴더를 시작하기 전에 아래를 먼저 끝내야 한다.

1. `../JOIN-표준JOIN` - JOIN·표준 JOIN 전체 문법(INNER/LEFT/RIGHT/FULL/CROSS,
   ON/USING/NATURAL/구문형/`(+)`)
2. `../NULL` - NULL 3값 논리(비교, 산술 전파, `IS NULL`, `IN`/`NOT IN`)
3. 집계 함수(COUNT/SUM/AVG/MIN/MAX)의 기본 동작
4. 서브쿼리(단순 서브쿼리, 상관 서브쿼리) 기본 문법

## 2. 기존 자료 조사 결과 (작업 착수 전 판독)

`깨우침/JOIN·표준 JOIN 문제 풀이표.md`, `깨우침/NULL 정리.md`,
`../JOIN-표준JOIN`, `../NULL`, 이 폴더의 구버전, `../_common/*`, Python 검증
스크립트를 모두 읽고 아래 기준으로 분류했다. "구현됨"의 판정 기준은
**준비 데이터 + 조회용 SELECT + `sql_example_result` 적재용 INSERT +
`sql_example_expectation`/CSV 기대값** 네 요소가 실제 파일에 모두 있을
때만이며, README나 주석의 언급만으로는 구현으로 인정하지 않았다.

### 2-1. JOIN 전용에만 완전히 구현된 개념

`../JOIN-표준JOIN/Oracle/01_prepare.sql`+`02_examples.sql`에 준비데이터·
SELECT·INSERT가 있고 `../_common/expected_results.csv`(topic=JOIN)에
기대값이 있는 것을 확인함: J01(테이블수) J02(카티션곱) J03(조건부JOIN)
J04(카티션곱 행수/열수) J05(CROSS JOIN) J06(등가조인) J07(비등가조인)
J08(조인조건 vs 필터) J09(중복값조인) J10(INNER) J11(LEFT) J12(RIGHT)
J13/J13B(FULL) J14(ON, 열이름 다름) J15(USING) J16(NATURAL JOIN)
J17(구문형JOIN) J18(Oracle `(+)`) J19(OUTER JOIN후 WHERE) J20(LEFT JOIN+IS
NULL) J21/J21B(COUNT 차이) J22(별칭) J23(행수계산). 이 24개는 NULL이 조인
결과의 원인이 되는 경우가 없다(J19~J21의 미매칭 행은 "값이 없어서" 생긴
결과 구조이지 조인 키 자체가 NULL이라 발생한 게 아니다) - 그대로 유지.

### 2-2. NULL 전용에만 완전히 구현된 개념

`../NULL/Oracle/01_prepare.sql`+`02_examples.sql`+CSV(topic=NULL)에서 확인:
N01~N36 전부(빈문자열, 비교, IN/NOT IN, 산술전파, 집계함수 NULL처리,
COALESCE/NVL/ISNULL/NULLIF, GROUP BY/DISTINCT/ORDER BY의 NULL, PK/UNIQUE/FK
제약조건). 이 중 JOIN을 전혀 쓰지 않는 것(N01~N27, N30~N36)은 이 폴더와
무관하다.

### 2-3. JOIN 전용과 NULL 전용 양쪽에 부분적으로 겹치는 개념

- **OUTER JOIN + NULL count 차이**: `../JOIN-표준JOIN` J19~J21/J21B(member/
  contact 데이터)와 `../NULL` N28/N29(customer_left/customer_right_order
  데이터)가 각자 독립적으로 "LEFT JOIN 미매칭 행 + COUNT(*) vs COUNT(열)"을
  구현해뒀다. 그러나 둘 다 "패딩 NULL 대 원본 NULL 구분", "COUNT(NOT NULL
  키) 대 COUNT(nullable 일반열) 구분"까지는 다루지 않는다 - 이 간극이 아래
  2-4의 B/D 개념이다.
- **NOT IN + NULL 서브쿼리 함정**: `../NULL` N22(customer_flag_check/
  customer_flag_exclude, JOIN 없이 단일 목록 비교)가 이미 완전히 구현돼
  있다. 이 폴더의 구버전 JN06도 독립적으로 구현했었다(주문 없는 고객
  질문으로 재구성). 두 구현 모두 "NULL이 섞인 서브쿼리는 NOT IN을
  깨뜨린다"는 같은 결론이지만, 이 폴더는 그 위에 LEFT JOIN+IS NULL·NOT
  EXISTS·안전한 NOT IN까지 나란히 비교해야 하므로(요구사항 E) 통합 예제로
  유지한다(아래 4절 판정표 JN06 항목 참고).

### 2-4. 기존 JOIN·NULL 전용에 없고 통합에서 새로 구현해야 하는 교차 개념

- **C. ON 필터 vs WHERE 필터 비교** - JOIN 전용 J19는 WHERE의 위험만 단독으로
  보여줄 뿐 같은 조건을 ON에 넣은 버전과 나란히 비교하지 않는다. 완전히
  새로 구현(JN03A/JN03B).
- **F. 안티조인 검사열 오선택(order_id IS NULL vs amount IS NULL)** - 어느
  폴더에도 없었다. 완전히 새로 구현(JN06A/JN06B).
- **L. 복합 조인 키 일부/양쪽 NULL** - 어느 폴더에도 복합키 예제 자체가
  없었다. 완전히 새로 구현(JN12/JN12B, order_events 테이블 신설).
- **A의 "양쪽 다 NULL이어도 매칭 안 됨"** - 구버전 JN01은 한쪽(고객)만 NULL인
  경우만 다뤘다. REGIONS에 NULL 값(R4)을 추가해 새로 구현(JN01B).
- **I의 "양쪽 조인 키가 모두 NULL이면 별도 두 행으로 남는다"** - 구버전
  JN10은 고객 로열티 PK 조인이라 애초에 NULL 키가 나올 수 없는 구조였다.
  REGIONS 기반으로 재설계해 새로 구현(JN09B).

### 2-5. 구버전 JOIN×NULL 통합에 4요소 중 하나 이상이 없어 미구현이던 것

구버전(JN01~JN14, 이 편집 이전 커밋)을 다시 검토한 결과, 위 2-4에 적은
C/F/L은 **준비 데이터 자체가 없어서** 조회용 SELECT도 INSERT도 애초에
작성될 수 없었던 경우다(4요소 중 1번부터 누락). A의 "양쪽 NULL" 케이스와
I의 "양쪽 NULL 별도 행" 케이스는 준비 데이터에 해당 NULL 조합이 없어서(4요소
중 1번 누락) SELECT/INSERT/기대값이 그 케이스를 검증하지 못했다. 이번
개편에서 데이터를 다시 설계해 전부 채웠다(위 1절 데이터셋 참고).

### 2-6. 검증 스키마·결과 저장 방식의 불일치 (발견 및 수정)

구버전 `Oracle/02_examples.sql`의 JN03, JN06, JN10, JN21(당시 JOIN-표준JOIN
쪽)은 `actual_row_count` 자리에 `COUNT(*)` 값을 직접 넣고 있었다(예:
`SELECT 'JN03', COUNT(*), COUNT(o.order_id), NULL, SYSDATE`). 이러면
"이 INSERT가 남긴 물리적 행 수"와 "검증하려는 COUNT 값"이 같은 컬럼에
뒤섞여, `expected_row_count`도 6·7처럼 실제로는 numeric 값이어야 할 숫자를
담고 있었다. 이번 개편에서는 **모든 JN 예제의 `actual_row_count`를 항상
리터럴 1로 고정**하고, 검증하려는 수치는 예외 없이 `actual_numeric_value`에
담도록 통일했다(3절 참고). 두 수치를 동시에 검증해야 하는 경우
(`COUNT(*)`와 `COUNT(우측열)` 등)는 `JNxxA`/`JNxxB`로 example_id를
분리했다(D, H 개념).

## 3. 검증 스키마 규칙 (이 폴더 전체에 예외 없이 적용)

```text
actual_row_count      = 이 예제의 INSERT SELECT가 sql_example_result에
                         남기는 물리적 행 수. 항상 리터럴 1.
actual_numeric_value  = COUNT/SUM/AVG/그룹수 등 실제로 검증하려는 핵심 수치.
actual_text_value     = 검증하려는 문자열 결과 또는 상태(예: 'RAW_NULL').
```

```sql
-- 올바른 방식(이 폴더 전체가 이 형태다)
INSERT INTO sql_example_result
SELECT 'JN01A', 1, COUNT(*), NULL, SYSDATE
FROM customers c JOIN regions r ON c.sales_region = r.sales_region;

-- 쓰지 않는 방식(구버전의 문제, 2-6 참고)
-- SELECT 'JN01A', COUNT(*), NULL, NULL, SYSDATE FROM ...
```

두 수치를 한 example_id에 억지로 넣지 않고 `JNxxA`/`JNxxB`(필요하면
`JNxxC`/`JNxxD`)로 분리한다(D: JN04A/B/C, E: JN05A/B/C/D, G: JN07A/B, H:
JN08A/B/C). 자세한 스키마 정의는 [`../_common/validation_schema.sql`](../_common/validation_schema.sql)
참고.

## 4. 개념 매트릭스 (A~N, 교차 개념만)

customer_id는 모두 실제 Olist 값(5절 참고). regions/orders/order_events/
customer_spend/spend_band의 PK 문자열·날짜·금액·구간은 합성값이다.

| 예제 ID | 교차 개념 | Oracle 예상값 | SQL Server 예상값 | 기존 폴더 참조 |
|---|---|---:|---:|---|
| JN01A | A. 등가조인 키 NULL - INNER 매칭 제외 | 5 | 5 | `../JOIN-표준JOIN` J06(등가조인 자체) |
| JN01B | A. 등가조인 키 NULL - LEFT OUTER 보존(양쪽 NULL도 매칭안됨) | 7 | 7 | `../JOIN-표준JOIN` J11(LEFT JOIN 자체) |
| JN02A | B. OUTER JOIN 패딩 NULL(주문 없음) | 2 | 2 | `../NULL` N28 |
| JN02B | B. 원본 저장 NULL(주문은 있으나 금액 NULL) | 2 | 2 | `../NULL` N06(IS NULL 자체) |
| JN03A | C. ON 필터 - 매칭 후보만 제한 | 7 | 7 | `../JOIN-표준JOIN` J19(WHERE 위험만 단독 설명) |
| JN03B | C. WHERE 필터 - 보존행 제거(null-rejecting) | 2 | 2 | `../JOIN-표준JOIN` J19 |
| JN04A | D. COUNT(*) | 8 | 8 | `../JOIN-표준JOIN` J21 |
| JN04B | D. COUNT(NOT NULL 키) | 6 | 6 | `../JOIN-표준JOIN` J21B |
| JN04C | D. COUNT(nullable 일반열) | 4 | 4 | `../NULL` N12 |
| JN05A | E. 안티조인 - LEFT JOIN+IS NULL | 2 | 2 | `../JOIN-표준JOIN` J20 |
| JN05B | E. 안티조인 - NOT EXISTS | 2 | 2 | (신규) |
| JN05C | E. 안티조인 - NOT IN(함정) | 0 | 0 | `../NULL` N22 |
| JN05D | E. 안티조인 - NOT IN 안전 대안 | 2 | 2 | `../NULL` N22 |
| JN06A | F. 검사열 - order_id IS NULL(정답) | 2 | 2 | (신규) |
| JN06B | F. 검사열 - amount IS NULL(오답) | 4 | 4 | (신규) |
| JN07A | G. 실제 합계 0(C3) | 0 (`RAW_ZERO`) | 0 (`RAW_ZERO`) | `../NULL` N14 |
| JN07B | G. 주문없어 합계 NULL(C5) | 0 (`RAW_NULL`) | 0 (`RAW_NULL`) | `../NULL` N19 |
| JN08A | H. GROUP BY c.customer_id(왼쪽 그룹) | 7 | 7 | `../NULL` N30 |
| JN08B | H. GROUP BY o.customer_id(우측키, NULL병합) | 6 | 6 | `../NULL` N30B |
| JN08C | H. 병합 NULL 그룹 크기 | 2 | 2 | (신규) |
| JN09 | I. FULL OUTER JOIN 행수 | 9 | 9 | `../JOIN-표준JOIN` J13/J13B |
| JN09B | I. 통합키(COALESCE) NULL 개수 | 3 | 3 | (신규) |
| JN10 | J. USING과 NULL 키 | 5 | 5 | `../JOIN-표준JOIN` J15 |
| JN11A | K. 비등가조인(BETWEEN) INNER, 경계값 | 5 | 5 | `../JOIN-표준JOIN` J07 |
| JN11B | K. 비등가조인(BETWEEN) LEFT, 보존 | 7 | 7 | (신규) |
| JN12 | L. 복합 조인키 일부/양쪽 NULL - INNER | 1 | 1 | (신규) |
| JN12B | L. 복합 조인키 - LEFT 보존 | 8 | 8 | (신규) |
| JN13 | M. CROSS JOIN 대조 | 28 | 28 | `../JOIN-표준JOIN` J05 |
| JN14 | N. Oracle `(+)` 반대편 필터 누락 함정 | 2 | 2(ANSI 대응) | `../JOIN-표준JOIN` J18 |

전체 정답표는 [`../_common/expected_results.csv`](../_common/expected_results.csv)에
`topic=JOIN_NULL`로 필터링해서 볼 수 있다(29개 example_id x 2 DBMS = 58행).

## 5. 기존 통합 예제 처리 결과 (구버전 JN01~JN14 판정)

| 기존 ID | 판정 | 사유·근거 |
|---|---|---|
| 구 JN01(등가조인 키 NULL) | 통합 | 한쪽만 NULL인 경우만 다뤘던 것을 JN01A로 이관, 양쪽 NULL·LEFT 대비를 JN01B로 확장 |
| 구 JN02(LEFT OUTER JOIN이 만드는 NULL) | 통합 | JN02A(패딩)/JN02B(원본)로 분리 확장 - 원래는 패딩 NULL만 셌다 |
| 구 JN03(COUNT(*) vs COUNT(우측열), 단순 COUNT 차이) | 통합 | JN04A/B/C로 확장(order_id뿐 아니라 amount까지 3중 대비), `actual_row_count` 오용도 함께 수정(2-6 참고) |
| 구 JN04(OUTER JOIN 후 WHERE 제거 함정) | 통합 | ON 버전(JN03A)과 나란히 비교하는 형태로 재구성(JN03B) |
| 구 JN05(LEFT JOIN+IS NULL 안티조인) | 통합 | JN05A로 이관, NOT EXISTS(JN05B)·안전한 NOT IN(JN05D) 추가 |
| 구 JN06(NOT IN 서브쿼리 함정) | 통합 | JN05C로 이관. `../NULL` N22이 이미 NULL만의 버전을 구현했지만, 이 폴더는 3종 안티조인 비교(요구사항 E)의 한 축이므로 JOIN 요소(고아 주문)가 결과의 직접 원인이라 통합 유지 |
| 구 JN07(COALESCE로 미매칭 집계값 기본값 치환, **단순 COALESCE**) | 통합 | OUTER JOIN이 만든 NULL을 COALESCE/NVL/ISNULL로 처리한다는 점에서 JOIN이 결과 발생의 직접 원인 - JN07A/B로 확장하며 "실제 0 대 NULL" 구분을 추가(원래는 이 구분이 없었다) |
| 구 JN08(JOIN 결과 집계에서 NULL 제외, **일반 AVG와 NULL**) | **NULL 전용 참조로 전환, 통합 폴더에서 제거** | AVG가 NULL을 제외한다는 동작 자체는 JOIN을 빼도 동일하게 성립한다(`../NULL/Oracle/02_examples.sql` N15가 이미 준비데이터·SELECT·INSERT·기대값을 모두 갖춰 구현함). JOIN은 그저 값을 실어 나르는 매개일 뿐 결과 발생의 원인이 아니므로 4절 판정 기준(NULL 전용 참조로 넘길 조건)에 해당한다 |
| 구 JN09(LEFT JOIN + GROUP BY의 NULL 그룹, **단순 GROUP BY NULL**) | 통합 | JN08A/B/C로 확장 - 원래는 우측 키 그룹(JN08B에 해당)만 있었고, 왼쪽 키 그룹(JN08A)과의 대비·병합 그룹 크기(JN08C)가 없었다 |
| 구 JN10(FULL OUTER JOIN + COALESCE 키 병합) | 통합 | JN09/JN09B로 재설계 - CUSTOMER_LOYALTY(PK 조인이라 NULL 키 자체가 불가능한 구조)를 REGIONS 기반으로 바꿔 "양쪽 다 NULL" 케이스(요구사항 I 2번째 조건)를 추가했다 |
| 구 JN11(USING과 NULL 키) | 통합 | JN10으로 번호만 재배치(JN01A와 동일한 5행이 되도록 데이터 재설계에 맞춰 기대값 갱신) |
| 구 JN12(비등가조인 경계값 NULL) | 통합 | JN11A/B로 확장 - 원래는 경계값(최솟값/최댓값/다음구간 시작값)이 없었고 INNER만 있었다. 경계값 전체 세트와 LEFT 대비를 추가 |
| 구 JN13(CROSS JOIN은 NULL과 무관, **단순 CROSS JOIN**) | 통합(축소·재구성) | CROSS JOIN 문법 자체를 가르치지 않고 JN01A(등가조인)와의 행수 대조 목적으로만 남김(요구사항 M) - 새 데이터에 맞춰 28행으로 갱신 |
| 구 JN14(Oracle `(+)` 반대편 필터 누락) | 통합 | JN14로 유지하되 JN03B(ON/WHERE 비교)와 정확히 같은 메커니즘이라는 설명을 추가하고 데이터 재설계에 맞춰 2행 유지 |

**삭제한 예제는 없다.** 구 JN08만 "NULL 전용 참조"로 전환해 통합 폴더에서
제거했고, 나머지 13개는 전부 통합(확장/재구성)했다.

## 6. 핵심 판단 규칙

- 조인 조건은 TRUE인 행만 매칭한다. NULL과의 일반 비교는 TRUE가 아니라
  UNKNOWN이며, 이는 NULL끼리의 비교(`NULL = NULL`)도 마찬가지다.
- OUTER JOIN은 행을 보존하지만, 그 뒤에 오는 WHERE는 보존된 행을 다시
  제거할 수 있다(null-rejecting predicate). ON은 매칭을 제한하고 WHERE는
  결과 행을 제한한다 - 오른쪽 열 조건을 왼쪽 보존과 함께 쓰려면 ON에 넣는다.
- LEFT JOIN 결과의 NULL을 보면 먼저 오른쪽 PK(NOT NULL 보장)부터 확인하라 -
  PK가 NULL이면 패딩(미매칭), PK는 있는데 다른 열이 NULL이면 원본 데이터다.
- 안티조인에서는 항상 우측의 NOT NULL 보장 키를 검사한다. nullable한 일반
  열로 검사하면 "매칭 자체가 없는 행"과 "매칭은 됐지만 그 값이 NULL인 행"이
  뒤섞인다.
- 서브쿼리에 NULL 가능성이 있으면 NOT IN보다 NOT EXISTS(또는 LEFT JOIN+IS
  NULL)가 안전하다. NOT IN을 꼭 써야 한다면 서브쿼리에서 NULL을 먼저
  제거한다.
- LEFT JOIN 뒤 집계값(SUM 등)이 NULL이면 "매칭 행이 0개"라는 뜻이지 실제
  값이 0이라는 뜻이 아니다. COALESCE/NVL/ISNULL로 채운 최종값만 보고는 이
  둘을 구분할 수 없으므로 원본이 NULL이었는지도 별도로 확인해야 한다.
- LEFT JOIN 뒤 GROUP BY는 왼쪽(보존되는 쪽) 키로 묶어야 원래 개체 수만큼
  그룹이 나온다. 오른쪽 키로 묶으면 서로 다른 미매칭 행들이 하나의 NULL
  그룹으로 합쳐진다.
- FULL OUTER JOIN + COALESCE 통합키를 만들어도, 조인 키 자체가 NULL인
  행끼리는 서로 매칭되지 않으므로 통합키도 NULL로 남을 수 있다.
- 복합 조인 조건은 AND로 묶인 각 비교마다 독립적으로 3값 논리가 적용된다 -
  하나라도 UNKNOWN이면 전체 AND는 TRUE가 아니다.
- 조인 조건이 없으면(CROSS JOIN) NULL도 결과에서 배제될 이유가 없다 - NULL
  배제는 "조인 조건이 있기 때문에" 생기는 현상이다.

## 7. 실행 순서

```
README.md (이 문서)
  -> Oracle/01_prepare.sql   또는   SQLServer/01_prepare.sql
  -> Oracle/02_examples.sql  또는   SQLServer/02_examples.sql
  -> python3 02_validate.py --dbms oracle   (또는 sqlserver, 또는 인자 없이 둘 다)
  -> Oracle/03_verify.sql    또는   SQLServer/03_verify.sql
```

각 DBMS 폴더는 독립적으로 실행 가능하다.

## 8. 데이터 출처와 합성 범위

| 요소 | 출처 |
|---|---|
| `customers.customer_id` 7명 | 전부 실제 `olist_customers_dataset.csv` 값. 6명은 이 폴더 구버전에서 이미 쓰던 값을 재사용, 1명(C7, `...6b5498...`)은 `../NULL/Oracle/02_examples.sql`의 `customer_loyalty`에서 이미 검증된 실제 값을 재사용 |
| `customers.sales_region`, `regions.*` | 이 실습을 위한 합성값(주 구역명은 실존 브라질 지역명을 빌렸을 뿐 컬럼 자체는 Olist 원본에 없음) |
| `orders.*`(order_id, 날짜, 금액) | 전부 합성. Olist 원본에는 주문 테이블이 없다(고객 테이블만 재사용) |
| `orders`의 O5, O8(고아 주문, customer_id NULL) | **실제 원자료에는 없는** 의도적 합성 이상치 - NOT IN 함정(E)과 복합키 양쪽 NULL(L)을 재현하기 위해 삽입 |
| `order_events`, `customer_spend`, `spend_band` | 전부 합성(L, K 개념 전용) |
| 의도적으로 삽입한 NULL | C5/C6의 `sales_region`, R4의 `sales_region`, O2/O7/O8의 `amount`/`customer_id`/`order_date`, E2/E3/E4의 `customer_id`/`event_date`, `customer_spend`의 C5 |

Olist 원본 CSV 자체는 5개 열 전체 결측 0건이다(`../NULL/README.md`,
`Olist-고객데이터/00-데이터사전` 참고) - 이 폴더의 NULL은 전부 실습을 위해
의도적으로 얹은 것이다.

## 9. 검증 테이블

`sql_example_expectation` / `sql_example_result` / `sql_example_validation`
세 테이블의 논리 스키마와 `actual_row_count`/`actual_numeric_value` 사용
규칙은 [`../_common/validation_schema.sql`](../_common/validation_schema.sql) 참고.

## 10. Python 검증 방식과 검증 결과 해석

`02_validate.py`는 `../_common/db_helpers.py`를 그대로 가져다 쓴다 -
`../JOIN-표준JOIN`, `../NULL`과 동일한 방식(환경변수 기반 연결 시도 → 실패
시 정적 검증 모드)이다. 모델 학습은 수행하지 않는다.

검증 결과는 세 가지로만 판정한다.

- **PASS** - `sql_example_result`의 실제값이 `sql_example_expectation`의
  기대값과 일치.
- **FAIL** - 실제값이 기대값과 다르거나, 정적 점검 모드에서 example_id
  자체를 `02_examples.sql`에서 찾지 못함.
- **NO_RESULT** - `sql_example_expectation`에는 있지만 `sql_example_result`에
  해당 example_id 행이 없는 경우(`02_examples.sql` 미실행), 또는 실제 DB
  연결 없이 정적 구조 점검만 수행해 실행 결과 자체를 비교하지 못한 경우.
  집계 시 PASS/FAIL 어느 쪽에도 포함되지 않고 `no_result_count`로 별도
  집계된다(`pass_count`/`fail_count`/`no_result_count`/`total_count`,
  `Oracle/03_verify.sql`·`SQLServer/03_verify.sql`의 A-2 쿼리 참고).

`03_verify.sql`은 PASS/FAIL/NO_RESULT 집계 외에 섹션 C에서 **메타모픽
검증**(예제 사이에 반드시 성립해야 하는 관계)을 추가로 확인한다.

| 관계 | 근거 example_id |
|---|---|
| LEFT JOIN+IS NULL = NOT EXISTS | JN05A = JN05B |
| 위 결과 ≠ NULL 포함 NOT IN | JN05A ≠ JN05C |
| ON 필터 행수 > WHERE 필터 행수 | JN03A > JN03B |
| COUNT(*) ≥ COUNT(NOT NULL 키) ≥ COUNT(nullable 열) | JN04A ≥ JN04B ≥ JN04C |
| Oracle USING = SQL Server 대응 ON | JN10(Oracle) = JN10(SQLServer) |
| Oracle `(+)` 함정 = ANSI LEFT JOIN+WHERE 함정 | JN14 = JN03B(같은 메커니즘) |
| NULL 키 등가조인 < CROSS JOIN | JN01A < JN13 |
| FULL OUTER JOIN 통합키 NULL 개수 = 기대값 | JN09B = 3 |

## 11. 실제 DB 실행 여부

**이 세션에는 Oracle과 SQL Server 실행 환경이 없다.** 이번 개편에서도 실제
Oracle/SQL Server에 접속해 실행한 적이 없다. 대신 이 폴더의 모든 example_id
(JN01A~JN14, 29개)와 동일한 데이터·동일한 쿼리 로직을 SQLite로 이 세션에서
**실제로 실행**해 위 표의 기댓값과 전부 일치함을 확인했다(FULL OUTER JOIN은
SQLite가 지원하지 않아 LEFT JOIN 두 번을 UNION ALL로 결합해 동치 쿼리로
검증했다). Oracle 고유 문법(`USING`, `(+)`, `NVL`, `SYSDATE`)과 SQL Server
고유 문법(`GETDATE()`, `ISNULL`)의 실제 실행, 그리고 `02_validate.py`를 실제
Oracle/SQL Server에 연결해 돌리는 것은 여전히 미검증이다 - SQLite 검증은
"데이터 구조상 이 숫자가 나오는가"를 확인한 것이지, Oracle/SQL Server
자체의 실행을 확인한 것이 아니라는 점을 분명히 한다.
`02_validate.py`를 실제 DB에 연결해 돌리려면 `../JOIN-표준JOIN/README.md`와
동일한 환경변수(`ORACLE_DSN`/`ORACLE_USER`/`ORACLE_PASSWORD` 또는
`SQLSERVER_CONNECTION_STRING`)를 설정하고 `python3 02_validate.py --dbms
oracle`(또는 `sqlserver`)를 실행한다. 연결에 실패하면 정적 검증 모드로
전환되며, 정적 모드의 결과는 항상 `NO_RESULT`로 표시되고 PASS로 표시되지
않는다.

## 12. 재현성

- 모든 예제 데이터는 고정 INSERT 문이다(임의 생성 없음).
- `01_prepare.sql`은 재실행 시 기존 객체를 모두 DROP 후 재생성한다.
- `02_examples.sql`은 `DELETE FROM sql_example_result WHERE example_id LIKE 'JN%'`로
  시작해, 여러 번 실행해도 결과가 중복 적재되지 않는다.
- `example_id`는 이 문서의 표와 동일하게 고정돼 있으며 실행마다 바뀌지 않는다.
