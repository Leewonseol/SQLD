---
type: technique
pilot: true
category: 지도학습-회귀
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 선형회귀 · 다중회귀 — Oracle · SQL Server 중심

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
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | 분석 테이블 구성, `membership_tier` 더미변수 생성, 변수별 요약통계 산출 |
| Python (`02_analyze.py`) | `statsmodels.OLS`로 계수 추정과 t검정·p-value 산출, 예측값·잔차 저장 |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, 유의한(p<0.05) 변수 조회, R²를 SQL로 직접 재계산해 대조, 잔차 상위 이상치 조회 |

## Oracle SQL

[`01_prepare_oracle.sql`](./01_prepare_oracle.sql). 요약통계에 `STDDEV_POP`을 그대로
쓴다(SQLite 버전처럼 `E[x²]-E[x]²` 공식을 풀어 쓸 필요 없음).

## SQL Server SQL

[`01_prepare_sqlserver.sql`](./01_prepare_sqlserver.sql). `SELECT ... INTO`로 테이블을
만들고, `STDEVP`를 쓴다.

## 두 DBMS에서 같은 부분

- 더미변수 생성(`CASE WHEN`)은 Oracle과 SQL Server 문법이 완전히 동일하다 — 이
  단계는 실질적 차이가 없는 사례다. (Oracle은 `DECODE`, SQL Server는 `IIF`라는
  대안도 있지만 `CASE WHEN`이 둘 다에서 표준이라 굳이 대안을 쓸 필요가 없다.)
- 회귀계수·R² 값 자체는 두 DBMS에서 같다(같은 Python 모델 결과를 저장하므로 당연하다).

## 두 DBMS에서 다른 부분

- 요약통계 함수 이름(`STDDEV_POP`↔`STDEVP`), 테이블 생성 문법(`CREATE TABLE AS
  SELECT`↔`SELECT INTO`), 상위 N행(`FETCH FIRST`↔`TOP`) — 앞선 기법들과 동일한
  패턴의 반복이다.
- **R² 재계산 시 나눗셈 안전성**: `regression_predictions`의 `residual`/`actual`을
  Oracle은 `NUMBER`, SQL Server는 `FLOAT`로 선언했다. 둘 다 이 컬럼들이 이미 실수형이라
  `필기계산문제-멀티DBMS/문제04`의 정수 나눗셈 문제는 발생하지 않지만, `COUNT(*)`가
  섞이는 계산에서는(예: 표본크기로 나누는 식) SQL Server에서 여전히 주의가 필요하다.

## SQLD 출제 함정

- 더미변수의 **기준범주(reference category)** 를 빠뜨리는 것이 흔한 실수다. 이 실습은
  `membership_years < 2`(신규)를 기준범주로 남기고 `tier_general`/`tier_premium` 두
  더미만 투입한다 — 세 범주를 모두 더미로 넣으면 다중공선성(더미변수 함정)이 생긴다는
  점을 SQL 단계에서부터 명확히 해야 한다.

## 실행

```bash
# Oracle: 01_prepare_oracle.sql, 03_verify_oracle.sql을 Oracle 환경에 복사해 실행 (이 저장소에서 실행 불가)
# SQL Server: *_sqlserver.sql을 SQL Server 환경에 복사해 실행 (이 저장소에서 실행 불가)
python3 02_analyze.py

# 보조(SQLite, 이 저장소에서 실제 실행 확인됨):
python3 ../_data/run_sql.py optional/01_prepare_sqlite.sql
python3 02_analyze.py
python3 ../_data/run_sql.py optional/03_verify_sqlite.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| β̂ = (XᵀX)⁻¹XᵀY | `statsmodels.api.OLS(y, X).fit()` |
| R², Adj R² | `model.rsquared`, `model.rsquared_adj` |
| t값, p-value | `model.tvalues`, `model.pvalues` |
| 예측값 ŷ | `model.predict(X)` |
| R 대응 | `lm(next_month_spend ~ ., data=df)`, `summary(fit)` |
