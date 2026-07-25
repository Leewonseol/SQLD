---
type: technique
pilot: true
category: 지도학습-분류
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 로지스틱 회귀 — Oracle · SQL Server 중심

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
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | 분석 테이블 구성, 이탈률(기저율) 요약 |
| Python (`02_analyze.py`) | `statsmodels.Logit`으로 계수·z검정·p-value 추정, 오즈비(`EXP(β)`)·예측확률 산출 |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, `EXP(β)`를 SQL `EXP()` 함수로 재계산해 대조, 혼동행렬 집계 |

## 두 DBMS에서 같은 부분

- `EXP(x)` 지수함수는 Oracle과 SQL Server 모두 동일한 이름·인수로 지원한다 —
  오즈비 재계산 쿼리 자체는 함수 이름 수준에서 완전히 같다.
- Python이 추정한 오즈비와 SQL `EXP(coef)`로 재계산한 값은 (캐스팅을 올바르게 하면)
  두 DBMS에서 동일하다.

## 두 DBMS에서 다른 부분

- **정수 나눗셈**: `churned`가 정수형(Oracle `NUMBER`는 안전, SQL Server `INT`는
  위험)인 이탈률 계산에서 `01_prepare_sqlserver.sql`은 `1.0 *`을 반드시 붙여야 한다.
- **`GROUP BY`에 별칭 사용 불가**: `03_verify_*.sql`의 예측확률 구간별 이탈률 집계에서
  `CASE WHEN ... AS prob_bucket`을 만든 뒤 `GROUP BY prob_bucket`으로 줄여 쓸 수 없다
  — Oracle·SQL Server 둘 다 `GROUP BY`에 `CASE` 표현식 전체를 다시 써야 한다(SQLite/
  MySQL은 별칭을 허용하는 비표준 확장이 있어 이 문제가 가려져 있었다 — 자세한 내용은
  [[DBMS 문법 차이(Oracle-SQLServer)]] 참고).

## SQLD 출제 함정

- 오즈비 해석 문제에서 `EXP(β)`의 밑이 자연상수 `e`라는 점, 그리고 `LOG`가 아니라
  `EXP`가 "로그의 역함수"라는 점을 혼동하기 쉽다 — [문제05](../../필기계산문제-멀티DBMS/문제05-엔트로피-지니계수/README.md)의
  `LOG` 인수 순서 함정과 짝을 이루는 함정이다.

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
| 로짓 β̂ | `statsmodels.Logit(y, X).fit().params` |
| z값, p-value | `.tvalues`(z), `.pvalues` |
| 오즈비 EXP(β) | `np.exp(params)` |
| 예측확률 p | `.predict(X)` |
| R 대응 | `glm(churned ~ ., data=df, family=binomial)`, `exp(coef(fit))` |
