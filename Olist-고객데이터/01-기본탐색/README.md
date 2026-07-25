---
type: exercise-set
pilot: true
primary_dbms: [oracle, sqlserver]
---

# 01. 기본 탐색 (Oracle · SQL Server 중심)

`olist_customers_dataset.csv`(00-데이터사전 근거, 99,441행) 5개 열만으로 수행하는
기본 탐색을 Oracle SQL과 SQL Server SQL로 각각 작성했다. 실제 CSV·자료형·통계는
`00-데이터사전/README.md`를 근거로 하며, 가짜 변수는 만들지 않는다.

## 파일 구성

| 단계 | Oracle | SQL Server | 다루는 내용 |
|---|---|---|---|
| 적재 후 탐색 | `02_explore_oracle.sql` | `02_explore_sqlserver.sql` | CSV 적재 DDL, ID 자료형·유일성, zip 문자형 보존, 도시·주별 고객수, 중복(재구매) 탐색 |
| 문자열 정제 | `03_clean_oracle.sql` | `03_clean_sqlserver.sql` | TRIM/LOWER 멱등성 검증 |
| 인코딩·통합 | `04_encode_oracle.sql` | `04_encode_sqlserver.sql` | 레이블 인코딩, 희소 범주 통합 |
| 순위·편중도 | `05_rank_oracle.sql` | `05_rank_sqlserver.sql` | RANK, 누적비율(파레토), HHI |
| fold 생성 | `06_fold_oracle.sql` | `06_fold_sqlserver.sql` | customer_unique_id 기준 5-fold, leakage 검증 |
| NULL 데모 | `08_null_behavior_demo_oracle.sql` | `08_null_behavior_demo_sqlserver.sql` | **합성 테스트 테이블**(실제 Olist 데이터 아님)로 `''` vs `NULL` 차이 시연 |

`01_load.py`, `07_verify_with_python.py`는 보조 실행 트랙(SQLite)을 위한 Python
스크립트로 그대로 유지한다. 기존 SQLite 전용 SQL(`02_explore_basic.sql` 등)은
`optional/`로 옮겼다 — 더 이상 기준 자료가 아니라 보조 검증용이다.

## CSV 실제 적재 방법 — 문법 예시일 뿐, 이 환경에서 실행하지 않음

- Oracle: `SQL*Loader`(`sqlldr` + 제어파일) 또는 외부 테이블(`ORACLE_LOADER`).
  `02_explore_oracle.sql` 상단에 제어파일 예시를 주석으로 남겼다.
- SQL Server: `BULK INSERT` 또는 `bcp` 유틸리티. `02_explore_sqlserver.sql` 상단에
  예시를 남겼다.

두 방식 모두 **이 세션에서 실행 검증하지 않았다.** 실제 사용 시 파일 경로·권한·문자셋을
환경에 맞게 조정해야 한다.

## 핵심 발견 — Oracle과 SQL Server 관점

- **우편번호 캐스팅 위험은 두 DBMS 모두 동일하게 발생한다.** zip 접두사를 정수로
  캐스팅했다가 문자열로 되돌리면 `0`으로 시작하는 23,995건(전체의 24.1%, 00-데이터사전
  근거)에서 선행 0이 사라진다 — Oracle `TO_NUMBER`/`TO_CHAR` 라운드트립과 SQL Server
  `CAST AS INT`/`CAST AS VARCHAR` 라운드트립 모두에서 같은 사고가 난다.
- **집계 후 나눗셈에서 SQL Server만 정수 나눗셈을 조심해야 한다.** `05_rank_sqlserver.sql`의
  HHI·누적비율 계산에 `1.0 *`을 넣은 이유가 이것이다. Oracle `NUMBER`는 이 문제가 없다
  (`필기계산문제-멀티DBMS/문제04` 참고).
- **`''`과 `NULL`을 같은 것으로 취급해도 되는 DBMS는 Oracle뿐이다.** 실제 Olist 데이터에는
  결측이 없어 이 차이가 드러나지 않으므로, `08_null_behavior_demo_*.sql`에 **별도의
  작은 합성 테이블**을 만들어 명확히 표시했다 — 실제 데이터에 결측이 있다고 거짓으로
  적지 않는다.
- **CTAS 문법 자체가 다르다.** Oracle은 `CREATE TABLE x AS SELECT ...`, SQL Server는
  `SELECT ... INTO x FROM ...`로 테이블 생성과 데이터 채우기를 한 문장에 표현하는
  방식이 다르다(`06_fold_*.sql`에서 직접 비교).
- **인코딩·통합 단계(04)는 두 DBMS 사이에 실질적 차이가 거의 없다** — `DENSE_RANK() OVER`,
  `CASE WHEN` 기반 `GROUP BY`는 두 DBMS에서 문법이 동일하다(상위 N행 문법만 `FETCH
  FIRST`/`TOP`으로 다름). 모든 단계에서 차이가 나는 것은 아니라는 점도 정직하게 기록한다.

## 실행

```bash
# Oracle: 02_explore_oracle.sql ~ 08_null_behavior_demo_oracle.sql을
#         Oracle SQL Developer 등에 순서대로 복사해 실행 (이 저장소에서 실행 불가)
# SQL Server: *_sqlserver.sql을 SSMS 등에 순서대로 복사해 실행 (이 저장소에서 실행 불가)

# 보조 실행(SQLite, 이 저장소에서 바로 가능):
python3 01_load.py
python3 ../_lib/run_sql.py olist.db optional/02_explore_basic.sql
python3 ../_lib/run_sql.py olist.db optional/03_clean_and_normalize.sql
python3 ../_lib/run_sql.py olist.db optional/04_encode_and_consolidate.sql
python3 ../_lib/run_sql.py olist.db optional/05_rank_cumulative_concentration.sql
python3 ../_lib/run_sql.py olist.db optional/06_sampling_and_fold.sql
python3 07_verify_with_python.py
```
