# 06 GROUP BY·HAVING → SELECT·DISTINCT·ORDER BY·행 제한 — 단원 안내

학습 흐름에서 이 단원은 **WHERE 다음의 모든 단계**를 다룬다.
`GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → 행 제한 및 최종 결과`.
[ex04](examples/ex04_logical_order_trace.md)에서 한 쿼리를 이 순서대로 한 단계씩 실행해 중간 결과를 확인한다(학습 능력 7번).

| 실습 | 주제 | 근거 |
|---|---|---|
| [ex01](examples/ex01_aggregates.md) | COUNT·SUM·AVG·MAX·MIN과 NULL, 빈 집합, 정수 평균 | §7 (추출본에 집계함수 본문 없음) |
| [ex02](examples/ex02_group_by_rules.md) | GROUP BY 규칙, NULL 그룹, 표현식 | §7 |
| [ex03](examples/ex03_having.md) | HAVING, WHERE와 HAVING 비교 | PDF E-06, E-24 |
| [ex04](examples/ex04_logical_order_trace.md) | 논리적 처리 순서 단계별 추적 | PDF E-05, §3 |
| [ex05](examples/ex05_order_by.md) | ORDER BY, NULL 정렬, 정렬 가능 컬럼 | PDF E-08 |
| [ex06](examples/ex06_top_n.md) | ROWNUM, FETCH FIRST, TOP, WITH TIES, OFFSET | PDF E-36, §7 |

## 실행으로 확인한 DBMS 차이와 PDF 대조
| 항목 | Oracle 21c | SQL Server 2022 | PDF |
|---|---|---|---|
| 정수 컬럼 AVG | 소수까지(1.5) | **정수 나눗셈**(1) | — |
| NULL 정렬(ASC) | 맨 뒤 | 맨 앞 | E-08 "Oracle 최댓값, SQL Server 최솟값" 일치 |
| NULLS FIRST/LAST | 지원 | 구문 오류 Msg 102 → CASE로 흉내 | E-08 "NULL LAST \| NULL FISRT"는 키워드 오기(NULLS) |
| GROUP BY 후 SELECT에 없는 그룹 컬럼·집계로 ORDER BY | 허용 | 허용 | E-08 "SELECT 절에 있는 컬럼만 가능"과 **다르다** |
| 파생 테이블 안 ORDER BY | 허용 | TOP 없으면 Msg 1033 | — |
| 행 제한 | ROWNUM, 12c+ FETCH FIRST·OFFSET·WITH TIES·PERCENT | TOP·TOP WITH TIES·TOP PERCENT, OFFSET-FETCH(ORDER BY 필수) | E-36 |
| WITH TIES 동점 행의 출력 순서 | SCOTT, FORD | FORD, SCOTT | 동점 순서는 단정할 수 없다 |
| 분산·표준편차 | VARIANCE·STDDEV | VAR·STDEV (FLOAT 결과 `…8700000001`) | — |
