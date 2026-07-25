# 00. NULL의 의미와 3값 논리

## 1. 학습 목표

- NULL이 "0"도 "빈 문자열"도 아닌 **"알 수 없음(unknown)"** 이라는 것을 이해한다.
- SQL의 비교·논리 연산이 TRUE/FALSE 2값이 아니라 **TRUE/FALSE/UNKNOWN 3값 논리**로
  동작한다는 것을 진리표로 직접 확인한다.
- `WHERE`가 UNKNOWN인 행을 어떻게 처리하는지 감을 잡는다(상세 실습은
  [`06-NULL과WHERE-CASE`](../06-NULL과WHERE-CASE/README.md)).
- 이 폴더에서 정의하는 공통 데이터셋(`null_lab_customer`/`null_lab_dept`/
  `null_lab_excluded_codes`)이 이 학습 모듈 전체(`01`~`11`)에서 그대로
  재사용된다는 것을 확인한다.

## 2. 핵심 원리

- NULL은 값이 아니라 **상태**다 — "값이 없음" 또는 "값을 모름"을 뜻하며,
  0이나 빈 문자열과 다르다.
- 비교 연산자(`=`, `<>`, `<`, `>` 등)에 NULL이 하나라도 관여하면 결과는
  TRUE도 FALSE도 아닌 **UNKNOWN**이다. `score = NULL`, `score <> NULL`은
  문법 오류가 아니라 **항상 UNKNOWN**이라 절대 TRUE가 될 수 없다 — 그래서
  이 조건으로는 어떤 행도 걸러낼 수 없다.
- 3값 논리 진리표(TRUE=T, FALSE=F, UNKNOWN=U):

  | AND | T | F | U |
  |---|---|---|---|
  | **T** | T | F | U |
  | **F** | F | F | F |
  | **U** | U | F | U |

  | OR | T | F | U |
  |---|---|---|---|
  | **T** | T | T | T |
  | **F** | T | F | U |
  | **U** | T | U | U |

  | NOT | 결과 |
  |---|---|
  | NOT T | F |
  | NOT F | T |
  | NOT U | **U** |

  규칙을 외우는 대신 이렇게 이해하면 된다 — **AND는 FALSE가 하나라도 있으면
  무조건 FALSE**, **OR는 TRUE가 하나라도 있으면 무조건 TRUE**(둘 다 단축
  평가). 나머지 경우에만 UNKNOWN이 살아남는다. NOT은 U를 절대 T나 F로
  바꾸지 못한다.
- `WHERE`(그리고 `CASE WHEN`, `CHECK` 제약조건)는 **딱 TRUE인 행/조건만**
  통과시킨다. FALSE와 UNKNOWN을 구분하지 않고 둘 다 버린다는 점이 SQLD에서
  가장 자주 나오는 함정이다.

## 3. 공통 입력 데이터

이 폴더가 `NULL-집중학습/` 전체의 공통 데이터셋을 **처음** 정의한다.
`01`~`11` 폴더는 아래와 완전히 같은 DDL/INSERT를 각자의 `oracle.sql`/
`sqlserver.sql` 앞부분에 그대로 복사해서 자기완결적으로 실행되게 한다.

- `null_lab_customer`(12행) — 고객 정보. 실제 NULL, 빈 문자열 `''`, 공백
  한 칸 `' '`, 숫자 0, 문자열 `'0'`, 분모 0/NULL, 집계 대상 숫자 NULL,
  JOIN 키 NULL/불일치를 모두 포함한다(자세한 배치는
  [`../README.md`](../README.md)의 "공통 테스트 데이터" 표 참고).
- `null_lab_dept`(3행) — `dept_code` 조인 대상. 고객 4명(4,8,10행)이
  대응하는 부서가 없다.
- `null_lab_excluded_codes`(3행, `'D02'`, `'D03'`, `NULL`) — `NOT IN`
  서브쿼리 함정 전용(`08` 폴더).

**Olist 원자료(`olist_customers_dataset.csv`)에는 실제 결측이 없다** —
이 세 테이블은 Olist와 무관한 이 학습 모듈 전용의 작은 합성 데이터다.

전체 DDL/INSERT는 [`oracle.sql`](./oracle.sql), [`sqlserver.sql`](./sqlserver.sql) 참고.

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — 공통 데이터셋 생성 후 4단계로 3값 논리를 확인한다.

1. `score = NULL` / `score <> NULL`이 항상 NULL(UNKNOWN)로 표시됨을 확인
2. `WITH truth_values`로 TRUE/FALSE/UNKNOWN 모든 조합의 AND/OR 진리표를 직접 계산
3. `NOT`이 UNKNOWN을 뒤집지 못함을 확인
4. `WHERE score > 80` / `WHERE NOT (score > 80)` / `WHERE score IS NULL` 세
   쿼리가 12행을 서로 겹치지 않게 나눔을 확인

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — 로직은 Oracle과 동일하되 두 가지 문법 차이가 있다.

- `score = NULL`을 `SELECT` 목록에서 곧바로 쓸 수 없어(SQL Server는 비교
  predicate가 아닌 위치에서 `= NULL`을 boolean으로 못 씀) `CASE WHEN`으로
  감쌌다.
- 정렬에서 Oracle의 `NULLS LAST`가 없어 `CASE WHEN ... IS NULL THEN 1 ELSE 0 END`
  트릭으로 대신했다(`09` 폴더에서 상세히 다룸).

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고. 3값 논리 자체는
표준 SQL 공통 규칙이라 **Oracle과 SQL Server의 계산 결과는 완전히 같다** —
이 폴더에서 두 DBMS가 갈리는 지점은 문법(`= NULL`을 SELECT에 직접 쓸 수
있는지, 정렬에 `NULLS LAST`가 있는지)뿐이다.

## 7. 결과 차이의 이유

3값 논리는 SQL 표준(ANSI SQL)에 정의된 공통 규칙이므로 Oracle/SQL Server가
계산 결과 자체를 다르게 낼 이유가 없다. 이 폴더에서 관찰되는 차이는 전부
**문법 차이**다 — SQL Server가 `= NULL`을 SELECT 최상위 표현식으로 거부하는
것은 Oracle보다 더 엄격하게 "비교 연산자는 predicate 자리에서만 쓴다"는
규칙을 지키기 때문이다(실제로는 `SET ANSI_NULLS OFF`로 완화할 수 있지만
레거시 설정이라 이 저장소에서는 쓰지 않는다).

## 8. SQLD 함정

- **"NULL이 아닌 값은 다 TRUE거나 FALSE다"라고 착각** — WHERE에서 걸러진
  행이 꼭 조건에 "안 맞아서(FALSE)"가 아니라 "몰라서(UNKNOWN)" 빠졌을 수
  있다.
- **`WHERE condition`과 `WHERE NOT condition`을 합치면 전체 행이 나온다고
  착각** — UNKNOWN 몫이 양쪽 모두에서 빠지므로, 전체를 다 보려면
  `OR column IS NULL`을 반드시 추가해야 한다.
- **`AND`/`OR`에 NULL이 섞이면 결과가 항상 NULL(UNKNOWN)이라고 착각** —
  `FALSE AND UNKNOWN`은 `FALSE`이고 `TRUE OR UNKNOWN`은 `TRUE`다(단축
  평가). 무조건 NULL이 되는 게 아니라 **다른 쪽 값에 따라 달라진다.**
- **`NOT (조건)`으로 UNKNOWN을 뒤집어 잡으려는 시도** — `NOT UNKNOWN`도
  여전히 `UNKNOWN`이라 어떤 조건을 부정해도 NULL 행은 절대 잡히지 않는다.

## 9. 빅분기 결측치 처리와의 연결

빅데이터분석기사 실기에서 결측치를 다룰 때 가장 먼저 하는 판단이 "이 값이
왜 없는가(MCAR/MAR/MNAR)"다 — SQL의 3값 논리도 같은 태도의 연장선이다.
"NULL = 0으로 간주해도 되는가"를 섣불리 결정하지 않고, `IS NULL`로 결측을
먼저 식별한 뒤(`01` 폴더) 대치 전략(`12`~`13` 폴더)을 고르는 순서 자체가
SQL의 3값 논리 원칙("모르는 것은 모르는 채로 다루고, 함부로 TRUE/FALSE로
단정하지 않는다")과 같은 맥락이다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) 참고.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증** — 이 세션에는 두 DBMS를 실행할 환경이
없다(`../README.md`, 저장소 루트 `README.md` §5 참고). `oracle.sql`/
`sqlserver.sql`은 문법·3값 논리 규칙 기준으로 작성한 완전한 스크립트이며,
사용자가 각자의 Oracle/SQL Server 환경에 그대로 복사해 실행할 수 있다.
실행했다고 보고하지 않는다 — 실제 결과는 각 환경에서 재확인이 필요하다.
