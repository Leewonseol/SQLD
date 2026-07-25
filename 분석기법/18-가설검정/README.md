---
type: technique
pilot: true
category: 통계적추론
---

# 가설검정

## 필기 공식

- 대응표본 t검정 (전/후 비교): `t = d̄ / (s_d / √n)` (`d̄`: 차이의 평균, `s_d`: 차이의 표본표준편차)
- 일원배치 분산분석(one-way ANOVA): `F = MSB / MSW`
  - `MSB = SSB/(k-1)`, `SSB = Σ nᵢ(x̄ᵢ - x̄)²` (집단간 변동)
  - `MSW = SSW/(N-k)`, `SSW = Σ Σ(xᵢⱼ - x̄ᵢ)²` (집단내 변동)
- 카이제곱 독립성 검정: `χ² = Σ (O-E)² / E` (`O`: 관측빈도, `E`: 기대빈도 = 행합계×열합계/전체합계)
- 유의수준 α(보통 0.05)보다 p-value가 작으면 귀무가설(H0: 차이/효과 없음) 기각
- 참고: `scipy.stats.chi2_contingency`는 2x2 표에서 기본적으로 **Yates 연속성 수정**을
  적용해 필기 공식과 값이 달라진다. 이 실습은 `correction=False`로 꺼서 공식과 1:1 비교한다.

## 이번 실습의 세 가지 검정

| 검정 | 데이터 | 귀무가설 |
|---|---|---|
| 대응표본 t검정 | `paired_scores` (프로모션 전/후 만족도) | 전/후 평균 차이는 0이다 |
| 일원배치 분산분석 | `branch_scores` (지점 A/B/C 만족도) | 세 지점의 평균 만족도는 같다 |
| 카이제곱 독립성 검정 | `ab_test` (A/B 변형 × 전환여부) | 변형(A/B)과 전환 여부는 독립이다 |

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 집단별 평균·분산·표본크기 요약, A/B 교차표(contingency table) 집계 |
| Python (`02_analyze.py`) | `scipy.stats`의 `ttest_rel`, `f_oneway`, `chi2_contingency`로 검정통계량·p-value 산출 |
| SQL (`03_verify.sql`) | SQL 요약통계로 t/F/χ² 통계량을 직접 재계산해 Python 결과와 대조 |

## DBMS별 SQL 차이

집단별 평균·분산 집계는 표준 `GROUP BY` + `AVG`로 어느 DBMS에서나 동일하다. SQLite는
분산 내장함수가 없어 `AVG(x*x)-AVG(x)*AVG(x))` 공식을 쓰며, Oracle은 `VARIANCE(x)`,
SQL Server는 `VAR(x)`로 대체 가능하다.

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 대응표본 t검정 | `scipy.stats.ttest_rel(after, before)` |
| 일원배치 분산분석 | `scipy.stats.f_oneway(a, b, c)` |
| 카이제곱 독립성 검정 | `scipy.stats.chi2_contingency(table)` |
| R 대응 | `t.test(after, before, paired=TRUE)`, `aov(score~branch)`, `chisq.test(table)` |
