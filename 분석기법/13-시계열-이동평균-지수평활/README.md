---
type: technique
pilot: true
category: 시계열
---

# 시계열: 이동평균 · 지수평활

## 필기 공식

- 이동평균(Moving Average, n기간): `MA_t = (y_t + y_{t-1} + ... + y_{t-n+1}) / n`
  - 노이즈를 완화해 추세를 보기 쉽게 하지만, 항상 `n-1`기간만큼 뒤처져 반응
- 단순지수평활(SES): `S_t = α·y_t + (1-α)·S_{t-1}` (`0<α<1`)
  - `α`가 클수록 최근 값에 민감(반응 빠름), 작을수록 과거값을 더 반영(평활 강함)
  - 추세·계절성이 없는 시계열에 적합
- 이중지수평활(Holt, 추세 반영): 수준(level) `Lt`와 추세(trend) `Tt`를 함께 평활
  - `L_t = α·y_t + (1-α)(L_{t-1}+T_{t-1})`
  - `T_t = β·(L_t - L_{t-1}) + (1-β)·T_{t-1}`

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 시간순 정렬, 윈도우 함수로 3개월·6개월 이동평균과 전월 대비(lag) 컬럼 생성 |
| Python (`02_analyze.py`) | `statsmodels`의 `SimpleExpSmoothing`(SES), `Holt`(추세) 적합, 6개월 예측 |
| SQL (`03_verify.sql`) | SQL 이동평균과 Python 예측 결과를 함께 조회, 이동평균의 예측오차(MAE) 계산 |

## DBMS별 SQL 차이 (이동평균 윈도우 함수)

| DBMS | 이동평균 구문 |
|---|---|
| Oracle | `AVG(sales) OVER (ORDER BY month_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)` |
| SQL Server | 동일 구문 지원 (`ROWS BETWEEN ... PRECEDING AND CURRENT ROW`) |
| SQLite | 3.25+ 부터 동일 구문 지원 — 이 실습 그대로 사용 가능 |

세 DBMS 모두 문법이 사실상 동일해, 이 실습에서는 차이보다 "윈도우 프레임(ROWS BETWEEN)"
개념 자체를 확인하는 데 집중한다. ([[윈도우 함수]] 개념 노트 참고)

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 이동평균 MA_t | SQL `AVG() OVER(...)` — Python은 검산용으로만 `pandas.rolling(n).mean()` 사용 |
| 단순지수평활 | `statsmodels.tsa.holtwinters.SimpleExpSmoothing(y).fit(smoothing_level=α)` |
| 이중지수평활(Holt) | `statsmodels.tsa.holtwinters.Holt(y).fit()` |
| R 대응 | `HoltWinters(ts, gamma=FALSE)`, `forecast::ses()`, `forecast::holt()` |
