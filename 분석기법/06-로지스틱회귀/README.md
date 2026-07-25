---
type: technique
pilot: true
category: 지도학습-분류
---

# 로지스틱 회귀

## 필기 공식

- 오즈(Odds): `p / (1-p)`
- 로짓(Logit) 변환: `ln(p / (1-p)) = β0 + β1X1 + ... + βpXp`
- 확률 예측: `p = 1 / (1 + e^-(β0+β1X1+...))`
- 오즈비(Odds Ratio): `EXP(β)` — Xⱼ가 1 증가할 때 오즈가 몇 배가 되는지
  - `EXP(β) > 1` → 해당 변수가 커질수록 사건(예: 이탈) 발생 오즈 증가
  - `EXP(β) < 1` → 오즈 감소
- 추정: 최대우도추정(MLE), OLS의 정규방정식이 아님

## 이번 실습의 분석 단위

`customer_labels.churned`(이탈 여부, 0/1)를 종속변수로, 최근성(recency)·만족도·주문건수·
가입기간을 독립변수로 사용한다.

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 분석 테이블 구성, 이탈률(기저율) 요약 |
| Python (`02_analyze.py`) | `statsmodels.Logit`으로 계수·z검정·p-value 추정, 오즈비(`EXP(β)`)·예측확률 산출 |
| SQL (`03_verify.sql`) | `EXP(β)`를 SQL `EXP()` 함수로 재계산해 Python 오즈비와 대조, 혼동행렬 집계 |

## DBMS별 SQL 차이

| DBMS | 지수함수 |
|---|---|
| Oracle | `EXP(x)` |
| SQL Server | `EXP(x)` |
| SQLite | `EXP(x)` (수학 함수 확장이 켜진 최신 빌드에서 지원, 이 저장소 환경은 지원됨) |

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 로짓 β̂ | `statsmodels.Logit(y, X).fit().params` |
| z값, p-value | `.tvalues`(z), `.pvalues` |
| 오즈비 EXP(β) | `np.exp(params)` |
| 예측확률 p | `.predict(X)` |
| R 대응 | `glm(churned ~ ., data=df, family=binomial)`, `exp(coef(fit))` |
