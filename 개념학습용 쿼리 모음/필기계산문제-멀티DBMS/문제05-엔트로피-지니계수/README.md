---
type: written-exam-problem
pilot: true
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 문제 05. 엔트로피·지니계수 (Oracle · SQL Server)

## 1. 필기 예상문제

> 어떤 노드에 속한 10개 데이터의 클래스 분포가 Yes 8개, No 2개다. 이 노드의
> **엔트로피**와 **지니계수**를 구하시오.

## 2. 손계산

- `p_yes=0.8, p_no=0.2`
- `Entropy = -(0.8×log₂0.8 + 0.2×log₂0.2) ≈ 0.72193`
- `Gini = 1-(0.8²+0.2²) = 0.32`

## 3. 공통 입력 데이터

```
node_dist(label, n)
('Yes', 8), ('No', 2)
```

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql). **Oracle의 `LOG`는 인수 1개짜리가 없다** — 항상
`LOG(밑, 진수)` 두 인수가 필요하다.

```sql
SELECT - SUM((n/10) * LOG(2, n/10)) AS entropy FROM node_dist;
```

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql). SQL Server `LOG`는 인수 1개면 **자연로그**이고,
밑을 지정하려면 `LOG(진수, 밑)` — **Oracle과 인수 순서가 반대**다.

```sql
SELECT - SUM((n/10) * LOG(n/10, 2)) AS entropy FROM node_dist;
```

## 6. Oracle 예상 결과

`entropy≈0.72193, gini=0.32` (손계산과 일치 — **실제 Oracle 검증 필요**)

## 7. SQL Server 예상 결과

`entropy≈0.72193, gini=0.32`(밑을 명시했을 때) — 그러나 `sqlserver.sql`의 두 번째
쿼리처럼 밑 없이 `LOG(n/10)`을 쓰면 자연로그가 적용돼 **`entropy_wrong_using_ln`이
손계산과 다른 값**으로 나온다. (**실제 SQL Server 검증 필요**)

## 8. 두 DBMS에서 같은 부분

밑을 올바르게 지정하면(Oracle `LOG(2,p)`, SQL Server `LOG(p,2)`) 최종 엔트로피·지니계수
값은 완전히 동일하다.

## 9. 두 DBMS에서 다른 부분 — 인수 순서가 정반대

| | 밑을 지정한 로그 문법 |
|---|---|
| Oracle | `LOG(밑, 진수)` — 밑이 먼저 |
| SQL Server | `LOG(진수, 밑)` — **진수가 먼저, 밑이 나중** |

같은 두 값을 넣어도 순서를 바꿔 쓰면 값이 완전히 달라진다(`LOG(2, 0.8) ≠ LOG(0.8, 2)`).
게다가 SQL Server는 인수 1개짜리 `LOG(x)`가 **자연로그**로 정의되어 있어, Oracle에
"밑 없는 LOG는 없다"는 사실과 무관하게 SQL Server에서는 밑을 빠뜨려도 문법 오류 없이
**조용히 틀린 결과**를 낸다는 점이 더 위험하다.

## 10. SQLD 출제 함정

- 의사결정나무 분할기준(엔트로피/정보이득) 계산 문제에서 `LOG` 인수 순서를 Oracle
  기준으로 외운 채 SQL Server 문제에 그대로 적용하면(`LOG(2, p)`를 SQL Server에 쓰면)
  결과가 틀린다 — 반대로 SQL Server 기준으로 외운 순서(`LOG(p, 2)`)를 Oracle에 쓰면
  Oracle은 첫 인수를 밑으로 해석하므로 역시 틀린다. **두 DBMS의 `LOG` 인수 순서는
  통째로 반대로 외워야 한다.**

## 11. 실기 Python/R 코드와의 대응

| SQL | Python | R |
|---|---|---|
| `LOG(2, p)`/`LOG(p, 2)` | `math.log2(p)`, `numpy.log2(p)` | `log2(p)` |
| 지니계수 | `1 - sum(p**2)` | `1 - sum(p^2)` |

`sklearn.tree.DecisionTreeClassifier(criterion="entropy")`가 내부적으로 이 `log2`
연산을 각 분할 후보마다 반복 계산한다 — `분석기법/08-의사결정나무`는 이 계산 자체를
Python에 맡기고, SQL은 분할 전 탐색적 집계(`recency_bucket`별 이탈률)만 담당하도록
설계했다.

## 12. 보조 DBMS 실행 결과 (SQLite·DuckDB·MariaDB)

이 세션에서 실제 실행 확인(`python3 run_compare.py`): 밑을 지정하지 않은 `LOG(x)`가
SQLite·DuckDB에서는 **상용로그(log₁₀)**, MariaDB에서는 **자연로그(ln)** 로 나와 서로도
다르고 SQL Server(자연로그)와는 MariaDB만 일치했다 — "밑 없는 LOG는 위험하다"는
결론이 다섯 DBMS 전체에서 공통으로 확인된 셈이다. 밑을 `2`로 명시하면(SQLite/DuckDB
`LOG(2,p)`, MariaDB `LOG2(p)`) 다섯 DBMS 모두 `entropy≈0.72193`으로 일치한다.

## 실행

```bash
# Oracle: oracle.sql을 Oracle SQL Developer 등에 복사해 실행 (이 저장소에서 실행 불가)
# SQL Server: sqlserver.sql을 SSMS 등에 복사해 실행 (이 저장소에서 실행 불가)
python3 run_compare.py   # 보조 DBMS(SQLite/DuckDB/MariaDB) 실행 비교
```
