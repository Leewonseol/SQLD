---
type: written-exam-problem
pilot: true
---

# 문제 01. 평균·분산·표준편차

## 필기 예상문제 (재현)

> 다음은 5개 매장(A~E)의 일일 매출액(단위: 백만원)이다.
>
> | 매장 | A | B | C | D | E |
> |---|---|---|---|---|---|
> | 매출액 | 12 | 15 | 11 | 18 | 14 |
>
> 이 자료의 평균, **모분산·모표준편차**, **표본분산·표본표준편차**를 구하시오.

## 손계산

- 평균 `x̄ = (12+15+11+18+14) / 5 = 70/5 = 14`
- 편차제곱합 `Σ(xᵢ-x̄)² = (-2)²+1²+(-3)²+4²+0² = 4+1+9+16+0 = 30`
- 모분산 `σ² = 30/5 = 6`, 모표준편차 `σ = √6 ≈ 2.449`
- 표본분산 `s² = 30/(5-1) = 30/4 = 7.5`, 표본표준편차 `s = √7.5 ≈ 2.739`

## 4-DBMS 문법 비교

| 통계량 | Oracle | SQL Server | MySQL/MariaDB | DuckDB | SQLite |
|---|---|---|---|---|---|
| 모표준편차 | `STDDEV_POP(x)` | `STDEVP(x)` | `STDDEV_POP(x)` 또는 `STD(x)` | `STDDEV_POP(x)` | 내장 없음 |
| 표본표준편차 | `STDDEV(x)` | `STDEV(x)` | `STDDEV_SAMP(x)` 또는 `STDDEV(x)` | `STDDEV_SAMP(x)` | 내장 없음 |
| 모분산 | `VAR_POP(x)` | `VARP(x)` | `VARIANCE(x)` 또는 `VAR_POP(x)` | `VAR_POP(x)` | 내장 없음 |
| 표본분산 | `VARIANCE(x)` | `VAR(x)` | `VAR_SAMP(x)` | `VAR_SAMP(x)` | 내장 없음 |

**함정 포인트(실기·필기 공통 단골 오답 유발 지점)**: `STDDEV(x)`라는 이름이 Oracle에서는
**표본**표준편차인데, MySQL/MariaDB의 `STD(x)`는 **모**표준편차다. 엔진마다 "기본" 이름이
가리키는 대상이 다르므로, 시험이든 실무든 `_POP`/`_SAMP` 접미사가 붙은 명시적인 이름을
확인하는 습관이 필요하다. SQLite는 아예 내장 함수가 없어 `Var(x) = E[x²]-E[x]²` 공식을
직접 풀어 써야 한다 — 이것이 오히려 공식 자체를 외우는 데는 더 도움이 된다.

## 실행

```bash
python3 run_compare.py
```
SQLite는 항상 실행되고, DuckDB·MariaDB는 설치·기동되어 있으면 함께 비교되며 없으면
자동으로 건너뛴다(`_engine/README` 참고).
