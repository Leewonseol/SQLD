---
type: sql-practice
pilot: true
category: JOIN-NULL-통합
source_note: "깨우침/JOIN·표준 JOIN 문제 풀이표.md + 깨우침/NULL 정리.md (교차 개념)"
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# JOIN×NULL 통합 실습

`../JOIN-표준JOIN`과 `../NULL`은 각각 JOIN과 NULL을 **따로** 연습하는
폴더다. 이 폴더는 그 두 폴더를 대체하지 않고 그대로 둔 채, **JOIN과 NULL이
동시에 문제를 일으키는 지점**만 14개 예제(JN01~JN14)로 새로 묶은 것이다.

실무·시험 모두에서 가장 많이 틀리는 지점은 JOIN 따로, NULL 따로가 아니라
**둘이 겹치는 순간**이다 — 조인 키 자체가 NULL이라 등가조인이 안 되는 것,
OUTER JOIN이 만든 NULL을 WHERE가 다시 지우는 것, `NOT IN` 서브쿼리가 NULL
때문에 깨지는 것과 `LEFT JOIN + IS NULL`은 왜 안전한지 등이다.

## 학습 목표

- 등가조인 키에 NULL이 있으면 **어느 쪽에도 매칭되지 않는다**는 것(NULL과
  NULL도 매칭 안 됨)을 CROSS JOIN(NULL과 무관)과 대조해 확인한다.
- OUTER JOIN이 보존한 행을 WHERE가 다시 지우는 함정과, `LEFT JOIN + IS NULL`
  안티조인 패턴이 왜 안전한지 확인한다.
- **`NOT IN` 서브쿼리 vs `LEFT JOIN + IS NULL`**: 똑같은 질문("연결된 행이
  없는 것은 무엇인가")에 대해 서브쿼리 결과에 NULL이 하나라도 섞이면 `NOT IN`은
  틀린 답(0행)을 내고 `LEFT JOIN + IS NULL`은 정확한 답을 낸다는 것을 나란히
  실행해 확인한다 — 이 실습에서 가장 중요한 예제(JN05 vs JN06)다.
- JOIN 결과에 남은 NULL을 `COALESCE`/`NVL`/`ISNULL`로 기본값 처리하는 법과,
  집계 함수가 그 NULL을 어떻게 다루는지(AVG는 제외, COALESCE는 치환) 구분한다.

## 3층 구현 원칙

`../JOIN-표준JOIN/README.md`, `../NULL/README.md`와 동일하다 — Python은
모델을 학습하지 않고 실행 결과 검증·적재만 담당한다.

| 층 | 담당 | 이 폴더에서의 역할 |
|---|---|---|
| 1. SQL로 데이터·중간 구조 준비 | `01_prepare.sql` | 고정 데이터 INSERT, 검증 테이블 3종 생성 |
| 2. Python으로 실행·검증·적재 | `02_validate.py` | 실제 결과와 기대 결과 비교, PASS/FAIL 기록(모델 학습 없음) |
| 3. SQL로 결과 재조회·검산 | `03_verify.sql` | PASS/FAIL 집계, 실패 예제 조회, JN05 vs JN06 핵심 대조 재검산 |

## 실행 순서

```
README.md (이 문서)
  -> Oracle/01_prepare.sql   또는   SQLServer/01_prepare.sql
  -> Oracle/02_examples.sql  또는   SQLServer/02_examples.sql
  -> python3 02_validate.py --dbms oracle   (또는 sqlserver, 또는 인자 없이 둘 다)
  -> Oracle/03_verify.sql    또는   SQLServer/03_verify.sql
```

## 데이터 출처

`customer_id` 값은 모두 저장소 루트 `olist_customers_dataset.csv`에서 실제로
뽑은 값이다(`../JOIN-표준JOIN`, `../NULL`과 같은 원칙). `sales_region`,
`amount`, `points`, `total_spent` 같은 부가 속성은 이 실습을 위해 새로
부여한 값이며, 그 안에 의도적으로 NULL을 넣었다(원본 CSV에는 결측이 없다는
점은 `../NULL/README.md` 참고). 이 폴더의 데이터는 `../JOIN-표준JOIN`,
`../NULL`의 데이터와 완전히 독립적이다(같은 CSV에서 뽑았지만 다른 고객,
다른 테이블).

## 데이터셋

| 테이블 | 용도 | 행 수 |
|---|---|---|
| `customers` | 고객 5명, 그 중 1명은 `sales_region`이 NULL(권역 미배정) | 5 |
| `region_lookup` | 영업권역 담당자 매핑(등가조인/USING의 NULL 키 배제 확인) | 3 |
| `customer_orders` | 고객별 주문(1건은 금액 NULL, 1건은 고객 미상 "고아 주문") | 5 |
| `customer_loyalty` | CUSTOMERS와 2명만 겹치는 별도 고객 목록(FULL OUTER JOIN 병합용) | 4 |
| `customer_spend` / `spend_band` | 비등가조인(BETWEEN) 경계값 NULL 확인 | 5 / 3 |

## 필기 개념 ↔ 예제 대응표

| example_id | 교차 개념 | 기대 결과 | Oracle/SQL Server 차이 |
|---|---|---:|---|
| JN01 | 등가조인 키에 NULL이 있으면 매칭 안 됨 | 4행 | 없음 |
| JN02 | LEFT OUTER JOIN이 만드는 NULL | 6행 | 없음 |
| JN03 | COUNT(*) vs COUNT(우측열) | row_count=6, numeric=4 | 없음 |
| JN04 | OUTER JOIN 후 WHERE로 보존행 제거 함정 | 2행 | 없음 |
| JN05 | LEFT JOIN+IS NULL 안티조인(정답) | 2행 | 없음 |
| JN06 | NOT IN 서브쿼리 함정(오답, JN05와 대조) | 0행 | 없음 |
| JN07 | COALESCE로 미매칭 집계값 기본값 치환 | 0 | 없음 |
| JN08 | JOIN 결과 집계에서 NULL 제외(AVG) | 100 | 없음 |
| JN09 | LEFT JOIN + GROUP BY의 NULL 그룹 | 4그룹 | 없음 |
| JN10 | FULL OUTER JOIN + COALESCE 키 병합 | 7행 | 없음 |
| JN11 | USING과 NULL 키 | 4행 | **SQL Server 미지원** → ON으로 대체 |
| JN12 | 비등가조인(BETWEEN) 경계값 NULL | 4행 | 없음 |
| JN13 | CROSS JOIN은 NULL과 무관하게 행수 유지 | 15행 | 없음 |
| JN14 | Oracle `(+)` 반대편 필터에 `(+)` 누락 시 무력화 | 2행 | **SQL Server 미지원**(`(+)` 자체 없음) → LEFT JOIN+WHERE로 동일 함정 재현 |

전체 정답표는 [`../_common/expected_results.csv`](../_common/expected_results.csv)에
`topic=JOIN_NULL`로 필터링해서 볼 수 있다.

## 이 실습에서 가장 중요한 대조: JN05 vs JN06

```sql
-- JN05: 정답 (2행 - 주문 없는 고객)
SELECT c.customer_id
FROM customers c LEFT OUTER JOIN customer_orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- JN06: 오답 (0행 - 서브쿼리에 고아 주문의 NULL customer_id가 섞여 있어서)
SELECT c.customer_id
FROM customers c
WHERE c.customer_id NOT IN (SELECT o.customer_id FROM customer_orders o);
```

두 쿼리는 "주문이 한 건도 없는 고객은 누구인가"라는 같은 질문에 답하려
하지만, `customer_orders`에 고객 식별이 안 된 주문(`O5`, `customer_id IS
NULL`) 한 건이 섞여 있다는 이유만으로 결과가 완전히 달라진다(2행 vs 0행).
`NOT IN`은 내부적으로 여러 개의 `<>` 조건을 `AND`로 묶은 것과 같아서,
목록에 NULL이 하나라도 있으면 그 비교가 `UNKNOWN`이 되어 전체 조건이
`UNKNOWN`이 된다 — 이것이 실무에서 `NOT IN` 대신 `NOT EXISTS`나
`LEFT JOIN + IS NULL`을 권장하는 이유다.

## Oracle · SQL Server 비교

| 항목 | Oracle | SQL Server | 결과가 실제로 달라지는가 |
|---|---|---|---|
| `USING(col)` | 지원(JN11) | **미지원** — `ON`으로 대체 | 문법만 다르고 결과(4행)는 같다 |
| `(+)` 구문형 OUTER JOIN | 지원(JN14, 반대편 필터에 `(+)` 누락 함정 재현) | **미지원** — `(+)` 자체가 없어 이 특유의 함정도 없음, 대신 `LEFT JOIN + WHERE`가 같은 결과를 낸다 | 문법 경로는 다르지만 결과(2행)는 같다 |
| `NOT IN` + NULL 서브쿼리 | 동일하게 깨짐(JN06) | 동일하게 깨짐(JN06) | 없음 — DBMS와 무관한 표준 SQL 3값 논리 |
| `FULL OUTER JOIN` | 지원(JN10) | 지원(JN10) | 없음 |

## 검증 테이블

`sql_example_expectation` / `sql_example_result` / `sql_example_validation`
세 테이블의 논리 스키마는 [`../_common/validation_schema.sql`](../_common/validation_schema.sql)
참고.

## Python 검증 방식

`02_validate.py`는 `../_common/db_helpers.py`를 그대로 가져다 쓴다 —
`../JOIN-표준JOIN`, `../NULL`과 완전히 동일한 방식(환경변수 기반 연결 시도 →
실패 시 정적 검증 모드)이다. 모델 학습은 수행하지 않는다.

## 실제 DB 실행 여부

**이 세션에는 Oracle과 SQL Server 실행 환경이 없다.** 대신 이 폴더의 14개
예제와 동일한 데이터·쿼리 로직을 SQLite로 이 세션에서 **실제로 실행**해
전부 PASS를 확인했다(JN01~JN14, `(+)` 구문 자체는 SQLite에 없으므로 JN14는
JN04와 동일한 ANSI 등가 쿼리로 결과값만 대조했다). `02_validate.py`를 실제
Oracle/SQL Server에 연결해 돌린 적은 없다. 실제 환경에서 실행하려면
`../JOIN-표준JOIN/README.md`와 동일한 환경변수를 설정하고
`python3 02_validate.py --dbms oracle` 또는 `--dbms sqlserver`를 실행한다.

## 재현성

- 모든 예제 데이터는 고정 INSERT 문이다(임의 생성 없음).
- `01_prepare.sql`은 재실행 시 기존 객체를 모두 DROP 후 재생성한다.
- `02_examples.sql`은 `DELETE FROM sql_example_result WHERE example_id LIKE 'JN%'`로
  시작해, 여러 번 실행해도 결과가 중복 적재되지 않는다.
- `example_id`는 이 문서의 표와 동일하게 고정돼 있으며 실행마다 바뀌지 않는다.
