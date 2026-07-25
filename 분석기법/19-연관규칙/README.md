---
type: technique
pilot: true
category: 비지도학습-연관규칙
---

# 연관규칙 (Association Rules)

## 필기 공식

- 지지도(Support): `support(A) = count(A를 포함하는 거래) / 전체 거래 수`
- 신뢰도(Confidence): `confidence(A→B) = support(A∪B) / support(A)`
  — A를 산 거래 중 B도 같이 산 비율
- 향상도(Lift): `lift(A→B) = confidence(A→B) / support(B)`
  - `lift > 1`: A와 B가 양(+)의 연관 (같이 살 가능성이 우연보다 높음)
  - `lift = 1`: 두 품목이 독립
  - `lift < 1`: 음(-)의 연관
- Apriori 알고리즘: 최소 지지도(min_support) 이상인 빈발항목집합만 후보로 남기고,
  하위집합이 빈발하지 않으면 상위집합도 빈발할 수 없다는 성질(Apriori 성질)로 탐색 공간을 줄인다

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | `basket_transactions`(롱포맷)를 거래×품목 원-핫 wide 테이블로 PIVOT |
| Python (`02_analyze.py`) | `mlxtend.frequent_patterns.apriori` + `association_rules`로 지지도·신뢰도·향상도 계산 |
| SQL (`03_verify.sql`) | 상위 규칙 하나를 골라 지지도·신뢰도·향상도를 SQL `COUNT` 기반으로 직접 재계산해 대조 |

## DBMS별 SQL 차이 (PIVOT)

[`02-SVD-NMF`](../02-SVD-NMF/README.md)와 동일하게 SQLite는 PIVOT 구문이 없어
`SUM(CASE WHEN item = '...' THEN 1 ELSE 0 END)` 조건부 집계로 대체한다. Oracle/SQL Server는
`PIVOT` 구문을 직접 사용할 수 있다.

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 빈발항목집합(Apriori) | `mlxtend.frequent_patterns.apriori(df, min_support=0.05, use_colnames=True)` |
| 지지도/신뢰도/향상도 | `association_rules(freq_itemsets, metric="lift", min_threshold=1.0)` |
| R 대응 | `arules::apriori(transactions, parameter=list(support=0.05, confidence=0.3))` |
