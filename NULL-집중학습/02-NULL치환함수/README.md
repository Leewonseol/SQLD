# 02. NULL 치환 함수 — NVL / NVL2 / ISNULL / COALESCE / NULLIF / CASE

## 1. 학습 목표

- `NVL`(Oracle 전용), `NVL2`(Oracle 전용), `ISNULL`(SQL Server 전용),
  `COALESCE`(표준 SQL, 양쪽 다 지원), `NULLIF`, `CASE WHEN` 여섯 가지 NULL
  치환 방법을 직접 실행해 비교한다.
- 단순히 "어떤 함수가 어떤 DBMS 전용인지" 대응표를 외우는 데서 그치지 않고,
  **자료형·길이가 다른 값을 섞었을 때** 각 함수가 정말로 같은 결과를 내는지
  직접 확인한다.
- 짧은 `VARCHAR2(5)`/`VARCHAR(5)` 컬럼에 긴 대체 문자열을 넣으면 SELECT는
  성공해도 저장(INSERT)은 실패한다는 것, 그리고 `ISNULL`은 에러 없이
  조용히 잘라버린다는 것을 실제 에러 메시지로 확인한다.
- 정수+소수, 숫자+문자열, 날짜+문자열처럼 자료형이 다른 인수를 섞었을 때의
  암시적 변환·타입 승격 규칙을 확인한다.

## 2. 핵심 원리

- `NVL(expr, replacement)`(Oracle 전용): expr이 NULL이면 replacement, 아니면
  expr을 반환한다. 인수가 정확히 2개인 `COALESCE`의 특수형이다.
- `NVL2(expr, not_null_result, null_result)`(Oracle 전용): expr이 NULL이
  **아니면** `not_null_result`, NULL이면 `null_result`를 반환한다 — "NULL
  여부에 따라 서로 다른 두 표현식"을 지정할 수 있다는 점이 `NVL`과 다르다.
- `ISNULL(expr, replacement)`(SQL Server 전용): 겉보기엔 `NVL`과 똑같지만
  **반환형이 첫 번째 인수(expr) 기준으로 고정**된다(Microsoft 공식 문서
  근거) — `replacement`가 더 길거나 다른 타입이어도 expr의 타입/길이에
  맞춰진다. 그래서 `ISNULL(짧은컬럼, 긴리터럴)`은 에러 없이 조용히 잘릴 수
  있다. **`NVL`과 동의어가 아니다** — 이름이 비슷해도 반환형 결정 규칙이
  다르다.
- `COALESCE(expr1, expr2, ...)`(표준 SQL, Oracle·SQL Server 모두 지원):
  인수를 순서대로 봐서 처음 NULL이 아닌 값을 반환한다. 인수 개수 제한이
  없고, **결과 타입은 인수들 중 데이터 타입 우선순위(data type precedence)가
  가장 높은 타입으로 승격**된다 — 그래서 짧은 컬럼과 긴 리터럴을 섞어도
  SELECT 단계에서는 잘리지 않는다.
- `NULLIF(expr1, expr2)`: `expr1 = expr2`이면 NULL을, 아니면 `expr1`을
  반환한다. "특정 값(흔히 0)을 결측으로 취급하고 싶을 때" 또는(`03` 폴더)
  "0으로 나누기를 막을 때" 쓰인다.
- `CASE WHEN expr IS NULL THEN ... ELSE ... END`은 위 함수들을 모두 직접
  구현할 수 있는 가장 기본적인 방법이다 — SQLD는 종종 "NVL/ISNULL을 CASE
  WHEN으로 바꿔 써라"는 형태로 출제한다.
- **데이터 타입 우선순위(data type precedence, 표준 SQL 개념)**: 여러
  타입이 섞인 표현식(COALESCE, CASE, UNION 등)에서 결과 타입을 정할 때 쓰는
  순서. 이 저장소에서 다루는 범위에서는 대략 `날짜/시간 > 부동소수점 >
  DECIMAL/NUMBER(소수 포함) > 정수 > 문자열` 순으로 숫자·날짜가 문자열보다
  우선순위가 높다 — 그래서 NUMBER/INT와 VARCHAR2/VARCHAR를 섞으면
  문자열 쪽이 숫자로 변환되려고 시도한다(변환 불가능하면 에러).

  | 함수 | 반환형 결정 기준 |
  |---|---|
  | `NVL(a, b)` | a, b 중 우선순위 높은 타입(Oracle) |
  | `NVL2(a, b, c)` | b, c 중 우선순위 높은 타입 |
  | `ISNULL(a, b)` | **a(첫 번째 인수) 타입/길이로 고정**(SQL Server) |
  | `COALESCE(a, b, ...)` | 전체 인수 중 우선순위 가장 높은 타입으로 승격 |

## 3. 공통 입력 데이터

`00-NULL의미와3값논리`와 완전히 같은 `null_lab_customer`/`null_lab_dept`/
`null_lab_excluded_codes`를 재사용한다(전체 DDL/INSERT는
[`oracle.sql`](./oracle.sql), [`sqlserver.sql`](./sqlserver.sql) 참고). 이
폴더에서 특히 중요한 컬럼:

| 컬럼 | 자료형 | 이 폴더에서의 역할 |
|---|---|---|
| `purchase_amt` | NUMBER(10,2) / DECIMAL(10,2) | customer_id 5, 11이 NULL — 기본 치환(STEP 1) |
| `nickname` | VARCHAR2(20) / VARCHAR(20) | Oracle·SQL Server 간 NULL 취급 차이가 치환 결과에도 그대로 이어짐(STEP 1) |
| `score` | NUMBER / INT | customer_id 3, 9가 NULL — NVL2/CASE(STEP 2), 정수+소수 혼합(STEP 6) |
| `age` | NUMBER / INT | customer_id 5만 NULL, 4는 0 — NULLIF(STEP 4), 숫자+문자열 혼합(STEP 7) |
| `membership_code` | VARCHAR2(5) / VARCHAR(5) | 짧은 컬럼(STEP 5, 9), 숫자로 변환 가능한 `'0'`(STEP 7) |
| `dept_code` | VARCHAR2(5) / VARCHAR(5) | 숫자 변환 불가능한 `'D01'`로 실제 에러 시연(STEP 7) |
| `join_date` | DATE | customer_id 3, 11이 NULL — 날짜+문자열 혼합(STEP 8) |

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — 공통 데이터셋 생성 후 9단계.

1. `NVL`/`COALESCE` 기본 치환 비교(purchase_amt, nickname)
2. `NVL2`로 NULL 여부에 따른 서로 다른 두 값 반환
3. `CASE WHEN`으로 `NVL`을 직접 구현해 결과 동일함을 확인
4. `NULLIF(age, 0)`, `NULLIF(score, 0)` — 0을 NULL로
5. 짧은 `VARCHAR2(5)` + 긴 대체 문자열 — SELECT 성공, INSERT는 에러
   (`ORA-12899`)
6. `COALESCE(score, 0.5)` — Oracle NUMBER는 원래도 소수 나눗셈이라 "승격"이
   눈에 보이지 않음을 확인
7. `COALESCE(age, membership_code)`(우연히 성공) vs `COALESCE(age,
   dept_code)`(`ORA-01722` 에러)
8. `COALESCE(join_date, '정보없음')`(에러) → `TO_CHAR` 선변환으로 수정
9. Oracle에는 `ISNULL`이 없다는 점을 참고로 재확인(`NVL`로 대체)

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — 로직은 Oracle과 동일하되 STEP 1~9의
함수 대응이 다음처럼 바뀐다.

- Oracle `NVL` → SQL Server `ISNULL`(단, 반환형 결정 규칙이 다르므로 완전한
  동의어가 아니다).
- Oracle `NVL2` → SQL Server에는 없어 `CASE WHEN`으로 직접 구현(STEP 2).
- STEP 6은 `score`가 `INT`로 선언되어 있어 Oracle과 달리 정수→decimal 승격이
  나눗셈 결과 차이로 뚜렷이 드러난다.
- STEP 9는 SQL Server 전용 — `ISNULL`이 첫 번째 인수 타입/길이로 고정되어
  긴 대체 문자열이 조용히 잘리는 것을 `COALESCE`와 나란히 비교한다.

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고.

## 7. 결과 차이의 이유

- **NVL vs ISNULL의 반환형 결정 규칙 차이**는 Oracle과 Microsoft 각자의
  함수 설계 철학 차이다 — Oracle의 `NVL`은 `COALESCE`와 같은 승격 규칙을
  따르지만, SQL Server의 `ISNULL`은 (Sybase에서 물려받은 하위호환 함수라)
  T-SQL 고유의 "첫 인수 타입 고정" 규칙을 따른다. 표준 SQL 함수인
  `COALESCE`는 두 DBMS 모두 동일한 승격 규칙을 따르므로 여기서는 차이가
  없다.
- **정수/소수 승격이 SQL Server에서만 뚜렷이 보이는 이유**는 Oracle의
  `NUMBER`가 정밀도·스케일을 지정하지 않으면 정수와 소수를 구분하지 않는
  가변 숫자 타입이기 때문이다. SQL Server의 `INT`는 처음부터 정수 전용
  고정 타입이라, 소수 리터럴과 섞이는 순간 명시적으로 `decimal`로 승격되는
  과정이 나눗셈 결과에 그대로 드러난다.
- **숫자+문자열 암시적 변환 에러**는 두 DBMS 모두 데이터 타입 우선순위상
  숫자가 문자열보다 높아 문자열을 숫자로 변환하려 시도한다는 점에서
  원리가 같다 — 다만 에러 코드/메시지 형식만 벤더별로 다르다
  (`ORA-01722` vs `Conversion failed ...`).
- **짧은 컬럼 + 긴 문자열**에서 SELECT는 성공하고 INSERT만 실패하는 이유는
  SELECT 결과 컬럼은 물리적 저장 제약이 없는 "가상의" 결과 집합이지만,
  INSERT 대상 컬럼은 `CREATE TABLE`에서 정한 고정 폭 저장 공간이기
  때문이다 — 이 폭 제약을 검사하는 시점이 SELECT가 아니라 INSERT(또는
  UPDATE)라는 것이 핵심.

## 8. SQLD 함정

- **"NVL, ISNULL, COALESCE는 전부 완전히 같은 함수다"라고 암기** —
  인수 개수 제한(NVL/ISNULL은 2개, COALESCE는 여러 개), 반환형 결정 규칙
  (ISNULL은 첫 인수 고정, 나머지는 승격)이 다르다는 것을 놓치면 SQLD
  응용 문제에서 틀린다.
- **"COALESCE(짧은컬럼, 긴문자열)을 SELECT했을 때 에러가 안 났으니 INSERT도
  안전하다"는 착각** — SELECT 성공은 저장 가능성을 보장하지 않는다.
- **"ISNULL이 조용히 자르는 걸 눈치채지 못하는 함정"** — 에러가 안 나기
  때문에 오히려 더 위험하다. 긴 치환 문자열을 짧은 컬럼 타입 위에서 쓸 때는
  `ISNULL` 대신 `COALESCE` + 명시적 `CAST`/`CONVERT`로 폭을 미리 정해주는
  것이 안전하다.
- **`COALESCE(숫자컬럼, 문자컬럼)`이 항상 에러가 난다고 오해하거나, 항상
  성공한다고 오해** — 실제로는 "NULL을 대신하게 될 그 값이 숫자로 변환
  가능한가"에 달려 있다(이 폴더 STEP 7이 정확히 이 경계 사례를 보여준다).
- **`COALESCE(날짜컬럼, '문자열')`을 "그냥 텍스트로 보여주려는 것"으로
  오해** — 날짜 컬럼과 섞이면 문자열이 날짜로 변환되려 시도하므로, 반대로
  날짜를 먼저 문자열로 바꿔야 한다는 순서를 거꾸로 아는 함정이 자주 나온다.

## 9. 빅분기 결측치 처리와의 연결

- `NVL`/`ISNULL`/`COALESCE`로 단일 값(0, 평균, '정보없음' 등)을 채우는 것은
  pandas `df['col'].fillna(value)`, 또는 scikit-learn
  `SimpleImputer(strategy='constant', fill_value=...)`와 정확히 대응된다.
- `CASE WHEN ... END`으로 NULL 여부에 따라 완전히 다른 두 값을 넣는 것은
  `np.where(df['col'].isna(), a, b)` 패턴, 또는 `SimpleImputer`에 그룹별
  전략을 다르게 적용하는 것과 대응된다.
- **자료형·길이 문제는 빅분기 실기에서도 그대로 나타난다** — pandas에서
  `df['membership_code'].fillna('정보없음(장기미접속)')`을 실행하면 SQL의
  `COALESCE`처럼 자료형이 자동으로 `object`(가변 길이 문자열)로 남아 에러가
  나지 않지만, 이 결과를 고정 폭 문자열 컬럼을 쓰는 다른 시스템(DB, 고정폭
  파일 포맷 등)에 저장할 때는 SQL의 `VARCHAR2(5)` INSERT 에러와 똑같은
  문제가 재현된다 — "메모리에서는 유연해도 저장 시점에는 제약이 있다"는
  교훈이 pandas와 SQL 모두에 공통으로 적용된다.
- `fillna(0)`처럼 정수 컬럼에 0을 채우는 것과, `fillna(0.5)`처럼 소수를
  채우는 것의 차이(pandas는 자동으로 컬럼 dtype을 `float64`로 승격시킨다)도
  이 폴더 STEP 6의 SQL 타입 승격과 같은 현상이다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) 참고.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증** — 이 세션에는 두 DBMS를 실행할 환경이
없다(`../README.md`, 저장소 루트 `README.md` §5 참고). `oracle.sql`/
`sqlserver.sql`은 각 벤더 공식 문서에 기술된 `NVL`/`NVL2`/`ISNULL`/
`COALESCE`/`NULLIF`의 동작 규칙, 데이터 타입 우선순위 규칙, 오류 코드를
근거로 작성한 완전한 스크립트이며, 사용자가 각자의 Oracle/SQL Server
환경에 그대로 복사해 실행할 수 있다. 실행했다고 보고하지 않는다 — 특히
STEP 5, 7, 8의 에러 메시지 정확한 문구와 STEP 5의 정확한 바이트 수는 실제
환경(문자셋 설정 포함)에서 재확인이 필요하다.
