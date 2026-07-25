# 05. NULL과 문자열 함수 — `||`/`+`/`CONCAT`, `LENGTH`/`LEN`/`DATALENGTH`, `TRIM`

## 1. 학습 목표

- Oracle의 문자열 결합 연산자 `||`와 SQL Server의 `+`가 NULL을 **정반대로**
  처리한다는 것을 직접 확인한다.
- Oracle `CONCAT(a,b)`(2개 인수 고정)과 SQL Server `CONCAT(a,b,...)`(인수
  개수 제한 없음)의 문법 차이, 그리고 두 함수 모두 NULL을 빈 문자열처럼
  취급한다는 공통점을 확인한다.
- `LENGTH`(Oracle) vs `LEN`/`DATALENGTH`(SQL Server)의 차이를 다양한
  예시(공백 섞인 문자열 포함)로 확장 실습한다.
- `TRIM`/`LTRIM`/`RTRIM`이 NULL을 만났을 때의 동작과, Oracle·SQL Server가
  빈 문자열을 다루는 방식 차이 때문에 트림 결과까지 달라진다는 것을 본다.

## 2. 핵심 원리

- **Oracle `||`**: 인수 개수 제한이 없고, NULL이 섞여도 그 부분만 빈
  문자열처럼 건너뛰어 나머지가 그대로 이어붙는다. 즉 `'A' || NULL || 'B'`는
  `'AB'`가 되지 `NULL`이 되지 않는다. 이는 [`03-NULL과산술연산`](../03-NULL과산술연산/README.md)이
  다루는 "산술연산은 NULL이 하나만 섞여도 결과 전체가 NULL이 된다"는 규칙과
  **반대**되는, 문자열 결합 연산자만의 예외적인 동작이다.
- **Oracle `CONCAT(a, b)`**: 딱 2개 인수만 받는다. 3개 이상을 이으려면
  `CONCAT(CONCAT(a, b), c)`처럼 중첩해야 한다(`CONCAT(a, b, c)`는
  ORA-00909 오류). NULL 처리는 `||`와 동일하게 빈 문자열 취급이다.
- **SQL Server `+`**: 문자열 결합에 `||`가 아니라 `+`를 쓴다. NULL이 하나라도
  섞이면 **결과 문자열 전체가 NULL**이 된다 — Oracle `||`와 정확히 반대다.
- **SQL Server `CONCAT(a, b, ...)`**: 인수 개수 제한이 없고, NULL을 빈
  문자열로 취급해서 NULL이 섞여도 결과가 NULL이 되지 않는다. 즉 같은 SQL
  Server 안에서도 `+`와 `CONCAT`이 NULL 처리에서 **정반대**로 동작한다 —
  이것이 이 폴더의 핵심 함정이다.
- **`LENGTH`(Oracle) vs `LEN`(SQL Server)**: 둘 다 NULL의 길이는 NULL이다.
  차이는 공백 처리에 있다 — SQL Server `LEN`은 **뒤쪽(trailing) 공백을
  잘라내고** 길이를 센다(앞쪽 공백은 유지). 그래서 `' '`(공백 한 칸)의
  `LEN`은 `0`으로, 빈 문자열의 `LEN`(0)과 구분되지 않는다. 진짜 저장
  바이트 수를 보려면 `DATALENGTH`를 써야 한다. Oracle `LENGTH`는 이런
  trailing 공백 제거를 하지 않는다(있는 그대로 센다).
- **`TRIM`/`LTRIM`/`RTRIM`**: 인수가 NULL이면 결과도 NULL이다(`TRIM(NULL)`
  = NULL, 두 DBMS 공통). 다만 Oracle은 트림한 결과가 빈 문자열이 되는 순간
  다시 NULL로 취급하지만(Oracle의 `''` = `NULL` 원칙), SQL Server는 트림
  결과가 진짜 빈 문자열(`''`, `DATALENGTH`=0)로 남는다 — 이 역시 01 폴더의
  `''` vs NULL 차이가 문자열 함수 결과에도 그대로 이어지는 것이다.

## 3. 공통 입력 데이터

`00-NULL의미와3값논리`와 완전히 같은 `null_lab_customer`/`null_lab_dept`/
`null_lab_excluded_codes`를 재사용한다. 이 폴더에서 특히 중요한 컬럼은
`customer_name`(NOT NULL, 항상 값 있음)과 `nickname`(customer_id 2,8=NULL,
3=Oracle에서 NULL로 바뀌는 `''`/SQL Server에서는 `''` 그대로, 4=공백
`' '`, 나머지는 일반 문자열)이다. 자세한 배치는 [`../README.md`](../README.md)의
"공통 테스트 데이터" 표를 참고.

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — 공통 데이터셋 생성 후 4단계로 진행한다.

1. `||`로 `customer_name || '(' || nickname || ')'`를 만들어 nickname이
   NULL이어도 결과 전체가 NULL이 되지 않고 괄호만 남음을 확인
2. `CONCAT(a,b)`가 2개 인수만 받는다는 것과, 3개 이상을 이으려면 중첩이
   필요하다는 것을 확인(ORA-00909 사례는 주석으로만 남김)
3. `LENGTH`를 nickname, 공백이 섞인 리터럴(`'  hello  '`), `RTRIM(' ')`
   등 다양한 값에 적용
4. `TRIM`/`LTRIM`/`RTRIM`이 NULL과 공백 한 칸(`' '`)에 어떻게 반응하는지 확인
   (트림 결과가 빈 문자열이 되면 Oracle에서는 다시 NULL로 표시됨)

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — 로직 구성은 Oracle과 대응하되 다음이 다르다.

- 결합 연산자가 `+`이고, `CONCAT(a,b,...)` 함수와 나란히 비교해 NULL 처리가
  정반대임을 `CASE WHEN ... IS NULL`로도 명시적으로 보여준다.
- `LEN`과 `DATALENGTH`를 항상 나란히 조회해서 트레일링 공백 처리 차이를 드러낸다.
- `TRIM`/`LTRIM`/`RTRIM` 결과에 `DATALENGTH`를 붙여, SQL Server에서는 트림
  결과가 진짜 빈 문자열(길이 0, NULL 아님)로 남는다는 것을 Oracle과 대조한다.

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고.

## 7. 결과 차이의 이유

Oracle의 `||`와 SQL Server의 `CONCAT`이 NULL을 빈 문자열로 취급하는 것은
ANSI SQL의 문자열 연결 관용(NULL을 항등원처럼 다루는 방식) 쪽에 가깝고,
SQL Server의 `+`가 NULL 전파(propagation) 규칙을 따르는 것은 `+`가 원래
숫자 연산자이기 때문에 문자열에도 산술연산과 같은 "NULL이 섞이면 전체
NULL" 규칙을 그대로 적용한 것으로 볼 수 있다. `LEN`의 트레일링 공백 제거는
SQL Server가 오래된 `CHAR` 고정폭 비교 관례(뒤쪽 공백은 의미 없는 채움으로
취급)를 문자열 함수에도 남겨둔 결과이고, Oracle `LENGTH`는 이런 관례 없이
저장된 그대로를 센다. `TRIM`의 결과 차이는 결국 01 폴더의 `''` vs NULL
저장 규칙 차이가 함수 결과에도 이어진 것뿐이다.

## 8. SQLD 함정

| 상황 | Oracle | SQL Server |
|---|---|---|
| 문자열 결합에 NULL이 섞이면? | `\|\|`: 빈 문자열처럼 건너뜀 (전체 NULL 아님) | `+`: **전체 결과가 NULL** |
| `CONCAT` 함수에 NULL이 섞이면? | 빈 문자열 취급 (전체 NULL 아님) | 빈 문자열 취급 (전체 NULL 아님) |
| `CONCAT` 인수 개수 | 딱 2개만 (3개 이상은 중첩 필요) | 제한 없음 |

- **"Oracle `\|\|`와 SQL Server `+`가 같은 동작일 것"이라는 착각** — 실제로는
  NULL 처리가 정반대다. SQL Server에서 문자열을 이을 때 NULL이 껴 있을
  가능성이 있다면 `+`가 아니라 `CONCAT`을 써야 안전하다.
- **"같은 DBMS 안이니 결합 연산자와 결합 함수는 NULL을 똑같이 처리할
  것"이라는 착각** — SQL Server 안에서도 `+`와 `CONCAT`은 정반대다.
- **`LEN(nickname) = 0`으로 "빈 문자열인지" 판정하려는 함정** — 공백 한
  칸짜리 값도 `LEN`이 0이 되므로 빈 문자열과 구분이 안 된다. `DATALENGTH`를
  같이 써야 한다(01 폴더에서 이미 확인한 함정의 연장).
- **`CONCAT(a, b, c)`을 Oracle에서 그대로 쓰다 ORA-00909를 만나는 함정** —
  Oracle `CONCAT`은 반드시 2개 인수다.
- 참고: `CASE`/`CHECK` 제약조건이 UNKNOWN을 처리하는 방식은 이 폴더가
  아니라 [`06-NULL과WHERE-CASE`](../06-NULL과WHERE-CASE/README.md),
  [`11-NULL과제약조건`](../11-NULL과제약조건/README.md)에서 다룬다.

## 9. 빅분기 결측치 처리와의 연결

`pandas`에서 문자열 컬럼을 이어붙일 때(`df['a'] + df['b']`)도 결측값(NaN)이
하나라도 섞이면 결과가 NaN이 되어 SQL Server `+`와 같은 동작을 보인다.
반면 `df['a'].fillna('') + df['b'].fillna('')`나 `str.cat(na_rep='')`처럼
결측을 명시적으로 빈 문자열로 치환해야 Oracle `\|\|`/SQL Server `CONCAT`과
같은 "NULL을 건너뛰는" 결합이 된다. 즉 SQL 함수 선택(`+` vs `CONCAT`,
`\|\|` vs `CONCAT`)은 파이썬에서 `fillna` 여부를 언제 적용할지 결정하는
문제와 본질적으로 같은 설계 판단이다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) 참고.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증** — 이 세션에는 두 DBMS를 실행할 환경이
없다(`../README.md`, 저장소 루트 `README.md` §5 참고). `oracle.sql`/
`sqlserver.sql`은 문법·NULL 처리 규칙 기준으로 작성한 완전한 스크립트이며,
사용자가 각자의 Oracle/SQL Server 환경에 그대로 복사해 실행할 수 있다.
실행했다고 보고하지 않는다 — 실제 결과는 각 환경에서 재확인이 필요하다.
