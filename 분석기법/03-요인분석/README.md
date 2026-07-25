---
type: technique
pilot: true
category: 차원축소
---

# 요인분석 (Factor Analysis)

## 필기 공식

- 모형: `X = ΛF + ε` (`Λ`: 요인적재행렬, `F`: 공통요인, `ε`: 고유요인/오차)
- PCA와의 차이: PCA는 총분산을 설명하는 성분을 찾지만, 요인분석은 변수 간
  **공분산(상관)을 설명하는 잠재요인**을 찾는다 — 오차항 `ε`을 명시적으로 분리한다.
- 요인적재량(Factor Loading): 관측변수와 잠재요인 간 상관 정도 (보통 |적재량| ≥ 0.4를 유의미로 판단)
- 요인회전(Rotation): 해석을 쉽게 하기 위해 좌표축을 회전 (예: Varimax — 직교회전)
- 요인점수(Factor Score): 각 개체가 잠재요인 상에서 갖는 값

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 설문 6문항을 표준화하고, 롱포맷으로 변환한 뒤 문항 간 상관행렬을 SQL로 직접 계산 |
| Python (`02_analyze.py`) | `sklearn.decomposition.FactorAnalysis`로 2개 잠재요인 추출, 적재량·요인점수 산출 |
| SQL (`03_verify.sql`) | 상관행렬에서 문항 군집 확인, 적재량 상위 문항 조회, 요인점수 분포 비교 |

## DBMS별 SQL 차이

상관계수 `corr(x, y) = (E[xy] - E[x]E[y]) / (σx·σy)` 는 표준 집계함수 조합으로
어느 DBMS에서든 동일하게 짤 수 있다. Oracle은 `CORR(x, y)` 내장 집계함수를 제공해
한 줄로 대체 가능하지만, SQLite/일부 DBMS는 내장 함수가 없어 이 실습처럼 직접 풀어 쓴다.

| DBMS | 상관계수 |
|---|---|
| Oracle | `CORR(x, y)` |
| SQL Server | 내장 없음 → 직접 계산 |
| SQLite | 내장 없음 → 직접 계산 |

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 요인적재행렬 Λ | `FactorAnalysis().fit(X).components_.T` |
| 공통요인 F(요인점수) | `FactorAnalysis().fit_transform(X)` |
| 고유요인/오차분산 | `FactorAnalysis().noise_variance_` |
| R 대응 | `factanal(x, factors=2, rotation="varimax")` |
