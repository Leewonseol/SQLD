# 03. NULL과 산술 연산 — 전파, 문자열 결합, 0으로 나누기 방지

## 1. 학습 목표

- NULL이 포함된 산술연산(`+`, `-`, `*`, `/`)의 결과가 항상 NULL이 된다는
  "NULL 전파(propagation)"를 직접 확인한다.
- 문자열 결합(Oracle `||`, SQL Server `+`)도 산술연산과 마찬가지로 NULL이
  섞이면 전체 결과가 NULL이 된다는 것과, 이를 `COALESCE`/`NVL`/`ISNULL`로
  방어하는 패턴을 익힌다.
- `NULLIF`로 0으로 나누기 에러를 방지하는 SQLD 단골 패턴을 익히고, "분모가
  0인 것"과 "분모가 NULL인 것"이 서로 다른 현상(에러 vs NULL)이라는 것을
  명확히 구분한다.

## 2. 핵심 원리

- **NULL 산술 전파**: `NULL + n`, `NULL - n`, `NULL * n`, `NULL / n`은 n이
  무엇이든(0이든 아니든) 항상 NULL이다. NULL은 "알 수 없는 값"이므로 "알 수
  없는 값 + 알고 있는 값"도 여전히 "알 수 없다"는 것이 자연스러운 결론이다
  — 0을 더하거나 곱해도 결과가 0이나 원래 값이 되지 않고 NULL 그대로다.
- **문자열 결합도 같은 원리**: Oracle의 `||`와 SQL Server의 `+`(문자열
  결합 연산자로 쓰일 때) 모두, 피연산자 중 하나라도 NULL이면 결합 결과
  전체가 NULL이 된다. (문자열 전용 함수인 `CONCAT`의 NULL 처리 차이,
  `LENGTH`/`LEN`/`DATALENGTH` 등은 [`05-NULL과문자열`](../05-NULL과문자열/README.md)에서
  본격적으로 다룬다 — 여기서는 "NULL 산술의 한 예시"로만 짧게 확인한다.)
- **0으로 나누기(division by zero)는 에러, NULL로 나누기는 NULL** — 이 둘은
  전혀 다른 현상이다. `n / 0`은 수학적으로 정의되지 않는 연산이라 DBMS가
  실행 자체를 막고 에러를 던지지만, `n / NULL`은 "분모를 모른다"는 뜻이라
  정상적으로 실행되고 결과가 NULL이 될 뿐이다.
- **`NULLIF(discount_qty, 0)`로 0을 NULL로 바꿔치기**하면 나눗셈의 분모가
  "0"이 아니라 "NULL"이 되므로, 에러 대신 NULL 결과를 받을 수 있다 — 이는
  에러를 "없애는" 것이 아니라 애초에 에러가 발생할 상황 자체를 피하는
  전형적인 SQLD 방어 패턴이다.

## 3. 공통 입력 데이터

`00-NULL의미와3값논리`와 완전히 같은 `null_lab_customer`/`null_lab_dept`/
`null_lab_excluded_codes`를 재사용한다(전체 DDL/INSERT는
[`oracle.sql`](./oracle.sql), [`sqlserver.sql`](./sqlserver.sql) 참고). 이
폴더에서 특히 중요한 컬럼:

| 컬럼 | NULL 위치 | 이 폴더에서의 역할 |
|---|---|---|
| `purchase_amt` | customer_id 5, 11 | 산술 전파(STEP 1) |
| `age` | customer_id 5 | 산술 전파(STEP 1) |
| `score` | customer_id 3, 9 | 산술 전파(STEP 1) |
| `nickname` | customer_id 2, 8(+ Oracle은 3도) | 문자열 결합 NULL 전파(STEP 2) |
| `order_qty` | NULL 없음(0은 customer_id=6) | 나눗셈 분자(STEP 3) |
| `discount_qty` | customer_id=7만 NULL, customer_id=2는 **0**(NULL 아님) | 0 vs NULL 나눗셈 대조(STEP 3) — 이 폴더의 핵심 데이터 |

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — 공통 데이터셋 생성 후 3단계.

1. `purchase_amt`/`age`/`score`에 대한 산술연산이 NULL 행에서 모두 NULL을
   반환함을 확인
2. `nickname || '님'`이 NULL 행에서 NULL이 됨을 확인 → `NVL(nickname,
   '고객') || '님'`으로 방어
3. `order_qty / discount_qty`가 customer_id=2(분모 0)에서 `ORA-01476` 에러를
   냄을 확인 → customer_id=2를 제외하면 customer_id=7(분모 NULL)은 에러
   없이 NULL이 나옴을 대조 → `NULLIF(discount_qty, 0)`으로 방어

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — 로직은 Oracle과 동일하되 두 가지 차이가
있다.

- 문자열 결합에 `||` 대신 `+`를 쓴다. customer_id=3에서 결과가 Oracle과
  다르다 — SQL Server는 `nickname=''`이 NULL이 아니므로 `'' + '님'` =
  `'님'`으로 정상 결합되지만, Oracle은 3행의 nickname이 이미 NULL로
  저장되어 있어 결과도 NULL이다.
- `order_qty`, `discount_qty`가 모두 `INT`로 선언되어 있어 나눗셈이 **정수
  나눗셈**이 된다(소수부 버림). Oracle의 `NUMBER`는 이 구분이 없어 소수
  결과가 그대로 나온다는 차이가 STEP 3의 다른 행들(8, 9, 11)에서도 드러난다.

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고.

## 7. 결과 차이의 이유

- NULL 전파 규칙 자체는 표준 SQL 공통이므로 STEP 1은 Oracle과 SQL Server가
  완전히 같다.
- STEP 2의 customer_id=3 차이는 이 폴더에서 새로 생긴 규칙이 아니라, 01
  폴더에서 확인한 "Oracle은 `''`을 저장 시 NULL로 바꾼다"는 규칙이 문자열
  결합 결과에도 그대로 반영된 것이다.
- STEP 3의 0 vs NULL 나눗셈 차이(에러 vs NULL)는 산술 표준과 별개로 "0으로
  나누기는 수학적으로 정의되지 않아 DBMS가 예외를 던진다"는 규칙 때문이고,
  Oracle과 SQL Server의 에러 코드/메시지만 벤더별로 다를 뿐 발생 조건은
  같다.
- STEP 3의 정수 나눗셈 차이(8, 9, 11행)는 Oracle `NUMBER`가 정밀도·스케일
  미지정 시 정수/소수를 구분하지 않는 가변 숫자 타입인 반면, SQL Server의
  `INT`는 처음부터 정수 전용 고정 타입이기 때문이다(02 폴더 STEP 6과 같은
  근본 원인).

## 8. SQLD 함정

- **"NULL에 0을 더하면 그대로 0이 된다"거나 "NULL에 아무 값이나 곱하면
  0이 된다"는 착각** — 둘 다 틀렸다. NULL이 관여한 산술연산은 항상 NULL이지
  0이 아니다.
- **`order_qty / discount_qty`처럼 나눗셈이 있는 쿼리를 짜고 "데이터에 0이
  없으니 안전하다"고 안심하는 함정** — 실제 운영 데이터에는 예상치 못한 0이
  섞여 있을 수 있고, `NULLIF`로 미리 방어하지 않으면 쿼리 전체가 런타임에
  실패한다.
- **"분모가 NULL이면 에러가 날 것이다"라는 착각** — 정반대다. 분모가 NULL이면
  에러 없이 조용히 NULL이 나온다. 진짜 에러가 나는 것은 분모가 정확히 0일
  때뿐이다.
- **`NULLIF(discount_qty, 0)`을 쓰면 "0인 행도 다른 행처럼 정상적인 숫자
  결과가 나온다"고 오해** — 실제로는 그 행의 결과가 에러 대신 **NULL**로
  바뀌는 것이지, 나눗셈이 성공적으로 계산되는 것이 아니다.
- **문자열 결합에서 NULL이 하나만 섞여도 전체가 NULL이 된다는 것을 놓치는
  함정** — 여러 컬럼을 `||`/`+`로 이어붙이는 리포트성 쿼리에서 한 컬럼만
  NULL이어도 전체 줄이 NULL로 사라질 수 있다.

## 9. 빅분기 결측치 처리와의 연결

- pandas에서 `df['a'] + df['b']`처럼 Series 간 산술연산을 할 때도 SQL과
  똑같이 한쪽이 `NaN`이면 그 행의 결과가 `NaN`으로 전파된다 — SQL의 NULL
  산술 전파와 원리가 동일하다.
- `df['order_qty'] / df['discount_qty']`처럼 나눗셈을 할 때, pandas(NumPy
  기반)는 SQL과 달리 **0으로 나누어도 에러를 던지지 않고** `inf`(무한대)
  또는 `NaN`(0/0인 경우)을 반환한다는 점이 SQL과의 실무적 차이다 — SQL의
  "0으로 나누면 에러"와 pandas의 "0으로 나누면 inf/NaN"을 혼동하면 실기
  코드를 그대로 SQL로 옮길 때 예상치 못한 에러를 만나게 된다. 이런 이유로
  실무에서도 나눗셈 전에 분모를 `replace(0, np.nan)`(pandas) 또는
  `NULLIF(col, 0)`(SQL)로 미리 정리해두는 방어적 습관이 두 환경 모두에서
  권장된다.
- 텍스트 데이터를 결합해 파생 변수를 만들 때(`df['a'] + df['b']`, 문자열
  Series 결합)도 결측이 섞이면 결과가 결측으로 전파되므로, `fillna('')`
  등으로 먼저 방어하는 패턴이 이 폴더 STEP 2의 `NVL`/`ISNULL` 방어와 정확히
  대응된다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) 참고.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증** — 이 세션에는 두 DBMS를 실행할 환경이
없다(`../README.md`, 저장소 루트 `README.md` §5 참고). `oracle.sql`/
`sqlserver.sql`은 NULL 산술 전파 규칙(표준 SQL), Oracle `ORA-01476`, SQL
Server의 0으로 나누기 오류, 두 DBMS의 정수/소수 나눗셈 차이를 각 벤더 공식
문서 기준으로 작성한 완전한 스크립트이며, 사용자가 각자의 환경에 그대로
복사해 실행할 수 있다. 실행했다고 보고하지 않는다 — 실제 결과는 각 환경에서
재확인이 필요하다.
