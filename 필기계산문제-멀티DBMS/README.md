---
type: index
pilot: true
---

# 필기 계산문제 × Oracle·SQL Server

이 폴더는 저장소의 최종 목표 중 앞의 두 조각을 담당한다.

> "빅데이터분석기사 필기의 계산형 예상문제를 SQL로 재현하고,
> Oracle·SQL Server·MySQL·DuckDB의 문법과 결과 차이를 체험하며, ..."

**SQLD의 핵심 대상은 Oracle과 SQL Server다.** 이 폴더의 모든 문제는 Oracle SQL과
SQL Server SQL을 나란히 작성하고, 두 DBMS의 NULL 처리·문자열·숫자·날짜 함수가 실제
계산 결과에 어떻게 반영되는지를 중심 결론으로 삼는다. DuckDB·MySQL(MariaDB)·SQLite는
그 결론을 실제로 실행해 보조 확인하는 용도로만 남겨둔다.

## 우선순위와 실행 가능 여부

| 순위 | 엔진 | 역할 | 이 세션에서 실행 가능한가 |
|---|---|---|---|
| 1 | **Oracle** | 학습의 기준 DBMS | **불가능** — 상용 라이선스, 이 샌드박스에 설치 불가. Docker 데몬은 기동되지만 Docker Hub 이미지 pull이 조직 egress 정책으로 차단됨(`production.cloudfront.docker.com`에서 403, `/root/.ccr/README.md` 기준 재시도하지 않음) |
| 2 | **SQL Server** | 학습의 기준 DBMS | **불가능** — 위와 동일한 사유 |
| 3 | 표준 SQL/공통 계산 로직 | 두 기준 DBMS의 공통분모 확인 | 해당 없음(개념적 기준) |
| 4 | DuckDB / MariaDB(MySQL 호환) / SQLite | 보조 실행·검증 | **가능** — 이 세션에서 실제로 설치·기동·실행해 확인함 |

Oracle·SQL Server SQL은 각 문제 폴더에 `oracle.sql`, `sqlserver.sql`로 완전한 스크립트
형태(DDL+INSERT+SELECT)로 존재하며, **실제 Oracle/SQL Server 환경에 그대로 복사해
실행할 수 있도록** 작성했다. 다만 이 세션에서는 실행하지 못했으므로 각 README에
"실제 Oracle 검증 필요" / "실제 SQL Server 검증 필요"라고 명시했다 — 실행한 것처럼
결과를 지어내지 않는다.

## 문제 목록

| # | 주제 | 필기 계산 포인트 | Oracle ↔ SQL Server 핵심 차이 |
|---|---|---|---|
| 01 | 평균·분산·표준편차 | 모/표본 분산 공식 | **문법만 다르고 결과는 같음**: `VAR_POP/VARIANCE/STDDEV_POP/STDDEV` ↔ `VARP/VAR/STDEVP/STDEV`, 둘 다 "이름 없는 기본형=표본" |
| 02 | 피어슨 상관계수 | 공분산/표준편차 비율 | Oracle `CORR` 내장, SQL Server는 정의식 직접 전개 |
| 03 | 단순선형회귀 정규방정식 | β0, β1 최소제곱 공식 | Oracle `REGR_SLOPE/INTERCEPT/R2` 내장, SQL Server는 정의식 직접 전개 |
| 04 | 혼동행렬·정밀도·재현율·F1 | 혼동행렬 지표 공식 | **결과 자체가 실제로 달라짐**: SQL Server `INT/INT`는 정수 나눗셈(`3/4=0`), Oracle `NUMBER`는 캐스팅 없이도 `0.75` |
| 05 | 엔트로피·지니계수 | 의사결정나무 분할기준 공식 | `LOG` 인수 순서가 **정반대**: Oracle `LOG(밑,진수)`, SQL Server `LOG(진수,밑)` — 순서를 바꾸면 값이 틀림 |
| 06 | Z-score·Min-Max | 표준화/정규화 공식 | 파티션 없는 `OVER()` 구조는 동일, 함수 이름만 `STDDEV_POP`↔`STDEVP` |
| 07 | 문자열·날짜·상위N행·NULL | (문법 자체가 주제) | **결과 자체가 실제로 달라짐**: Oracle은 `''`을 NULL로 저장(`IS NULL`→TRUE), SQL Server는 `''`과 NULL을 구분(`IS NULL`→FALSE) |

`04`, `07`은 단순 문법 차이를 넘어 **같은 논리의 SQL이 실제로 다른 숫자/판정**을
내는 사례이고, `01`, `06`은 함수 이름만 다를 뿐 결과는 동일한 사례다 — 이 구분을
각 문제 README의 "8. 같은 부분 / 9. 다른 부분" 절에서 명시한다.

## 각 문제 폴더 구성

```
문제NN-주제/
  README.md       -- 12절 구성: 필기문제→손계산→공통입력→Oracle SQL→SQL Server SQL→
                      Oracle 예상결과→SQL Server 예상결과→같은 점→다른 점→SQLD 함정→
                      Python/R 대응→보조 DBMS 실행결과
  oracle.sql       -- Oracle 전용 완전한 스크립트 (DDL+INSERT+SELECT), 미실행·검증 필요
  sqlserver.sql    -- SQL Server 전용 완전한 스크립트, 미실행·검증 필요
  run_compare.py   -- 보조 DBMS(SQLite/DuckDB/MariaDB) 실제 실행 스크립트 (이 세션에서 실행 확인됨)
```

## 보조 DBMS 인프라 (SQLite·DuckDB·MariaDB)

- `_engine/engines.py` — SQLite/DuckDB/MariaDB 커넥션 팩토리 + 결과 출력 유틸.
- `_engine/setup_mariadb.sh` — MariaDB 설치부터 계정 생성까지, 이 세션에서 실제로 쓴 순서.

## 실행

```bash
# 1순위: Oracle (권장) — oracle.sql을 Oracle SQL Developer, Oracle Free(23ai) 등에 복사해 실행
# 2순위: SQL Server (권장) — sqlserver.sql을 SSMS, Azure Data Studio 등에 복사해 실행

# 4순위: 보조 검증(DuckDB/MariaDB/SQLite) — 이 저장소에서 바로 실행 가능
pip install duckdb pymysql
bash _engine/setup_mariadb.sh   # 최초 1회 (MariaDB 보조 실습을 포함하려면)

for d in 문제01-* 문제02-* 문제03-* 문제04-* 문제05-* 문제06-* 문제07-*; do
  echo "=== $d ==="
  python3 "$d/run_compare.py"
done
```

## 다음에 이어질 조각 (최종 목표의 나머지 부분)

최종 목표 문장의 나머지 절("Olist 고객 데이터를 중심으로 SQL 전처리·집계·분석 테이블을
구축한 뒤, 실기 범위의 통계·머신러닝 기법을 Python/R로 실행하고 그 결과를 다시 SQL로
검산하는")은 `Olist-고객데이터/`와 `분석기법/`이 같은 Oracle·SQL Server 중심 구조로
담당한다. 세 폴더가 합쳐져야 "통합 학습 환경"이 완성되며, 저장소 최상위 `README.md`가
그 지도 역할을 한다.
