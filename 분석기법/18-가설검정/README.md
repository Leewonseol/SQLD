---
type: technique
pilot: true
category: 통계적추론
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 가설검정 — Oracle · SQL Server 중심

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
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | 집단별 평균·분산·표본크기 요약, A/B 교차표 집계 |
| Python (`02_analyze.py`) | `scipy.stats`의 `ttest_rel`, `f_oneway`, `chi2_contingency`로 검정통계량·p-value 산출 |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, SQL 요약통계로 t/F/χ² 통계량을 직접 재계산해 대조 |

## 두 DBMS에서 같은 부분

- `GROUP BY` + `AVG`로 집단별 평균을 구하는 구조 자체는 동일하다.
- t/F/χ² 공식을 직접 SQL로 전개하는 로직(CTE 구조)은 두 DBMS에서 완전히 동일하게
  작성할 수 있다 — 최종 통계량 값도 같다.

## 두 DBMS에서 다른 부분

| 항목 | Oracle | SQL Server |
|---|---|---|
| 표본표준편차(대응차이) | `STDDEV(x)` | `STDEV(x)` |
| 모분산(ANOVA용) | `VAR_POP(x)` | `VARP(x)` |
| 나눗셈 안전성 | `NUMBER`라 캐스팅 불필요 | `SUM(n)`류 정수 컬럼이 섞이는 모든 나눗셈에 `1.0 *` 필요(`03_verify_sqlserver.sql`에 5곳) |

**정수 나눗셈이 이 실습에서 가장 위험한 지점이다.** 카이제곱 기대빈도
`row_total × col_total / grand_total`은 세 값 모두 `COUNT`에서 나온 정수이므로, SQL
Server에서 `1.0 *`을 빠뜨리면 기대빈도가 반올림되어 카이제곱 통계량 전체가 틀어진다 —
Oracle은 `NUMBER`이므로 이 문제가 나타나지 않는다(`필기계산문제-멀티DBMS/문제04`와
동일한 함정이 실제 가설검정 계산에 다시 등장한 사례).

## SQLD 출제 함정

- `scipy.stats.chi2_contingency`는 2×2 표에서 기본적으로 **Yates 연속성 수정**을
  적용해 필기 공식과 값이 달라진다(`02_analyze.py`는 `correction=False`로 꺼서 공식과
  1:1 비교한다) — 이는 DBMS 차이가 아니라 Python 라이브러리 기본값의 함정이지만,
  SQL로 직접 재계산한 값과 Python 기본 출력이 다르면 "검산 실패"로 오인하기 쉽다.

## 실행

```bash
# Oracle / SQL Server: *_oracle.sql, *_sqlserver.sql을 각 환경에 복사해 실행 (이 저장소에서 실행 불가)
python3 02_analyze.py

# 보조(SQLite, 이 저장소에서 실제 실행 확인됨):
python3 ../_data/run_sql.py optional/01_prepare_sqlite.sql
python3 02_analyze.py
python3 ../_data/run_sql.py optional/03_verify_sqlite.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 대응표본 t검정 | `scipy.stats.ttest_rel(after, before)` |
| 일원배치 분산분석 | `scipy.stats.f_oneway(a, b, c)` |
| 카이제곱 독립성 검정 | `scipy.stats.chi2_contingency(table)` |
| R 대응 | `t.test(after, before, paired=TRUE)`, `aov(score~branch)`, `chisq.test(table)` |
