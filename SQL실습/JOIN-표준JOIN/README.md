---
type: sql-practice
pilot: true
category: JOIN-표준JOIN
source_note: "깨우침/JOIN·표준 JOIN 문제 풀이표.md"
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# JOIN·표준 JOIN 실습

이 폴더는 `깨우침/JOIN·표준 JOIN 문제 풀이표.md`의 21개 판독 개념을 실제
실행 가능한 SQL 예제로 옮긴 것이다. `분석기법` 폴더의 3층 구조를 차용하되,
JOIN은 머신러닝 모델이 아니므로 Python은 모델을 학습하지 않는다. 대신
Python은 **SQL 결과의 자동 검증과 결과 적재**만 담당한다.

## 학습 목표

- JOIN을 만났을 때 "테이블 수 → 연결 조건 → 등가/비등가 → 보존 방식(INNER/
  LEFT/RIGHT/FULL) → 문법(ON/USING/NATURAL/구문형/(+))" 순서로 기계적으로
  판독할 수 있다.
- 카티션 곱·중복값 조인에서 결과 행 수를 손으로 계산할 수 있다.
- OUTER JOIN 뒤에 오는 WHERE가 미일치 행을 다시 지울 수 있다는 함정과,
  COUNT(*) vs COUNT(오른쪽 열)의 차이를 구분할 수 있다.
- Oracle과 SQL Server에서 같은 개념이 어떤 문법으로 갈리는지(USING, NATURAL
  JOIN, (+))와, 갈리더라도 결과값은 같아야 한다는 것을 SQL로 직접 확인한다.

## 필기 핵심 규칙 (원문 요약)

| 순서 | 확인할 질문 | 판정 |
|---|---|---|
| 1 | FROM에 테이블이 몇 개인가 | 1개=단일 조회, 2개 이상=JOIN 검토 |
| 2 | 연결 조건이 있는가 | 없으면 카티션 곱 |
| 3 | 연결 조건이 `=`인가 | `=`=등가, 범위=비등가 |
| 4 | 미일치 행도 남기는가 | INNER/LEFT/RIGHT/FULL 판정 |
| 5 | 어떤 문법으로 조건을 썼는가 | ON/USING/NATURAL/구문형/`(+)` |
| 6 | JOIN 뒤 WHERE가 있는가 | OUTER JOIN으로 보존한 행이 다시 제거될 수 있음 |
| 7 | 실제 행 조합이 몇 개인가 | 값별 매칭 횟수 계산 |

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

각 DBMS 폴더는 독립적으로 실행 가능하다 — Oracle 폴더만 실행해도, SQL Server
폴더만 실행해도 그 자체로 완결된 실습이 된다.

## 데이터셋

| 테이블 | 용도 | 행 수 |
|---|---|---|
| `dept` / `emp` / `salgrade` | 등가·비등가 조인, 카티션 곱, 조인조건 vs 필터, 구문형 JOIN, `(+)` | 4 / 8 / 5 |
| `dept2` | ON이 열 이름 달라도 동작함을 보여주는 전용 테이블(J14) | 4 |
| `grade_band` | DEPT(4)×GRADE_BAND(3)=12행 카티션 곱(J04) | 3 |
| `small_a` / `small_b` | 첨부 표준 JOIN 문제 9번 유형 CROSS JOIN(2×3=6행, J05) | 2 / 3 |
| `dup_t1` / `dup_t2` | 첨부 JOIN 문제 5번 유형, 중복값 조인(1,2,3 × 2,2,3=3행, J09) | 3 / 3 |
| `student` / `score` | INNER/LEFT/RIGHT/FULL JOIN, USING, NATURAL JOIN(J10~J13,J15,J16) | 3 / 3 |
| `full_a` / `full_b` | 첨부 표준 JOIN 문제 8번 그대로(1,2 × 2,3=3행, J13) | 2 / 2 |
| `member` / `contact` | OUTER JOIN 뒤 WHERE 제거, LEFT JOIN+IS NULL, COUNT 차이, `(+)`(J18~J21) | 3 / 3 |
| `branch` / `branch_sales` | 첨부 문제 형태 행 수 계산 연습(J23) | 3 / 3 |

## 필기 개념 ↔ 예제 대응표

| example_id | 필기 개념(원문 순서) | 기대 결과 | Oracle/SQL Server 차이 |
|---|---|---:|---|
| J01 | 1. 테이블 수 | 8행(EMP 전체) | 없음 |
| J02 | 2. 연결 조건 없음(카티션 곱) | 32행 | 없음 |
| J03 | 2. 연결 조건 있음(조건부 JOIN) | 8행 | 없음 |
| J04 | 2. 카티션 곱 계산(행수/열수) | 12행 | 없음 |
| J05 | 2. CROSS JOIN(첨부 문제9번) | 6행 | 없음 |
| J06 | 3. 등가 조인 | 8행 | 없음 |
| J07 | 3. 비등가 조인 | 8행 | 없음 |
| J08 | 3. 조인 조건과 일반 필터 조건 구분 | 4행 | 없음 |
| J09 | 4. 중복값에 따른 결과 행 수 증가 | 3행 | 없음 |
| J10 | 7. INNER JOIN | 2행 | 없음 |
| J11 | 6. LEFT OUTER JOIN | 3행 | 없음 |
| J12 | 6. RIGHT OUTER JOIN | 3행 | 없음 |
| J13 | 8. FULL OUTER JOIN | 3행 | 없음(둘 다 ANSI FULL OUTER JOIN 지원) |
| J13B | 8. FULL OUTER JOIN 추가연습 | 4행 | 없음 |
| J14 | 10. ON(열 이름 달라도 가능) | 8행 | 없음 |
| J15 | 11. USING | 2행 | **SQL Server 미지원** → ON으로 대체 |
| J16 | 12. NATURAL JOIN | 2행 | **SQL Server 미지원** → ON으로 대체 |
| J17 | 9. 구문형 JOIN | 4행 | 없음 |
| J18 | 13. Oracle `(+)` | 9행 | **SQL Server 미지원** → LEFT JOIN으로 대체 |
| J19 | 14. OUTER JOIN 이후 WHERE 조건 | 1행 | 없음 |
| J20 | 15. LEFT JOIN과 IS NULL | 1행 | 없음 |
| J21 | 19. COUNT(*)와 COUNT(오른쪽 열) - COUNT(*) | 4행 | 없음 |
| J21B | 19. COUNT(*)와 COUNT(오른쪽 열) - COUNT(우측열) | 3 | 없음 |
| J22 | 20. 테이블 별칭 | 8행 | 없음 |
| J23 | 21. 첨부 문제 형태 행 수 계산 | 3행 | 없음 |

전체 정답표(숫자·근거)는 [`../_common/expected_results.csv`](../_common/expected_results.csv)에
`topic=JOIN`으로 필터링해서 볼 수 있다.

## Oracle · SQL Server 비교

| 항목 | Oracle | SQL Server | 결과가 실제로 달라지는가 |
|---|---|---|---|
| `USING(col)` | 지원(J15) | **미지원** — `ON a.col=b.col`로 대체 | 문법만 다르고 결과(2행)는 같다 |
| `NATURAL JOIN` | 지원(J16) | **미지원** — `ON a.col=b.col`로 대체 | 문법만 다르고 결과(2행)는 같다 |
| `(+)` 구문형 OUTER JOIN | 지원(J18) | **미지원** — `LEFT JOIN`으로 대체 | 문법만 다르고 결과(9행)는 같다 |
| `FULL OUTER JOIN` | ANSI 문법 지원 | ANSI 문법 지원 | 둘 다 동일 |
| 재실행을 위한 DROP | `DROP TABLE x;`(없으면 최초 실행 시 에러, 무시하고 진행) | `IF OBJECT_ID('x','U') IS NOT NULL DROP TABLE x;` | 관례 차이 |
| 테이블 별칭 뒤 원본 테이블명 사용 | 오류(J22 주석 참고) | 오류(J22 주석 참고) | 동일 |

## 필기 vs 실기 연결

- 필기의 "값별 매칭 횟수를 곱해서 합산" 규칙(J09, J23)은 SQL에서
  `INNER JOIN`이 곱집합에서 조건을 만족하는 조합만 남기는 것과 동일한
  현상이다 — `03_verify.sql`의 상관 서브쿼리로 값별 매칭 횟수를 직접
  풀어서 재확인한다.
- 필기의 "OUTER JOIN 뒤 WHERE가 미일치 행을 제거한다"(J19)는 실제로
  `LEFT JOIN` 다음에 오른쪽 테이블 조건을 WHERE에 쓰면 왜 위험한지를
  `member`/`contact` 데이터로 직접 보여준다.
- 필기의 "USING/NATURAL/`(+)`" 세 문법은 Oracle 스크립트에서 그대로 실행되고,
  SQL Server 스크립트에서는 "지원하지 않는다"는 주석과 함께 ON 동등 구문으로
  대체된다 — 두 스크립트의 `expected_numeric_value`는 항상 같아야 한다.

## 검증 테이블

`sql_example_expectation` / `sql_example_result` / `sql_example_validation`
세 테이블의 논리 스키마는 [`../_common/validation_schema.sql`](../_common/validation_schema.sql)
참고. 이 폴더의 `01_prepare.sql`이 각 DBMS 방언으로 실제 CREATE TABLE 문을
만든다.

## Python 검증 방식

`02_validate.py`는 `../_common/db_helpers.py`를 그대로 가져다 쓴다.

- `ORACLE_DSN` / `ORACLE_USER` / `ORACLE_PASSWORD` 가 모두 설정돼 있고
  `python-oracledb`가 설치돼 있으면 Oracle에 연결해 실제 `sql_example_result`를
  읽어 `_common/expected_results.csv`와 비교한다.
- `SQLSERVER_CONNECTION_STRING` 이 설정돼 있고 `pyodbc`가 설치돼 있으면
  SQL Server에 연결해 같은 방식으로 비교한다.
- 둘 다 연결에 실패하면 **정적 검증 모드**로 전환한다 — `02_examples.sql`
  안에 각 `example_id`가 실제로 작성돼 있는지만 텍스트로 확인하고, "실제
  실행 결과와 비교했다"고 절대 주장하지 않는다.
- 모델 학습은 수행하지 않는다.

## 실제 DB 실행 여부

**이 세션에는 Oracle과 SQL Server 실행 환경이 없다.** 대신 이 폴더의 24개
예제와 동일한 데이터·동일한 쿼리 로직을 SQLite(3.45, `FULL OUTER JOIN`/
`USING`/`NATURAL JOIN` 지원)로 이 세션에서 **실제로 실행**해 `expected_row_count`/
`expected_numeric_value`가 전부 일치함을 확인했다(J01~J23, J13B, J21B 총 24건
전부 PASS). SQLite는 Oracle의 `(+)`와 `DUAL`, SQL Server의 `IF OBJECT_ID`
DROP 관용구를 그대로 갖고 있지 않으므로, J18은 `(+)` 대신 `LEFT JOIN` 동치
쿼리로 검증했다 — 문법이 아니라 **결과값**만 대조한 것이다. Oracle/SQL
Server 고유 문법(USING, NATURAL JOIN, `(+)`, `SYSDATE`/`GETDATE()` 등)
자체의 실제 실행은 여전히 미검증이며, `02_validate.py`를 실제 Oracle/SQL
Server에 연결해 돌린 적도 없다. 실제 환경에서 실행하려면:

```bash
export ORACLE_DSN=...
export ORACLE_USER=...
export ORACLE_PASSWORD=...
python3 02_validate.py --dbms oracle

export SQLSERVER_CONNECTION_STRING="DRIVER={ODBC Driver 18 for SQL Server};..."
python3 02_validate.py --dbms sqlserver
```

## 재현성

- 모든 예제 데이터는 고정 INSERT 문이다(임의 생성 없음).
- `01_prepare.sql`은 재실행 시 기존 객체를 모두 DROP 후 재생성한다.
- `02_examples.sql`은 `DELETE FROM sql_example_result WHERE example_id LIKE 'J%'`로
  시작해, 여러 번 실행해도 결과가 중복 적재되지 않는다.
- `example_id`는 이 문서의 표와 동일하게 고정돼 있으며 실행마다 바뀌지 않는다.
