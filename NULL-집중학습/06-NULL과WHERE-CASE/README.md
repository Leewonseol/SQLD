# 06. NULL과 WHERE / CASE — 실전 쿼리에서 UNKNOWN 처리

## 1. 학습 목표

- `00-NULL의미와3값논리`에서 배운 3값 논리 "이론"을 `WHERE`와 `CASE WHEN`
  **실전 쿼리**에 직접 적용해서, 여러 조건을 `AND`로 묶었을 때 NULL이 낀
  조건이 실제로 어떻게 행을 탈락시키는지 확인한다.
- **Simple CASE**(`CASE expr WHEN val THEN ... END`)가 NULL을 절대 잡지
  못한다는 것과, **Searched CASE**(`CASE WHEN 조건 THEN ... END`)로는
  `IS NULL`을 써서 정상적으로 잡을 수 있다는 차이를 직접 확인한다.
- `CASE` 표현식 자체가(ELSE 없이) NULL을 반환하면, 그 NULL이 다시 `WHERE`
  비교에 들어갔을 때 그 행도 조용히 배제된다는 것을 확인한다.

## 2. 핵심 원리

- `WHERE a AND b`에서 `a`, `b` 중 하나라도 NULL이 관여해 UNKNOWN이 되면,
  전체 결과는 **다른 쪽 값에 따라 달라진다**(00 폴더 진리표) — 다른 쪽이
  확정적으로 FALSE면 전체가 FALSE로 확정되고(단축 평가), 다른 쪽이 TRUE나
  UNKNOWN이면 전체가 UNKNOWN이 되어 역시 행이 빠진다. 즉 **AND로 묶인 행이
  결과에서 빠지는 이유는 "확정적으로 FALSE"와 "몰라서 UNKNOWN" 두 가지가
  섞여 있다** — WHERE 결과만 봐서는 이 둘이 구분되지 않는다.
- **Simple CASE**(`CASE dept_code WHEN NULL THEN ... END`)는 내부적으로
  `dept_code = NULL`과 동치인 비교를 수행한다. `= NULL`은 항상 UNKNOWN이므로
  `dept_code`가 실제로 NULL인 행에서도 이 `WHEN`은 **절대 TRUE가 되지
  않는다** — `ELSE`(또는 `ELSE`가 없으면 NULL)로 떨어진다.
- **Searched CASE**(`CASE WHEN dept_code IS NULL THEN ... END`)는 `IS NULL`
  술어를 직접 조건으로 쓸 수 있어 NULL을 정확히 잡는다.
- `CASE`에 `ELSE`가 없고 어떤 `WHEN`에도 걸리지 않으면 결과는 **NULL**이다.
  이 NULL이 `WHERE (CASE ...) = 'Y'`처럼 다시 비교에 쓰이면 `NULL = 'Y'`가
  되어 UNKNOWN → 그 행도 `WHERE`에서 배제된다. `WHERE`가 UNKNOWN을 FALSE와
  구분 없이 버린다는 00 폴더의 규칙이 `CASE`를 한 겹 거쳐도 그대로 적용된다.

## 3. 공통 입력 데이터

`00-NULL의미와3값논리`와 완전히 같은 `null_lab_customer`/`null_lab_dept`/
`null_lab_excluded_codes`를 재사용한다. 이 폴더에서 핵심적으로 쓰는 컬럼은
`score`(customer_id 3,9=NULL)와 `dept_code`(customer_id 4,10=NULL, 8=`'D99'`
불일치, 나머지는 `D01`/`D02`/`D03` 정상 매칭)이다. 자세한 배치는
[`../README.md`](../README.md)의 "공통 테스트 데이터" 표 참고.

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — 공통 데이터셋 생성 후 4단계로 진행한다.

1. `WHERE score > 80 AND dept_code = 'D01'`의 결과와, 12행 전체를
   `score_gt80`/`dept_eq_d01`/`and_result`(T/F/U)로 분류한 표로 "확정적
   FALSE로 빠진 행"과 "진짜 UNKNOWN이라 빠진 행"을 구분
2. `CASE dept_code WHEN NULL THEN ... END`이 NULL인 행에서도 절대
   걸리지 않음을 확인(Simple CASE 함정)
3. `CASE WHEN dept_code IS NULL THEN ... END`으로 올바르게 판정
4. `WHERE score > 80`과 `WHERE (CASE WHEN score > 80 THEN 'Y' END) = 'Y'`가
   완전히 같은 결과를 냄을 확인 — CASE가 반환한 NULL도 WHERE에서 조용히 배제됨

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — 로직과 결과 모두 Oracle과 동일하다.
3값 논리와 `CASE`의 NULL 처리는 ANSI SQL 표준 공통 규칙이라 두 DBMS 사이에
문법 차이조차 거의 없다(00 폴더와 마찬가지로 이 폴더는 순수하게 "결과가
같다"는 것을 보여주는 폴더에 가깝다).

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고.

## 7. 결과 차이의 이유

3값 논리, `CASE`의 내부 비교 규칙, `WHERE`가 UNKNOWN을 버리는 규칙은 모두
ANSI SQL 표준에 정의된 공통 동작이라 Oracle과 SQL Server가 계산 결과를
다르게 낼 이유가 없다. 이 폴더에서 두 스크립트가 사실상 동일한 것 자체가
"NULL의 논리적 처리는 DBMS 벤더 차이가 아니라 SQL 표준의 문제"라는 것을
보여준다 — 05/07 폴더처럼 함수/연산자 이름이 다르거나 저장 규칙이 다른
경우와 대조된다.

## 8. SQLD 함정

- **"AND로 묶인 조건에서 NULL이 있으면 무조건 그 행이 UNKNOWN이라 빠진
  것"이라고 착각** — STEP 1처럼 다른 조건이 확정적으로 FALSE라면 AND
  전체도 FALSE로 확정되어 빠진 것이지 UNKNOWN 때문이 아니다. 결과 행 수만
  봐서는 이 둘을 구분할 수 없다.
- **`CASE 컬럼 WHEN NULL THEN ... END`으로 NULL을 잡으려는 시도** — Simple
  CASE의 내부 비교는 `컬럼 = NULL`과 동치라서 절대 TRUE가 될 수 없다.
  `dept_code`가 정말 NULL인 행조차 이 분기를 타지 못하고 `ELSE`로 떨어진다.
  NULL을 분기하려면 반드시 Searched CASE(`CASE WHEN 컬럼 IS NULL THEN ...`)
  를 써야 한다.
- **`CASE`에 `ELSE`를 빠뜨리고 그 결과를 다시 조건으로 쓰는 함정** — `ELSE`
  없는 `CASE`가 반환하는 NULL이 이후 비교·WHERE에 들어가면 또 다른
  UNKNOWN을 만들어 예상과 다르게 행이 빠질 수 있다.
- **CHECK 제약조건은 다르게 동작한다는 것을 예고** — `WHERE`/`CASE`는
  UNKNOWN을 FALSE와 함께 버리지만, `CHECK` 제약조건은 UNKNOWN을 **통과**시켜
  값이 저장되는 것을 허용한다(TRUE와 UNKNOWN만 거부하지 않고 통과). 이
  비대칭은 [`11-NULL과제약조건`](../11-NULL과제약조건/README.md)에서
  상세히 다룬다.

## 9. 빅분기 결측치 처리와의 연결

`pandas`의 `df[(df['score'] > 80) & (df['dept_code'] == 'D01')]`처럼 여러
불리언 마스크를 `&`로 묶을 때도 NaN이 섞인 비교는 `False`로 평가되어(
pandas는 NaN 비교를 SQL의 UNKNOWN이 아니라 곧바로 False로 접는다) SQL과
결과는 비슷해 보이지만 원리가 다르다 — SQL은 3값 논리를 유지한 채
`WHERE`에서 최종적으로 TRUE만 통과시키는 반면, pandas는 비교 시점에 이미
NaN을 False로 확정해버린다. 이 차이 때문에 SQL에서 `OR score IS NULL`을
추가로 넣어야 하는 경우가 pandas 코드로 그대로 옮기면 놓치기 쉬운 함정이
된다 — SQL의 3값 논리를 이해하고 있어야 pandas로 옮길 때 결측 처리 로직을
빠뜨리지 않는다.

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
