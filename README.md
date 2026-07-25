# SQLD

SQL개발자(SQLD)·빅데이터분석기사 시험 대비용 개념·기출·오답 노트 및 통합 실습 저장소.
**이 저장소의 주 학습 대상은 Oracle과 SQL Server다.** DuckDB·MariaDB(MySQL 호환)·
SQLite는 실제로 돌려서 결과를 비교·검증하는 보조 엔진이며, 학습자료의 기준이 아니다.

## 1. Oracle과 SQL Server를 비교하는 이유

SQLD(SQL개발자)와 빅데이터분석기사 실기가 실제로 다루는 DBMS는 Oracle과 SQL Server다.
두 DBMS는 NULL 처리, 문자열·숫자·날짜 함수, 형변환, 행 제한 문법, 집합·계층 연산,
트랜잭션 방식이 이름만 다른 게 아니라 **의미와 결과가 달라지는 지점**이 있다
(`Concepts/DBMS 문법 차이(Oracle-SQLServer).md` 참고). 이 저장소는 "SQLite에서 실행한
결과를 Oracle에서도 비슷할 것"이라고 뭉뚱그리지 않고, 각 분석기법·계산문제마다 Oracle
SQL과 SQL Server SQL을 **따로** 작성해 그 차이가 실제 계산 결과에 어떻게 반영되는지
보여준다.

## 2. 빅분기 계산형 문제를 두 DBMS에서 푸는 방법

[`필기계산문제-멀티DBMS/`](./필기계산문제-멀티DBMS/README.md) — 평균·분산·표준편차,
피어슨 상관계수, 단순선형회귀, 혼동행렬·F1, 엔트로피·지니계수, Z-score·Min-Max,
문자열·날짜·NULL 문법 등 7개 계산형 예상문제를 손계산 → Oracle SQL → SQL Server SQL
순서로 재현한다. 각 문제 README는 "Oracle 예상 결과 / SQL Server 예상 결과 / 두 DBMS가
같은 부분 / 다른 부분 / SQLD 출제 함정"을 명시한다.

## 3. 분석기법별 SQL 준비·검산 구조

[`분석기법/`](./분석기법/README.md) — PCA·회귀·로지스틱회귀·SVM·트리·랜덤포레스트·
KNN·K-means·SVD/NMF·연관규칙·가설검정 등 20개 분석기법. 각 기법 폴더는 다음 구조를
쓴다(파일 수가 지나치게 많아지는 것을 피하기 위해 폴더를 나누는 대신 파일명으로
DBMS를 구분하는 방식을 택했다).

```
분석기법/NN-기법이름/
  README.md                   -- 필기 공식 + Oracle/SQL Server 역할 분담 + 같은점/다른점 + SQLD 함정
  01_prepare_oracle.sql        -- Oracle: 결측 처리, 표준화, 더미변수 등 분석 테이블 준비
  01_prepare_sqlserver.sql     -- SQL Server: 동일 작업의 SQL Server 버전
  02_analyze.py                -- Python: 모델 학습(sklearn/statsmodels), 결과를 DB에 저장
  03_verify_oracle.sql         -- Oracle: 결과 테이블 DDL + 계수·지표 검산 쿼리
  03_verify_sqlserver.sql      -- SQL Server: 동일 검산의 SQL Server 버전
  optional/
    01_prepare_sqlite.sql      -- 보조: 이 저장소에서 실제로 실행 확인된 SQLite 버전
    03_verify_sqlite.sql
```

**진행 상황**: 20개 기법 중 13개(`01-PCA`, `02-SVD-NMF`, `05-회귀분석`, `06-로지스틱회귀`,
`07-SVM`, `08-의사결정나무`, `09-랜덤포레스트`, `10-KNN`, `11-Kmeans`, `15-교차검증`,
`17-모델평가지표`, `18-가설검정`, `19-연관규칙`)를 이 구조로 전환했다. 나머지 7개
(`03-요인분석`, `04-MDS`, `12-계층적군집분석`, `13-시계열-이동평균-지수평활`,
`14-ARIMA`, `16-하이퍼파라미터탐색`, `20-데이터전처리와변수변환`)는 아직 기존
SQLite 전용 `01_prepare.sql`/`03_verify.sql` 구조 그대로이며, 같은 패턴으로 전환이
필요하다(하단 "미구현 항목" 참고).

### Oracle/SQL Server NULL 문법의 핵심 실습: kNN 결측값 대체

NULL 관련 함수·빈 문자열 차이를 단순 나열하는 대신,
[`22-KNN결측값대체/`](./분석기법/22-KNN결측값대체/README.md) 하나의 모듈에
통합했다. 저장소 루트의 `잠재프로파일 결측값에 대한 논문.pdf`(잠재프로파일
분석에서 결측값 처리를 위한 최근접이웃 대체법의 활용)를 근거로, 결측 식별 →
`NVL`/`NVL2`/`COALESCE`/`NULLIF`(Oracle) vs `ISNULL`/`COALESCE`/`NULLIF`
(SQL Server) 비교 → 평균/중앙값 베이스라인 대체 → 유클리드 거리·
`k=round(sqrt(n))` 규칙 기반 kNN 대체까지 10단계로 SQL(Oracle/SQL Server)과
Python 양쪽에서 구현하고, 20행 합성 데이터로 SQLite에서 실제 실행·검증했다.
`10-KNN`(분류 알고리즘)과는 다른 모듈이며 서로 대체하지 않는다.

## 4. DBMS별 실행 방법

| 순위 | 엔진 | 실행 방법 |
|---|---|---|
| 1 | **Oracle** | `*_oracle.sql`을 Oracle SQL Developer, Oracle Free(23ai) 등에 복사해 실행 |
| 2 | **SQL Server** | `*_sqlserver.sql`을 SSMS, Azure Data Studio 등에 복사해 실행 |
| 3 | 표준 SQL/공통 계산 로직 | 각 README의 공식·손계산이 Oracle/SQL Server 공통 기준 |
| 4 | DuckDB / MariaDB / SQLite | `optional/`(분석기법) 또는 `run_compare.py`(계산문제)로 이 저장소에서 바로 실행 |

```bash
# 분석기법 예시 (01-PCA)
cd 분석기법/01-PCA
# Oracle/SQL Server는 각 환경에 SQL 파일을 복사해 실행(아래는 보조 SQLite 실행)
python3 ../_data/run_sql.py optional/01_prepare_sqlite.sql
python3 02_analyze.py
python3 ../_data/run_sql.py optional/03_verify_sqlite.sql

# 필기계산문제 예시 (문제01)
cd 필기계산문제-멀티DBMS/문제01-평균분산표준편차
python3 run_compare.py   # SQLite/DuckDB/MariaDB 보조 실행 비교
```

## 5. 실제 실행된 환경과 미실행 환경

이 세션에서 실제로 조사·실행한 결과:

| 엔진 | 상태 |
|---|---|
| SQLite | 실행 확인됨 (Python 표준 라이브러리) |
| DuckDB | 실행 확인됨 (`pip install duckdb`) |
| MariaDB(MySQL 호환) | 실행 확인됨 (`apt-get install mariadb-server` + `service mariadb start`) |
| **Oracle** | **미실행** — 상용 라이선스, 이 샌드박스에 설치 불가 |
| **SQL Server** | **미실행** — 상용 라이선스, 이 샌드박스에 설치 불가 |

Docker 데몬은 이 세션에서 실제로 기동에 성공했지만, Docker Hub 이미지 pull이 조직
egress 정책으로 차단되어(`production.cloudfront.docker.com`에서 403) Oracle/SQL Server
컨테이너를 받아올 수 없었다 — 재시도하지 않고 그대로 보고한다(`/root/.ccr/README.md`
지침). 따라서 이 저장소의 모든 `*_oracle.sql`/`*_sqlserver.sql`은 **문법·공식 기준으로
작성한 미검증 스크립트**이며, 각 파일·README에 "실제 Oracle 검증 필요" /
"실제 SQL Server 검증 필요"라고 명시했다. 실제 결과가 다를 수 있으니, 실기 대비
목적으로 쓸 때는 실제 Oracle/SQL Server 환경에서 재검증을 권장한다.

## 6. SQLD에서 중요한 결과 차이 목록 (이 저장소에서 실제로 도출한 것)

- **정수 나눗셈**: SQL Server(`INT/INT`)와 SQLite는 나눗셈을 정수로 자르지만
  (`3/4=0`), Oracle(`NUMBER`)과 DuckDB/MariaDB는 자동으로 실수 승격한다 —
  `필기계산문제-멀티DBMS/문제04`, `분석기법/06-로지스틱회귀` 등에서 반복 확인.
- **빈 문자열과 NULL**: Oracle은 `''`를 NULL로 저장하지만(`IS NULL`→TRUE), SQL Server는
  `''`과 NULL을 별개 값으로 구분한다(`IS NULL`→FALSE) — `필기계산문제-멀티DBMS/문제07`,
  `Olist-고객데이터/01-기본탐색/08_null_behavior_demo_*.sql`에서 실증.
- **`LOG` 함수 인수 순서**: Oracle은 `LOG(밑, 진수)`, SQL Server는 `LOG(진수, 밑)`로
  **정반대** — `필기계산문제-멀티DBMS/문제05`.
- **`GROUP BY`에 별칭 사용**: Oracle·SQL Server는 표준 SQL 규칙대로 SELECT 별칭을
  GROUP BY에 못 쓴다(SQLite/MySQL은 비표준 확장으로 허용) — `분석기법/06-로지스틱회귀`.
- **`ROWID`/`ROWNUM`의 함정**: Oracle `ROWID`는 물리주소라 산술 불가, SQL Server는
  `ROWID` 개념 자체가 없다 — 두 DBMS 모두 `ROW_NUMBER() OVER(ORDER BY ...)`로 대체해야
  한다 — `분석기법/07-SVM`, `08-의사결정나무`, `09-랜덤포레스트`, `10-KNN`, `15-교차검증`.
- **문법만 다르고 결과는 같은 경우**: `STDDEV_POP`↔`STDEVP` 등 통계함수 이름
  (`분석기법/01-PCA` 등 다수), `CREATE TABLE AS SELECT`↔`SELECT INTO`, `PIVOT` 구문
  세부표기(`분석기법/02-SVD-NMF`, `19-연관규칙`) — 이런 경우는 README에 "결과는 같다"고
  명시해 실제로 다른 경우와 구분했다.
- **Oracle 전용 제약**: `FROM` 없는 `SELECT` 불가(`DUAL` 필요) — `분석기법/17-모델평가지표`.

## 7. Olist 데이터 적용 방법

[`Olist-고객데이터/`](./Olist-고객데이터/README.md) — `olist_customers_dataset.csv`
하나만 사용하는 실데이터 실습. `01-기본탐색/`을 Oracle/SQL Server 중심으로 전환했다
(CSV 적재 DDL, ID 자료형, 우편번호 문자형 보존, 도시·주별 고객수, 중복 고객 탐색,
fold 생성 등). 실제 데이터에는 NULL이 없으므로, NULL 처리 차이를 보여주는
`08_null_behavior_demo_*.sql`은 **별도의 작은 합성 테스트 테이블**임을 명확히 표시했다.
`02-관계파일확인/`, `03-기법별적용/`은 아직 SQLite/실데이터 판정 중심 구조 그대로이며
Oracle/SQL Server 전환이 필요하다(하단 "미구현 항목" 참고).

## 저장소 구성

- `Concepts/` — SQL 개념 노트 (Zettelkasten 스타일). `DBMS 문법 차이(Oracle-SQLServer).md`가
  전체 저장소가 참조하는 Oracle/SQL Server 비교 기준.
- `Questions/` `Propositions/` — 모의고사 문항·선지 해설
- `_원본 자료/` — 원본 마인드맵·정리 자료
- `잠재프로파일 결측값에 대한 논문.pdf` — `분석기법/22-KNN결측값대체/`의 근거 논문
- `필기계산문제-멀티DBMS/` — 계산형 예상문제 7종, Oracle·SQL Server 중심 (§2)
- `Olist-고객데이터/` — 실데이터 SQL 전처리·집계, Oracle·SQL Server 중심 (§7)
- `분석기법/` — 분석기법 20종, SQL 준비→Python 학습→SQL 검산 (§3), 인공신경망 계열은
  `21-제외기법-인공신경망/`에 재검토 조건과 함께 보류. `22-KNN결측값대체/`는 20개
  목록 이후 추가된 모듈로, Oracle/SQL Server NULL 문법 차이를 kNN 결측값 대체
  실습으로 통합한다(`10-KNN` 분류와는 다른 모듈).

## 미구현 또는 추가 검증이 필요한 항목

- **분석기법 7종 미전환**: `03-요인분석`, `04-MDS`, `12-계층적군집분석`,
  `13-시계열-이동평균-지수평활`, `14-ARIMA`, `16-하이퍼파라미터탐색`,
  `20-데이터전처리와변수변환` — 기존 SQLite 전용 구조 그대로.
- **Olist 모듈 일부 미전환**: `02-관계파일확인/`, `03-기법별적용/`.
- **모든 `*_oracle.sql`/`*_sqlserver.sql`은 실제 Oracle/SQL Server 미검증** — 문법과
  공식 기준으로 작성했으며, 실제 실행 시 값이 다를 가능성을 배제할 수 없다.
- **Docker 기반 실제 Oracle/SQL Server 실행 환경**: egress 정책상 이 세션에서는
  구성할 수 없었다. 인터넷 제약이 없는 환경이라면 `gvenzl/oracle-free`,
  `mcr.microsoft.com/mssql/server` 공식 이미지로 재시도 가능하다.
