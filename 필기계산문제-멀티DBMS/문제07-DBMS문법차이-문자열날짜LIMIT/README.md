---
type: written-exam-problem
pilot: true
---

# 문제 07. DBMS 문법 차이 전용 — 문자열 결합·날짜 계산·상위 N행·NULL 처리

## 필기 예상문제 (재현, SQL 문법형)

> 다음 고객 테이블에서 (1) 성과 이름을 합쳐 전체 이름을 만들고, (2) 기준일
> `2025-06-01` 기준 가입 후 경과일수를 구하고, (3) 전화번호가 없는(NULL) 고객은
> `'미등록'`으로 표시한 뒤, (4) 가입일이 가장 최근인 고객 3명만 조회하는 SQL을
> 작성하시오.
>
> | 성 | 이름 | 가입일 | 전화번호 |
> |---|---|---|---|
> | 김 | 민준 | 2024-03-15 | 010-1111-2222 |
> | 이 | 서연 | 2024-07-01 | (없음) |
> | 박 | 도윤 | 2023-11-20 | 010-3333-4444 |
> | 최 | 하은 | 2025-01-10 | (없음) |
> | 정 | 지호 | 2024-05-05 | 010-5555-6666 |

이 문제는 계산 자체보다 **DBMS마다 문법이 갈리는 네 가지 지점**을 겪어보는 것이
목적이다. `run_compare.py`에서 SQLite/DuckDB/MariaDB 세 엔진에 실제로 서로 다른
SQL 문자열을 실행해서 **같은 결과**가 나오는지 확인한다.

## 4-DBMS 문법 비교표

### (1) 문자열 결합

| DBMS | 문법 | 비고 |
|---|---|---|
| Oracle | `성 \|\| 이름` | |
| SQL Server | `성 + 이름` | `+`는 NULL이 하나라도 있으면 전체가 NULL |
| MySQL/MariaDB | `CONCAT(성, 이름)` | **`\|\|`는 기본 설정에서 결합이 아니라 논리 OR로 해석된다** — 이 세션에서 실제로 `'김' \|\| '민준'`을 실행하면 `0`이 나옴(문자열 결합이 아님)을 확인했다. `PIPES_AS_CONCAT` 모드를 켜야 `\|\|`가 결합 연산자가 된다. |
| DuckDB | `성 \|\| 이름` | |
| SQLite | `성 \|\| 이름` | |

### (2) 날짜 차이(경과일수)

| DBMS | 문법 |
|---|---|
| Oracle | `날짜1 - 날짜2` (바로 숫자가 나옴) |
| SQL Server | `DATEDIFF(day, 날짜2, 날짜1)` |
| MySQL/MariaDB | `DATEDIFF(날짜1, 날짜2)` |
| DuckDB | `날짜1 - 날짜2` 또는 `DATEDIFF('day', 날짜2, 날짜1)` |
| SQLite | `JULIANDAY(날짜1) - JULIANDAY(날짜2)` (날짜 전용 뺄셈 없음) |

### (3) NULL 처리

| DBMS | 전용 함수 | 표준(모든 DBMS 공통) |
|---|---|---|
| Oracle | `NVL(x, 대체값)` | `COALESCE(x, 대체값)` |
| SQL Server | `ISNULL(x, 대체값)` | `COALESCE(x, 대체값)` |
| MySQL/MariaDB | `IFNULL(x, 대체값)` | `COALESCE(x, 대체값)` |
| DuckDB / SQLite | 없음(표준만) | `COALESCE(x, 대체값)` |

`COALESCE`는 다섯 DBMS 모두에서 동일하게 동작하는 **유일하게 이식성 있는 선택**이다 —
이 저장소 전체(`분석기법/`, `Olist-고객데이터/`)에서 NULL 처리에 항상 `COALESCE`를 쓴
이유이기도 하다.

### (4) 상위 N행

| DBMS | 문법 |
|---|---|
| Oracle | `FETCH FIRST 3 ROWS ONLY` (12c+) 또는 `WHERE ROWNUM <= 3` |
| SQL Server | `SELECT TOP 3 ...` |
| MySQL/MariaDB | `LIMIT 3` |
| DuckDB | `LIMIT 3` |
| SQLite | `LIMIT 3` |

## 실행

```bash
python3 run_compare.py
```
