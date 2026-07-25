---
type: technique
pilot: true
category: 전처리
---

# 데이터 전처리와 변수 변환

## 필기 공식

- 결측치 대체(imputation): 평균/중앙값 대체, 그룹별 대체 등
- 이상치 처리(winsorize/capping): 백분위수(예: 5%, 95%) 밖의 값을 경계값으로 잘라냄
- 표준화(Z-score): `z = (x - μ) / σ` — 평균 0, 표준편차 1
- 정규화(Min-Max): `x' = (x - min) / (max - min)` — 0~1 범위로 변환
- 로그 변환: `x' = log(x+1)` — 오른쪽 꼬리가 긴(양의 왜도) 분포를 정규분포에 가깝게 완화
  (주의: 이미 이상치 capping으로 대칭화된 데이터에 로그변환을 또 적용하면 오히려 왜도가
  나빠질 수 있다 — `03_verify.sql`에서 실제로 확인한다)
- 왜도(Skewness): `E[(x-μ)³] / σ³` — 0에 가까울수록 좌우 대칭
- 구간화(Binning/Discretization): 연속형 변수를 범주형 구간으로 변환
- 범주형 인코딩: 원-핫 인코딩(더미변수), 레이블 인코딩

## 이번 실습의 분석 단위

`raw_customer_intake`는 결측치(6%), 이상치(소득 12배 부풀림, 나이 150세), 성별 표기
불일치(`M`/`F`/`male`/`Female`/`NULL`), 날짜 형식 불일치(`YYYY-MM-DD` vs `YYYY/MM/DD`)가
의도적으로 섞인 "지저분한" 원본이다.

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 중앙값·백분위수 계산(윈도우 함수), 결측치 대체, 이상치 capping, 범주 표기 통일, 날짜 형식 통일 |
| Python (`02_analyze.py`) | SQL이 정제한 데이터에 Z-score·Min-Max·로그변환·구간화·원-핫 인코딩 적용(`sklearn.preprocessing`) |
| SQL (`03_verify.sql`) | 전/후 결측치·이상치 개수 비교, 표준화 후 평균/분산 검산, 왜도 비교 |

## DBMS별 SQL 차이 (중앙값/백분위수)

| DBMS | 중앙값·백분위수 |
|---|---|
| Oracle | `MEDIAN(x)`, `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY x)` |
| SQL Server | `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY x) OVER()` |
| SQLite | 내장 함수 없음 → `ROW_NUMBER() OVER(ORDER BY x)` + `COUNT() OVER()`로 순위를 매겨 직접 계산 |

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| Z-score 표준화 | `sklearn.preprocessing.StandardScaler` |
| Min-Max 정규화 | `sklearn.preprocessing.MinMaxScaler` |
| 로그 변환 | `numpy.log1p(x)` |
| 구간화 | `sklearn.preprocessing.KBinsDiscretizer` / `pandas.cut` |
| 원-핫 인코딩 | `pandas.get_dummies` / `sklearn.preprocessing.OneHotEncoder` |
| R 대응 | `scale()`, `cut()`, `model.matrix(~gender)` |
