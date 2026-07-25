---
type: technique
pilot: true
category: 지도학습-회귀
---

# 선형회귀 · 다중회귀

## 필기 공식

- 단순선형회귀: `Y = β0 + β1X + ε`
- 다중회귀: `Y = β0 + β1X1 + β2X2 + ... + βpXp + ε`
- 최소제곱추정(OLS): `β̂ = (XᵀX)⁻¹XᵀY`
- 결정계수: `R² = 1 - SS_res / SS_tot` (`SS_res = Σ(yᵢ-ŷᵢ)²`, `SS_tot = Σ(yᵢ-ȳ)²`)
- 수정된 결정계수: `Adj R² = 1 - (1-R²)(n-1)/(n-p-1)` (변수 개수 페널티)
- 회귀계수 유의성 검정: `t = β̂ⱼ / SE(β̂ⱼ)`, 귀무가설 `H0: βⱼ = 0`
- 범주형 변수는 더미변수(가변수)로 변환해 투입 (기준범주 하나는 제외)

## 이번 실습의 분석 단위

고객별 `next_month_spend`(다음달 예상 지출)를 종속변수로, 평균주문액·주문건수·가입기간·
연소득·나이·만족도·최근성(recency)을 독립변수로 사용한다. 가입기간을 구간화한
`membership_tier`(신규/일반/우수)를 더미변수로 추가해 범주형 변수 처리도 함께 다룬다.

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 분석 테이블 구성, `membership_tier` 더미변수 생성, 변수별 요약통계(평균/표준편차/최소/최대) 산출 |
| Python (`02_analyze.py`) | `statsmodels.OLS`로 계수 추정과 t검정·p-value 산출, 예측값·잔차 저장 |
| SQL (`03_verify.sql`) | 유의한(p<0.05) 변수 조회, R²를 SQL로 직접 재계산해 Python 결과와 대조, 잔차 상위 이상치 조회 |

## DBMS별 SQL 차이 (CASE 기반 더미변수)

| DBMS | 구간화·더미변수 |
|---|---|
| Oracle | `CASE WHEN`, 또는 `DECODE(tier, '신규', 1, 0)` |
| SQL Server | `CASE WHEN`, `IIF(tier='신규', 1, 0)` |
| SQLite | `CASE WHEN` 만 지원 (DECODE/IIF 없음) — 이 실습은 `CASE WHEN`으로 통일 |

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| β̂ = (XᵀX)⁻¹XᵀY | `statsmodels.api.OLS(y, X).fit()` |
| R², Adj R² | `model.rsquared`, `model.rsquared_adj` |
| t값, p-value | `model.tvalues`, `model.pvalues` |
| 예측값 ŷ | `model.predict(X)` |
| R 대응 | `lm(next_month_spend ~ ., data=df)`, `summary(fit)` |
