# 01. NULL 판정 — IS NULL, 빈 문자열, 공백 문자열

## 1. 학습 목표

- `IS NULL`/`IS NOT NULL`이 NULL을 판정하는 유일하게 올바른 방법임을 확인한다.
- `= NULL`, `<> NULL`이 절대 작동하지 않는 이유를 직접 실행으로 확인한다.
- Oracle은 빈 문자열 `''`을 NULL로 저장하고, SQL Server는 `''`과 NULL을
  별개 값으로 저장한다는 두 DBMS의 정반대 동작을 비교한다.
- 공백 문자열(`' '`)과 빈 문자열(`''`)이 서로 다른 값이라는 것, 그리고 SQL
  Server에서는 `=` 비교만으로는 이 둘조차 구분되지 않는다는 함정을 확인한다.

## 2. 핵심 원리

- `IS NULL`/`IS NOT NULL`은 비교 연산자가 아니라 **술어(predicate)**다 —
  그래서 NULL에도 TRUE/FALSE를 확정적으로 반환할 수 있는 유일한 방법이다.
- `컬럼 = NULL`, `컬럼 <> NULL`은 문법 오류는 아니지만 **항상 UNKNOWN**이라
  0행만 반환한다(`00` 폴더의 3값 논리 참고).
- **Oracle**: `VARCHAR2` 컬럼에 `''`을 넣으면 저장되는 순간 NULL로 바뀐다.
  Oracle 내부적으로 길이 0인 문자열을 NULL과 동일하게 취급하기 때문이다.
  이는 컬럼 자료형이 `VARCHAR2`든 `CHAR`든 동일하며, **저장 이후에는 SQL로
  되돌릴 방법이 없다**(원본이 정말 `''`였는지 NULL이었는지 구분 불가).
- **SQL Server**: `''`과 NULL은 완전히 다른 값이다. `''`은 길이 0인 문자열로
  그대로 저장되고, `IS NULL`은 FALSE를 반환한다.
- **SQL Server의 숨은 함정 — ANSI 공백 패딩 비교**: SQL Server(와 ANSI SQL
  표준)는 `=` 비교에서 길이가 다른 두 문자열을 비교할 때 짧은 쪽 뒤에 공백을
  채워(pad) 길이를 맞춘 뒤 비교한다. 그 결과 `''`(길이 0)과 `' '`(길이 1)을
  `=`로 비교하면 **서로 같다고 판정된다** — SQL Server가 `''`과 NULL은
  구분해도, `=` 비교만으로는 `''`과 `' '`을 구분하지 못한다는 뜻이다. 정확히
  구분하려면 `DATALENGTH()`(실제 저장 바이트 길이)를 같이 써야 한다.
  Oracle은 `VARCHAR2`끼리 비교할 때 이 패딩 규칙을 적용하지 않는다(양쪽 다
  `VARCHAR2`면 nonpadded 비교) — 게다가 Oracle에서는 `''`이 이미 NULL이 되어
  버려 이 비교 자체가 성립하지 않는다.

## 3. 공통 입력 데이터

`00-NULL의미와3값논리`와 완전히 같은 `null_lab_customer`/`null_lab_dept`/
`null_lab_excluded_codes`를 재사용한다. 이 폴더에서 특히 중요한 행:

| customer_id | nickname 설계 의도 | Oracle 저장 결과 | SQL Server 저장 결과 |
|---|---|---|---|
| 2 | 실제 NULL | NULL | NULL |
| 3 | 빈 문자열 `''` | **NULL로 바뀜** | `''` 그대로 |
| 4 | 공백 한 칸 `' '` | `' '` 그대로 | `' '` 그대로 |
| 8 | 실제 NULL | NULL | NULL |

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — STEP 1(IS NULL/IS NOT NULL) → STEP 2(=NULL이
0행만 반환) → STEP 3(2,3,8행이 모두 IS NULL=TRUE로 나와 구분 불가) →
STEP 4(`nickname=''`은 0행, `nickname=' '`은 1행).

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — STEP 1~2는 Oracle과 결과가 같다.
STEP 3에서 3행만 `''`으로 남아 2,8행(NULL)과 명확히 구분된다. STEP 4가
Oracle과 가장 크게 갈리는 지점 — ANSI 공백 패딩 때문에 `nickname=''`과
`nickname=' '` 둘 다 **2행(customer_id 3과 4 모두)** 을 반환한다. `DATALENGTH`로
바이트 길이를 확인해야 3행(진짜 빈 문자열)과 4행(공백)을 가른다.

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고.

## 7. 결과 차이의 이유

Oracle이 `''`을 NULL로 저장하는 것은 Oracle의 초기 설계 결정(NULL과 빈
문자열을 같은 개념으로 취급)에서 비롯된 것으로, ANSI SQL 표준이 요구하는
동작이 아니다 — SQL Server는 표준에 더 가깝게 `''`과 NULL을 구분한다.
반면 ANSI 공백 패딩 비교는 표준에 명시된 동작이라 SQL Server가 이를 따르고
있는 것이고, Oracle은 `VARCHAR2`끼리 비교할 때는 이 규칙을 적용하지 않는다
(고정 길이 `CHAR`끼리 비교할 때는 Oracle도 패딩을 적용한다 — 이 저장소는
가변 길이 `VARCHAR2`/`VARCHAR`만 쓰므로 이 차이가 실제로 드러난다).

## 8. SQLD 함정

- **"Oracle은 빈 문자열이 없다"고 암기하고 넘어가는 함정** — 정확히는 "빈
  문자열을 저장하려는 시도가 NULL로 바뀐다"이다. 공백 한 칸은 빈 문자열이
  아니므로 그대로 저장된다는 것까지 같이 기억해야 한다.
- **"SQL Server는 ''과 NULL을 구분하니 문자열 비교가 항상 안전하다"는 착각** —
  구분되는 것은 `IS NULL` 판정뿐이고, `=` 비교는 공백 패딩 때문에 `''`과
  `' '`을 구분하지 못한다.
- **`컬럼 = NULL`을 조건문에 그대로 쓰고 "결과가 없네" 하고 데이터가 없다고
  오판하는 함정** — 실제로는 데이터가 있어도 이 조건 자체가 절대 TRUE가
  될 수 없어서 0행이 나온 것이다.

## 9. 빅분기 결측치 처리와의 연결

결측치 탐지의 첫 단계는 항상 "이 값이 정말 결측인가, 아니면 빈 문자열/공백
같은 다른 종류의 '비어 있음'인가"를 구분하는 것이다. `pandas`의
`isna()`/`isnull()`은 Python `None`/`NaN`만 결측으로 잡고 빈 문자열 `''`은
결측으로 보지 않는다 — 이는 SQL Server의 동작과 원리가 같다(NULL과 빈
문자열을 구분). 반대로 Oracle에서 CSV를 그대로 적재하면 원본의 빈 문자열이
전부 NULL로 바뀌어 버려, Python에서 계산한 결측 비율과 Oracle DB에서 집계한
결측 비율이 달라질 수 있다는 것이 실무에서 실제로 발생하는 함정이다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) 참고.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증.** 이 세션에는 두 DBMS 실행 환경이 없다
(저장소 루트 `README.md` §5 참고). Oracle의 `''`→NULL 변환과 SQL Server의
ANSI 공백 패딩 비교는 각 DBMS 공식 문서에 명시된 표준 동작을 근거로 작성했으며,
`oracle.sql`/`sqlserver.sql`은 각자의 환경에 그대로 복사해 실행할 수 있는
완전한 스크립트다. 실제 결과는 각 환경에서 재확인이 필요하다.
