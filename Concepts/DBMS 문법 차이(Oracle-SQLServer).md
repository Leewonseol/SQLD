---
type: concept
pilot: true
origin:
  - current-map
  - mock-01
---

# DBMS 문법 차이 (Oracle · SQL Server)

## 한 줄 정의

SQLD·빅데이터분석기사 실기에서 가장 자주 묻는 Oracle과 SQL Server의 문법·자료형·함수·
NULL 처리 차이를 한곳에 모은 참조 노트. `분석기법/`, `Olist-고객데이터/`,
`필기계산문제-멀티DBMS/`의 각 기법·문제 README는 이 노트를 인용하고, 그 기법에서
실제로 드러나는 차이만 자신의 SQL에 반영한다.

## 핵심 규칙

### NULL과 빈 문자열

- **Oracle은 빈 문자열 `''`을 VARCHAR2 컬럼에 넣으면 NULL로 저장한다.** SQL Server는
  `''`과 NULL을 별개의 값으로 구분한다 — 같은 `INSERT ... VALUES ('', ...)`가 두 DBMS에서
  다른 결과를 남긴다.
- [[NULL]] 개념 노트: PK는 NULL 불가, `=` 비교 불가([[IS NULL]]), 산술식에 NULL이
  섞이면 결과도 NULL — 이 세 규칙은 두 DBMS 공통.
- [[집계 함수]] 노트: `COUNT(*)`는 NULL 포함 전체 행, `COUNT(열)`은 NULL 제외 — 공통.
- 문자열 결합에서 NULL 처리가 갈린다: Oracle `\|\|`는 NULL을 빈 문자열처럼 건너뛰고
  나머지를 이어붙이지만(`'A' \|\| NULL = 'A'`), SQL Server `+`는 피연산자 중 하나라도
  NULL이면 전체 결과가 NULL이다(`'A' + NULL = NULL`, `CONCAT()`을 쓰면 NULL을 건너뜀).
- `WHERE` 조건이 NULL과 비교돼 UNKNOWN이 되면 두 DBMS 모두 그 행을 결과에서 제외한다
  (TRUE만 통과, FALSE·UNKNOWN 모두 제외) — [[WHERE]] 개념과 동일, DBMS 차이 없음.

### NULL 관련 함수

| 목적 | Oracle | SQL Server | 공통(표준) |
|---|---|---|---|
| 대체값 | `NVL(x, 대체값)` (인수 2개) | `ISNULL(x, 대체값)` (인수 2개) | `COALESCE(x1, x2, ...)` (인수 N개) |
| 조건부 대체 | `NVL2(x, x가 NULL 아닐 때 값, x가 NULL일 때 값)` (인수 3개) | 없음(`CASE WHEN x IS NULL THEN ... ELSE ... END`로 대체) | - |
| 같으면 NULL | `NULLIF(x, y)` | `NULLIF(x, y)` | 동일 |

- `NVL`/`ISNULL`은 **반환 자료형이 첫 번째 인수를 따른다** — 자료형이 다른 두 인수를
  섞으면(예: 문자열과 숫자) Oracle은 암시적 변환을 시도하고, SQL Server의 `ISNULL`은
  첫 번째 인수의 자료형으로 결과를 캐스팅하므로 두 번째 인수 값이 잘리는 사고가 날 수 있다
  (예: `ISNULL(NULL, 3.14)`를 첫 인수가 INT로 선언된 컬럼에서 쓰면 `3`으로 잘림).
  `COALESCE`는 인수들의 자료형을 표준 규칙으로 승격하므로 이런 사고가 상대적으로 적다.

### 문자열 처리

| 기능 | Oracle | SQL Server | 비고 |
|---|---|---|---|
| 결합 | `\|\|` | `+` (NULL 전파 주의) | 둘 다 `CONCAT(a,b,...)` 지원, NULL을 안전하게 건너뜀 |
| 부분 추출 | `SUBSTR(문자열, 시작, 길이)` | `SUBSTRING(문자열, 시작, 길이)` | 길이 인수 Oracle은 생략 가능(끝까지), SQL Server는 필수 |
| 위치 검색 | `INSTR(문자열, 검색어)` | `CHARINDEX(검색어, 문자열)` | **인수 순서가 반대**(Oracle: 대상이 먼저, SQL Server: 검색어가 먼저) |
| 길이 | `LENGTH(문자열)` | `LEN(문자열)` | **SQL Server `LEN`은 오른쪽 공백(trailing space)을 세지 않는다.** Oracle `LENGTH`는 앞뒤 공백을 모두 센다 — `LENGTH('AB ')`=3이지만 `LEN('AB ')`=2 |
| 공백/문자 제거 | `TRIM`, `LTRIM`, `RTRIM` | `TRIM`(2017+), `LTRIM`, `RTRIM` | 오래된 SQL Server(2016 이하)는 `TRIM` 미지원 → `LTRIM(RTRIM(x))`로 대체 |

[[문자형 함수]] 개념 노트의 `LENGTH/LEN` 규칙("공백도 문자로 계산")은 Oracle 기준
서술이며, SQL Server `LEN`의 trailing space 예외는 별도로 확인이 필요하다(보강 대상).

### 숫자와 통계 함수

| 기능 | Oracle | SQL Server |
|---|---|---|
| 반올림 | `ROUND(x, n)` | `ROUND(x, n)` — 동일 |
| 버림(절삭) | `TRUNC(x, n)` | 전용 함수 없음(2022 이전) → `ROUND(x, n, 1)`(세 번째 인수 1이면 절삭) 또는 `CAST/FLOOR` 조합 |
| 나머지 | `MOD(x, y)` | `x % y` |
| 정수 나눗셈 | `/`는 항상 실수 나눗셈(NUMBER는 소수 보존) | `INT / INT`는 **정수 나눗셈으로 소수부가 잘린다** — `3/4`가 SQL Server에서 `0` |
| 표본표준편차 | `STDDEV(x)` | `STDEV(x)` | **두 DBMS 모두 기본값이 "표본"** — MySQL의 `STD`가 모표준편차인 것과 헷갈리지 말 것 |
| 모표준편차 | `STDDEV_POP(x)` | `STDEVP(x)` | |
| 표본분산 | `VARIANCE(x)` | `VAR(x)` | |
| 모분산 | `VAR_POP(x)`(11g+) | `VARP(x)` | Oracle 하위버전은 `VARIANCE`만, 별도 `VAR_POP` 없을 수 있음(버전별 확인 필요) |

[[숫자형 함수]] 개념 노트의 `ROUND`/`TRUNC`/`MOD` 정의는 Oracle 기준이며, SQL Server의
`TRUNC` 부재·`%` 연산자·정수 나눗셈 절단은 이 노트에서 보강한다.

### 날짜 처리

| 기능 | Oracle | SQL Server |
|---|---|---|
| 현재 일시 | `SYSDATE`(초 단위), `SYSTIMESTAMP`(나노초+시간대) | `GETDATE()`(밀리초), `SYSDATETIME()`(나노초) |
| 날짜 연산 | `날짜 + 정수` = 며칠 뒤(정수 1 = 1일), `날짜 + 1/24` = 1시간 뒤 | `DATEADD(day, n, 날짜)`, `DATEADD(hour, n, 날짜)` — 정수를 날짜에 직접 더할 수 없음 |
| 날짜 차이 | `날짜1 - 날짜2` = 일수(숫자) | `DATEDIFF(day, 날짜2, 날짜1)` — 뺄셈 연산자 없음, 단위를 명시해야 함 |
| 문자→날짜 | `TO_DATE(문자열, 포맷)` | `CONVERT(DATE, 문자열, 스타일코드)` 또는 `CAST(문자열 AS DATE)` |
| 날짜→문자 | `TO_CHAR(날짜, 포맷)` | `CONVERT(VARCHAR, 날짜, 스타일코드)` 또는 `FORMAT(날짜, .NET포맷)` |
| 월 단위 연산 | `ADD_MONTHS(날짜, n)`, `LAST_DAY(날짜)` | `DATEADD(month, n, 날짜)`, `EOMONTH(날짜)` |

`TO_DATE`/`TO_CHAR`는 자유 형식 포맷 문자열(`'YYYY-MM-DD'`)을 쓰지만, SQL Server
`CONVERT`는 **정수 스타일 코드**(예: 120=`'yyyy-mm-dd hh:mi:ss'`)를 쓴다는 점이 근본적으로
다르다 — 포맷 문자열 대 스타일 코드라는 서로 다른 설계 방식이므로 단순 이름 치환이 불가능하다.

### 형변환

| 기능 | Oracle | SQL Server |
|---|---|---|
| 명시적 변환 | `TO_NUMBER`, `TO_DATE`, `TO_CHAR` (포맷 지정형) | `CAST(x AS 자료형)`, `CONVERT(자료형, x, 스타일)` |
| 변환 실패 시 | 오류 발생(예외) | `CAST`/`CONVERT`도 오류, `TRY_CAST`/`TRY_CONVERT`는 실패 시 **NULL 반환**(오류 없음) |
| 암시적 변환 | 문자↔숫자 비교 시 숫자 기준으로 자동 변환(오래 걸리면 인덱스 미사용 위험) | 자료형 우선순위 규칙에 따라 자동 변환, 우선순위가 낮은 쪽이 높은 쪽으로 변환됨 |

Oracle에는 `TRY_CAST`에 대응하는 표준 함수가 없고(12c+ `CONVERT ... DEFAULT ... ON
CONVERSION ERROR` 등 별도 문법 필요), SQL Server의 `TRY_CAST`/`TRY_CONVERT`처럼
"실패하면 그냥 NULL"을 한 함수로 처리하는 방법이 없다는 점이 실무에서 자주 부딪히는 차이다.

### 행 제한과 정렬

| 기능 | Oracle | SQL Server |
|---|---|---|
| 상위 N행 (구버전) | `WHERE ROWNUM <= n` (정렬 전에 번호가 매겨지므로 `ORDER BY`와 함께 쓸 때 서브쿼리로 감싸야 함) | `SELECT TOP n ... ORDER BY ...` |
| 상위 N행 (표준) | `FETCH FIRST n ROWS ONLY` (12c+, `ORDER BY` 뒤에 위치) | `OFFSET 0 ROWS FETCH NEXT n ROWS ONLY` |
| NULL 정렬 기본값 | ASC → NULL 마지막, DESC → NULL 처음 | ASC → NULL 처음, DESC → NULL 마지막 |
| NULL 정렬 명시 | `NULLS FIRST` / `NULLS LAST` | 없음 → `ORDER BY CASE WHEN x IS NULL THEN 0 ELSE 1 END, x`로 흉내 |

[[ORDER BY]] 개념 노트에 이미 "NULL 정렬 순서는 Oracle과 SQL Server가 서로 다르다"고
기록되어 있다 — 이 노트는 그 규칙에 `NULLS FIRST/LAST` 유무까지 보강한다.
**`ROWNUM`의 함정**: `WHERE ROWNUM <= 3 ORDER BY score DESC`처럼 쓰면 정렬 전에
ROWNUM이 매겨진 뒤 정렬되므로 "상위 3건"이 아니라 "임의 3건을 뽑아 정렬한 것"이 된다 —
반드시 `SELECT * FROM (SELECT ... ORDER BY score DESC) WHERE ROWNUM <= 3`처럼
서브쿼리로 감싸야 한다.

### 집합·계층·재귀

| 기능 | Oracle | SQL Server |
|---|---|---|
| 차집합 | `MINUS` | `EXCEPT` |
| 합집합/교집합 | `UNION`, `UNION ALL`, `INTERSECT` | 동일(이름 같음) |
| 계층 질의 | `START WITH ... CONNECT BY PRIOR 자식 = 부모`, `LEVEL`, `PRIOR` | 재귀 CTE: `WITH cte AS (앵커 쿼리 UNION ALL 재귀 쿼리) SELECT * FROM cte` |

[[집합 연산자]] 노트의 `MINUS`는 Oracle 전용이며 SQL Server에서는 `EXCEPT`로 이름만
다를 뿐 의미(첫 결과 - 두 번째 결과)는 동일하다. [[계층형 질의]] 노트의
`START WITH...CONNECT BY`는 Oracle 전용 문법이고, SQL Server는 이를 지원하지 않아
재귀 CTE로 **다시 작성**해야 한다 — 함수 이름 치환이 아니라 질의 구조 자체가 달라지는
사례다.

### GROUP BY와 별칭

- Oracle과 SQL Server는 표준 SQL 규칙대로 `GROUP BY`에 `SELECT` 목록에서 정의한
  **별칭을 쓸 수 없다**(`GROUP BY`가 논리적으로 `SELECT`보다 먼저 실행되므로 그
  시점엔 별칭이 존재하지 않는다) — `CASE WHEN ... END AS prob_bucket`처럼 만든
  별칭을 그대로 `GROUP BY prob_bucket`에 쓰면 두 DBMS 모두 오류가 난다. 전체 `CASE`
  표현식을 `GROUP BY`에 다시 써야 한다.
- SQLite와 MySQL/MariaDB는 이를 허용하는 비표준 확장을 갖고 있어, SQLite 기준으로
  작성한 SQL을 그대로 Oracle/SQL Server에 옮기면 이 지점에서 걸린다
  (`분석기법/06-로지스틱회귀`의 `optional/03_verify_sqlite.sql`과
  `03_verify_oracle.sql`/`03_verify_sqlserver.sql`을 비교하면 실제 차이를 볼 수 있다).

### 트랜잭션과 DDL

- [[AUTO COMMIT]] 노트: Oracle은 DML을 수동 커밋하지만 DDL 실행 시 자동 커밋되고,
  SQL Server는 기본이 AUTO COMMIT이며 `BEGIN TRANSACTION`으로 수동 전환 가능.
- [[DDL]] 노트: `DROP`은 객체(구조+데이터)를 삭제, `TRUNCATE`는 데이터만 비움(둘 다
  Oracle에서 DDL로 취급되어 자동 커밋 → ROLLBACK 불가). SQL Server의 `TRUNCATE TABLE`도
  최소 로깅 작업이라 일반적으로 트랜잭션 밖에서는 되돌리기 어렵지만, `BEGIN TRAN`으로
  감싸면 `DELETE`처럼 `ROLLBACK` 가능하다는 점이 Oracle과의 실질적 차이다
  (Oracle은 `TRUNCATE`를 트랜잭션으로 감싸도 롤백되지 않음).
- 자동 증가 식별자: Oracle은 `SEQUENCE` 객체를 만들고 `시퀀스명.NEXTVAL`로 값을 가져오는
  방식(12c+는 `GENERATED ... AS IDENTITY` 컬럼도 지원), SQL Server는 컬럼 자체에
  `IDENTITY(시작값, 증가값)` 속성을 붙이는 방식 — 객체 대 컬럼 속성이라는 설계가 다르다.

## Related Concepts

- [[NULL]]
- [[자료형]]
- [[집합 연산자]]
- [[계층형 질의]]
- [[DDL]]
- [[AUTO COMMIT]]
- [[ORDER BY]]
- [[문자형 함수]]
- [[숫자형 함수]]
- [[집계 함수]]

## Source

- 이 저장소의 기존 Concepts 노트(NULL, 자료형, 집합 연산자, 계층형 질의, DDL,
  AUTO COMMIT, ORDER BY, 문자형 함수, 숫자형 함수, 집계 함수)에서 이미 확인된 규칙을
  우선 인용했다.
- 위 표 중 원본 마인드맵/Concepts에 없던 항목(NVL2, ISNULL 자료형 우선순위, LEN 공백
  처리, TRY_CAST/TRY_CONVERT, ROWNUM 서브쿼리 함정, IDENTITY/SEQUENCE 등)은 Oracle·
  SQL Server 공식 문서 기준의 일반 지식이며, **이 세션에서 실제 Oracle/SQL Server로
  실행 검증하지 않았다** — 실기 대비 시 각자 환경에서 재검증할 것을 권장한다.
