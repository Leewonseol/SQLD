# 09 집합 연산 — 단원 안내 (별도 학습 분기)

집합 연산자는 **SELECT 문 두 개의 결과**를 집합으로 보고 결합한다(PDF E-27). 각 SELECT는 FROM~SELECT까지 독립적으로 처리된다.
그다음 집합 연산을 하고, ORDER BY는 전체 결과에 **한 번만** 적용한다.

| 실습 | 주제 | 근거 |
|---|---|---|
| [ex01](examples/ex01_union_intersect_minus.md) | UNION·UNION ALL·INTERSECT·MINUS/EXCEPT, NULL | PDF E-27 |
| [ex02](examples/ex02_set_operation_rules.md) | 컬럼명·컬럼 수·자료형·ORDER BY 규칙, 연산자 우선순위 | PDF E-27 |
| [ex03](examples/ex03_set_vs_join.md) | 집합 연산 vs EXISTS·JOIN | PDF E-27, §7 |

## 실행으로 확인한 DBMS 차이
| 항목 | Oracle 21c (기준 19c) | SQL Server 2022 |
|---|---|---|
| 차집합 | MINUS (EXCEPT는 **21c부터**. 19c 미지원 — 외부 문서 기준, 19c 미실행) | EXCEPT |
| `MINUS` 사용 시 | — | **오류 없음**: MINUS를 테이블 별칭으로 해석해 SELECT 두 개를 따로 실행한다 |
| INTERSECT ALL / MINUS ALL | 21c부터 지원 | 미지원(Msg 324) |
| 우선순위 | 모든 집합 연산자가 같다(왼쪽부터) | **INTERSECT가 먼저** → `A UNION B INTERSECT C`의 결과가 다르다 |
| 자료형 불일치 | ORA-01790(컴파일 단계) | 우선순위가 높은 형으로 변환을 시도하다 Msg 245(실행 단계) |
