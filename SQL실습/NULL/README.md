---
type: sql-practice
pilot: true
category: NULL
source_note: "깨우침/NULL 정리.md"
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# NULL 실습

이 폴더는 `깨우침/NULL 정리.md`의 36개 개념을 실제 실행 가능한 SQL 예제로
옮긴 것이다. NULL은 머신러닝 모델이 아니라 SQL 동작 규칙이므로, `분석기법`
폴더의 3층 구조를 차용하되 Python은 모델을 학습하지 않는다 — SQL 결과의
자동 검증과 결과 적재만 담당한다.

## 학습 목표

- NULL이 비교·산술·집계·조인·그룹화·정렬 각 위치에서 서로 다른 규칙을
  따른다는 것을 직접 실행 결과로 확인한다.
- `COUNT(*)`와 `COUNT(열)`, `IN`/`NOT IN`과 NULL, 서브쿼리 `NOT IN` 함정처럼
  실제로 값이 갈리는 지점을 SQL로 재현한다.
- Oracle과 SQL Server에서 빈 문자열, NULL 정렬 위치, NVL/ISNULL, UNIQUE의
  NULL 허용 개수가 실제로 다르게 동작한다는 것을 같은 데이터로 대조한다.

## 필기 핵심 규칙 (원문 요약)

| 순서 | 확인 질문 | 적용 규칙 |
|---|---|---|
| 1 | NULL이 어디에 등장하는가 | 비교·산술·집계·조인·그룹화·정렬 중 위치 확인 |
| 2 | 해당 연산이 NULL을 전파하는가 | 산술 연산은 일반적으로 결과가 NULL |
| 3 | 해당 연산이 NULL을 제외하는가 | 주요 집계 함수는 NULL 제외 |
| 4 | 행 자체를 세는가, 열 값을 세는가 | COUNT(*)와 COUNT(열) 구분 |
| 5 | 조건 결과가 TRUE/FALSE/UNKNOWN 중 무엇인가 | WHERE는 TRUE만 통과 |
| 6 | DBMS별 차이가 있는가 | 정렬·빈 문자열·함수 차이 확인 |

## 3층 구현 원칙 (이 실습에서의 의미)

| 층 | 담당 | 이 폴더에서의 역할 |
|---|---|---|
| 1. SQL로 데이터·중간 구조 준비 | `01_prepare.sql` | 고정 데이터 INSERT, 검증 테이블 3종 생성 |
| 2. Python으로 실행·검증·적재 | `02_validate.py` | 실제 결과와 기대 결과 비교, PASS/FAIL 기록(모델 학습 없음) |
| 3. SQL로 결과 재조회·검산 | `03_verify.sql` | PASS/FAIL 집계, 실패 예제 조회, 핵심값 재검산 |

## 실행 순서

```
README.md (이 문서)
  -> Oracle/01_prepare.sql   또는   SQLServer/01_prepare.sql
  -> Oracle/02_examples.sql  또는   SQLServer/02_examples.sql
  -> python3 02_validate.py --dbms oracle   (또는 sqlserver, 또는 인자 없이 둘 다)
  -> Oracle/03_verify.sql    또는   SQLServer/03_verify.sql
```

## 데이터셋

| 테이블 | 용도 |
|---|---|
| `score_t` (10, NULL, 20) | COUNT/SUM/AVG/MIN/MAX, =NULL, IS NULL, 산술 전파 (N04~N07,N10~N12,N14~N17) |
| `score_zero` (10, 20, 0) | NULL과 0의 평균 차이 대조군(N18) |
| `score_dup` (10,10,NULL,20) | COUNT(DISTINCT 열) 전용(N13) |
| `str_t` ('APPLE',NULL,'',' ') | NULL/빈문자열/공백 구분, LIKE(N01~N03B, N09) |
| `null_left`(1,2,3) / `null_right`(1,2) | OUTER JOIN이 만드는 NULL, COUNT 차이(N28,N29) |
| `region_t` (서울,NULL,NULL) | GROUP BY의 NULL(N30,N30B) |
| `distinct_t` (1,1,NULL,NULL) | DISTINCT의 NULL(N31) |
| `order_t` (10,NULL,5) | ORDER BY의 NULL 위치(N32,N32B) |
| `unique_test` | UNIQUE 제약과 NULL - Oracle 3행 vs SQL Server 2행(N35) |
| `notnull_test` | PK/NOT NULL 제약 메타데이터 확인(N33,N34) |
| `fk_parent` / `fk_child` | FOREIGN KEY와 NULL(N36) |
| `base_vals`(1,2,3) / `exclude_list`(1,3,NULL) | 서브쿼리 NOT IN과 NULL 함정(N22) |

## 필기 개념 ↔ 예제 대응표

| example_id | 필기 개념(원문 순서) | 기대 결과 | Oracle/SQL Server 차이 |
|---|---|---:|---|
| N01 | 1. NULL, 0, 공백, 빈 문자열 | Oracle 2건 / SQLServer 1건 | **다르다** |
| N02 | 2/3. 빈 문자열과 NULL(`TXT=''`) | Oracle 0건 / SQLServer 1건 | **다르다** |
| N03 | 2/3. 공백 문자열 길이 | Oracle LENGTH=1 / SQLServer LEN=0 | **다르다** |
| N03B | 2/3. 공백 문자열 길이(바이트) | Oracle 1 / SQLServer DATALENGTH=1 | 개념 자체가 SQL Server에만 별도 존재 |
| N04 | 4. `= NULL` | 0건 | 없음 |
| N05 | 5. `<> NULL` | 0건 | 없음 |
| N06 | 6. `IS NULL` | 1건 | 없음 |
| N07 | 7. `IS NOT NULL` | 2건 | 없음 |
| N08/N08B/N08C | 8. TRUE/FALSE/UNKNOWN | 1/0/0건 | 없음 |
| N09 | 9. LIKE와 NULL | 1건 | 없음 |
| N10 | 10. 산술 연산 NULL 전파 | 플래그 1 | 없음 |
| N11 | 11. COUNT(*) | 3 | 없음 |
| N12 | 12. COUNT(열) | 2 | 없음 |
| N13 | 13. COUNT(DISTINCT 열) | 2 | 없음 |
| N14 | 14. SUM | 30 | 없음 |
| N15 | 15. AVG | 15 | 없음 |
| N16 | 16. MIN | 10 | 없음 |
| N17 | 17. MAX | 20 | 없음 |
| N18 | 18. NULL과 0의 평균 차이 | 10 | 없음 |
| N19 | 19. 0행 집계 결과 | 1행 반환, COUNT=0 | 없음 |
| N20/N20B/N20C | 20. IN과 NULL | 1/0/0건 | 없음 |
| N21/N21B/N21C | 21. NOT IN과 NULL | 0/0/1건 | 없음 |
| N22 | 22. 서브쿼리 NOT IN과 NULL | 0행 | 없음 |
| N23 | 23. COALESCE | -1 | 없음 |
| N24 | 24. NVL 대응 | -1 | **SQL Server 미지원(NVL 없음)** → ISNULL로 대체 |
| N25 | 25. ISNULL | -1 | **Oracle 미지원(ISNULL 없음)** → NVL로 대체 |
| N26/N26B | 26(10절). NULLIF | 1(플래그)/10 | 없음 |
| N27/N27B | 27. 0 나누기 방지 | 1(플래그)/20 | 없음 |
| N28 | 28(15절). OUTER JOIN으로 생성된 NULL | 1건 | 없음 |
| N29 | 29(16절). OUTER JOIN 이후 COUNT 차이 | 3/2 | 없음 |
| N30/N30B | 30(17절). GROUP BY의 NULL | 2그룹 / 2건 | 없음 |
| N31 | 31(18절). DISTINCT의 NULL | 2건 | 없음 |
| N32/N32B | 32(19절). ORDER BY의 NULL 위치 | ASC/DESC 순위 반전 | **다르다**(정반대) |
| N33 | 33(20절). PRIMARY KEY | 1건 | 없음 |
| N34 | 34(20절). NOT NULL | 1건 | 없음 |
| N35 | 35(21절). UNIQUE | Oracle 3행 / SQLServer 2행 | **다르다** |
| N36 | 36(20절). FOREIGN KEY와 NULL | 1건 | 없음 |

전체 정답표(숫자·근거)는 [`../_common/expected_results.csv`](../_common/expected_results.csv)에
`topic=NULL`로 필터링해서 볼 수 있다.

## Oracle · SQL Server 비교

| 항목 | Oracle | SQL Server | 결과가 실제로 달라지는가 |
|---|---|---|---|
| 빈 문자열 `''` | 저장되는 순간 NULL이 된다 | NULL과 별개의 값으로 저장된다 | **다르다**(N01, N02) |
| 공백 문자열 길이 | `LENGTH(' ')`=1, 구분 개념 없음 | `LEN(' ')`=0(트레일링 공백 제거), `DATALENGTH(' ')`=1 | **다르다**(N03, N03B) |
| NULL 대체 함수 | `NVL(a,b)` (2개 고정) | `ISNULL(a,b)` (2개 고정) | 함수명 자체가 다르다(N24, N25) — `COALESCE`는 표준이라 양쪽 동일 |
| ASC 정렬 기본 | NULL 마지막 | NULL 처음 | **다르다**(N32) |
| DESC 정렬 기본 | NULL 처음 | NULL 마지막 | **다르다**(N32B) |
| NULL 명시 정렬 | `NULLS FIRST`/`NULLS LAST` 직접 지원 | 직접 지원 없음 — `CASE WHEN col IS NULL THEN 1 ELSE 0 END` 정렬 트릭으로 대체(이 실습에서는 기본 동작만 다룸) | 문법 자체가 다르다 |
| UNIQUE와 NULL | 여러 개의 NULL 허용 | NULL 1개만 허용 | **다르다**(N35) |
| 재실행을 위한 DROP | `DROP TABLE x;`(없으면 최초 실행 시 에러, 무시하고 진행) | `IF OBJECT_ID('x','U') IS NOT NULL DROP TABLE x;` | 관례 차이 |

## 필기 vs 실기 연결

- 필기의 "COUNT(*)는 행을 세고, COUNT(열)은 NULL이 아닌 값만 센다"(N11,
  N12, N29)는 OUTER JOIN이 만든 NULL 행에서 실제로 값이 갈리는 것을
  `null_left`/`null_right` 데이터로 직접 확인한다.
- 필기의 "NOT IN 목록에 NULL이 있으면 결과가 비어버릴 수 있다"(N22)는
  `base_vals`/`exclude_list`로 직접 재현한다 — VAL=2가 목록의 어떤 값과도
  일치하지 않는데도 결과에 나오지 않는다는, 가장 흔한 실무 함정이다.
- 필기의 "Oracle은 빈 문자열을 NULL처럼 취급한다"(N01, N02)는 SQL Server
  버전과 나란히 실행해 `expected_numeric_value`가 실제로 다르다는 것으로
  확인한다 — 이 차이는 관례가 아니라 실제 결과값의 차이다.

## 검증 테이블

`sql_example_expectation` / `sql_example_result` / `sql_example_validation`
세 테이블의 논리 스키마는 [`../_common/validation_schema.sql`](../_common/validation_schema.sql)
참고.

## Python 검증 방식

`02_validate.py`는 `../_common/db_helpers.py`를 그대로 가져다 쓴다 —
JOIN-표준JOIN 폴더와 완전히 동일한 방식(환경변수 기반 연결 시도 → 실패 시
정적 검증 모드)이다. 모델 학습은 수행하지 않는다.

## 실제 DB 실행 여부

**이 세션에는 Oracle과 SQL Server 실행 환경이 없다.** 대신 이 폴더의 핵심
숫자 예제(N01~N32B 중 값이 있는 40개 항목)를 SQLite로 이 세션에서 **실제로
실행**해 전부 PASS를 확인했다. Oracle의 `''=NULL` 특성은 STR_T의 id=3에
NULL을 직접 넣은 대조 테이블로, SQL Server의 `''≠NULL`은 원본 STR_T로 각각
시뮬레이션해 N01/N02 두 값이 실제로 다르다는 것까지 확인했다. SQLite의 기본
NULL 정렬(ASC=처음, DESC=마지막)은 SQL Server와 같으므로 N32/N32B의 SQL
Server 쪽 값을 직접 검증했고, Oracle 쪽 값(정반대)은 정렬 규칙을 근거로
추론했다. N33~N36(제약조건 메타데이터), N24/N25(NVL/ISNULL 함수명 자체)는
SQLite 문법 특성상 이 방식으로 검증할 수 없어 여전히 손으로 확인한 값이다.
`02_validate.py`를 실제 Oracle/SQL Server에 연결해 돌린 적은 없다. 실제
환경에서 실행하려면 JOIN-표준JOIN/README.md와 동일한 환경변수를 설정하고
`python3 02_validate.py --dbms oracle` 또는 `--dbms sqlserver`를 실행한다.

## 재현성

- 모든 예제 데이터는 고정 INSERT 문이다(임의 생성 없음).
- `01_prepare.sql`은 재실행 시 기존 객체를 모두 DROP 후 재생성한다.
- `02_examples.sql`은 `DELETE FROM sql_example_result WHERE example_id LIKE 'N%'`로
  시작해, 여러 번 실행해도 결과가 중복 적재되지 않는다.
- `example_id`는 이 문서의 표와 동일하게 고정돼 있으며 실행마다 바뀌지 않는다.
