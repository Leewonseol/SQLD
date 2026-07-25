---
type: technique
pilot: true
category: 비지도학습-연관규칙
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 연관규칙 (Association Rules) — Oracle · SQL Server 중심

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
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | `basket_transactions`(롱포맷)를 거래×품목 원-핫 wide 테이블로 PIVOT |
| Python (`02_analyze.py`) | `mlxtend.frequent_patterns.apriori` + `association_rules`로 지지도·신뢰도·향상도 계산 |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, 지지도·신뢰도·향상도를 SQL `COUNT` 기반으로 직접 재계산해 대조 |

## 두 DBMS에서 같은 부분 / 다른 부분

[`02-SVD-NMF`](../02-SVD-NMF/README.md)와 동일한 결론이다: Oracle·SQL Server 둘 다
`PIVOT`을 네이티브로 지원하고, 값이 있으면 1인 원-핫 인코딩은 `MAX(CASE WHEN...)`을
집계함수로 넘겨 PIVOT한다. 다른 점도 동일하다 — PIVOT 문법 세부사항(값 목록 표기,
대괄호 여부)과, 정수 나눗셈 캐스팅 필요 여부(SQL Server만 `1.0 *` 필요)뿐이다.
이 기법에서 특별히 새로 드러나는 차이는 없다는 것 자체가 유효한 기록이다 — 매 기법마다
Oracle과 SQL Server가 다르지는 않다는 것을 두 사례(SVD·NMF, 연관규칙)로 확인했다.

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
| 빈발항목집합(Apriori) | `mlxtend.frequent_patterns.apriori(df, min_support=0.05, use_colnames=True)` |
| 지지도/신뢰도/향상도 | `association_rules(freq_itemsets, metric="lift", min_threshold=1.0)` |
| R 대응 | `arules::apriori(transactions, parameter=list(support=0.05, confidence=0.3))` |
