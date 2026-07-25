---
type: index
pilot: true
---

# 필기 계산문제 × 멀티 DBMS 체험

이 폴더는 저장소의 최종 목표 중 앞의 두 조각을 담당한다.

> "빅데이터분석기사 필기의 계산형 예상문제를 SQL로 재현하고,
> Oracle·SQL Server·MySQL·DuckDB의 문법과 결과 차이를 체험하며, ..."

`분석기법/`이 실기 범위 통계·머신러닝 기법을 SQL→Python→SQL 검산으로 다루고,
`Olist-고객데이터/`가 실데이터 전처리·집계를 다뤘다면, 이 폴더는 **필기에서 손으로
풀던 계산 문제를 SQL 쿼리로 다시 풀고, 그 SQL이 DBMS마다 실제로 다르게 동작하는
지점**을 정직하게 확인하는 역할을 맡는다.

## 이 세션에서 실제로 실행 가능한 엔진

| 엔진 | 상태 | 방법 |
|---|---|---|
| SQLite | 항상 가능 | Python 표준 라이브러리 |
| DuckDB | 가능 | `pip install duckdb` (이 세션에서 설치·검증함) |
| MariaDB(MySQL 호환) | 가능 | `apt-get install mariadb-server` + `service mariadb start` (이 세션에서 설치·기동·검증함, `_engine/setup_mariadb.sh` 참고) |
| Oracle | **불가능** | 상용 라이선스·이미지가 이 샌드박스에 없고, 인터넷/도커 데몬도 제한됨 |
| SQL Server | **불가능** | 위와 동일한 사유 |

Oracle·SQL Server는 각 문제 폴더 README의 문법 비교표에 **문헌 기준으로만** 싣는다.
실행한 것처럼 결과를 지어내지 않는다 — MySQL/MariaDB·DuckDB·SQLite 세 엔진은 실제로
실행해 같은 숫자가 나오는지까지 확인했고, Oracle·SQL Server는 "이런 문법을 쓴다"는
사실만 기록했다.

## 문제 목록

| # | 주제 | 필기 계산 포인트 | DBMS 차이 포인트 |
|---|---|---|---|
| 01 | 평균·분산·표준편차 | 모/표본 분산 공식 | `STDDEV`가 Oracle="표본", MySQL `STD`="모"로 반대 의미 |
| 02 | 피어슨 상관계수 | 공분산/표준편차 비율 | `CORR`은 Oracle·DuckDB만 내장, 나머지는 수식 직접 전개 |
| 03 | 단순선형회귀 정규방정식 | β0, β1 최소제곱 공식 | `REGR_SLOPE/INTERCEPT`는 Oracle·DuckDB만 내장 |
| 04 | 혼동행렬·정밀도·재현율·F1 | 혼동행렬 지표 공식 | **정수 나눗셈**: SQLite `3/4=0`, DuckDB/MariaDB `3/4=0.75` — 직접 실행해 확인 |
| 05 | 엔트로피·지니계수 | 의사결정나무 분할기준 공식 | 밑 없는 `LOG(x)`가 SQLite/DuckDB=log10, MariaDB=자연로그로 실제로 다름 |
| 06 | Z-score·Min-Max | 표준화/정규화 공식 | 파티션 없는 윈도우 함수(`OVER()`)로 행 단위 변환, SQLite는 STDDEV 수식 전개 |
| 07 | 문자열·날짜·상위N행·NULL | (문법 자체가 주제) | MariaDB `\|\|`가 결합이 아니라 논리 OR — 실행해서 확인 |

## 공통 인프라

- `_engine/engines.py` — SQLite/DuckDB/MariaDB 커넥션 팩토리 + 결과 출력 유틸.
  엔진이 없으면(설치 안 됨/서비스 미기동) 해당 엔진만 건너뛰고 나머지로 계속 진행한다.
- `_engine/setup_mariadb.sh` — MariaDB 설치부터 계정 생성까지, 이 세션에서 실제로 쓴
  순서 그대로.

## 실행

```bash
pip install duckdb pymysql
bash _engine/setup_mariadb.sh   # 최초 1회 (MariaDB 실습을 포함하려면)

for d in 문제01-* 문제02-* 문제03-* 문제04-* 문제05-* 문제06-* 문제07-*; do
  echo "=== $d ==="
  python3 "$d/run_compare.py"
done
```

`_engine`이 DuckDB나 MariaDB에 연결하지 못하면 해당 엔진 결과만 "[건너뜀]"으로 표시되고
SQLite 결과는 항상 나온다 — 즉 이 폴더는 세 엔진이 모두 없는 환경에서도 최소한 SQLite
기준으로는 전부 실행된다.

## 다음에 이어질 조각 (최종 목표의 나머지 부분)

최종 목표 문장의 나머지 절("Olist 고객 데이터를 중심으로 SQL 전처리·집계·분석 테이블을
구축한 뒤, 실기 범위의 통계·머신러닝 기법을 Python/R로 실행하고 그 결과를 다시 SQL로
검산하는")은 이미 `Olist-고객데이터/`와 `분석기법/`이 각자 담당하고 있다. 세 폴더가
합쳐져야 "통합 학습 환경"이 완성되며, 저장소 최상위 `README.md`가 그 지도 역할을 한다.
