---
type: technique
pilot: true
category: 시계열
---

# AR · MA · ARMA · ARIMA

## 필기 공식

- AR(p) (자기회귀): `y_t = c + φ1·y_{t-1} + ... + φp·y_{t-p} + ε_t` — 과거 자기 자신의 값으로 현재를 설명
- MA(q) (이동평균 과정): `y_t = c + ε_t + θ1·ε_{t-1} + ... + θq·ε_{t-q}` — 과거 오차(충격)로 현재를 설명
- ARMA(p,q): AR과 MA를 결합
- ARIMA(p,d,q): 비정상(non-stationary) 시계열을 `d`번 차분(Integrated)해 정상화한 뒤 ARMA(p,q) 적용
  - `d=1`: 1차 차분 `Δy_t = y_t - y_{t-1}`
- 정상성(Stationarity): 평균·분산이 시간에 따라 일정해야 ARMA류 모형을 적용할 수 있다
  (추세·계절성이 있으면 비정상 → 차분으로 제거)
- 모형 비교 기준: AIC(Akaike Information Criterion)가 작을수록 상대적으로 적합한 모형

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 시간순 데이터, 1차 차분(`diff1`), 시차(lag1/lag2) 컬럼을 윈도우 함수로 생성 |
| Python (`02_analyze.py`) | AR(1)/MA(1)/ARMA(1,1)/ARIMA(1,1,1) 각각 적합해 AIC 비교, 최종모형으로 6개월 예측 |
| SQL (`03_verify.sql`) | 모형별 AIC 순위 조회, 예측오차와 잔차의 시차상관(자기상관) 확인 |

## DBMS별 SQL 차이

`LAG()` 윈도우 함수는 Oracle/SQL Server/SQLite(3.25+) 모두 동일한 문법을 지원한다.

| DBMS | 차분/시차 |
|---|---|
| Oracle | `sales - LAG(sales) OVER (ORDER BY month_id)` |
| SQL Server | 동일 |
| SQLite | 동일 (3.25+) |

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| AR(1) | `statsmodels.tsa.arima.model.ARIMA(y, order=(1,0,0))` |
| MA(1) | `ARIMA(y, order=(0,0,1))` |
| ARMA(1,1) | `ARIMA(y, order=(1,0,1))` |
| ARIMA(1,1,1) | `ARIMA(y, order=(1,1,1))` |
| AIC 비교 | `model.aic` |
| R 대응 | `arima(y, order=c(1,1,1))`, `auto.arima(y)` |
