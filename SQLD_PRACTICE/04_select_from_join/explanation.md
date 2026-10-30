# 04 FROM·JOIN·ON — 단원 안내

학습 흐름에서 이 단원의 위치는 **테스트 데이터 INSERT → FROM·JOIN·ON** 이다.
SELECT 문을 실행하면 DBMS는 논리적으로 FROM 절을 먼저 처리한다. 이 단계에서 "어떤 행들이 처리 대상인가"가 정해진다.
나머지 절(WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → 행 제한)은 FROM·JOIN이 만든 중간 결과를 받아 처리한다.

> **세 가지 순서를 구분한다**
> * **작성 순서**: SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY (문법이 정한 순서)
> * **논리적 처리 순서**: FROM(JOIN·ON) → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → 행 제한
>   (결과의 의미를 정하는 순서. PDF E-05의 (1)~(6)은 이 가운데 DISTINCT와 행 제한을 뺀 것이다)
> * **물리적 실행 순서**: 옵티마이저가 고른 실행 계획. 인덱스 사용, 조건을 조인 전으로 밀어 넣기(predicate pushdown), 해시 조인 등으로 실제 연산 순서는 달라질 수 있다. 다만 결과는 논리적 처리 순서로 해석한 것과 같아야 한다.

## 실습 목록

| 실습 | 주제 | 근거 | 데이터 |
|---|---|---|---|
| [ex01](examples/ex01_sql_statement_types.md) | SQL 문장 종류 DML·DDL·DCL·TCL | PDF E-04 | — |
| [ex02](examples/ex02_clause_order.md) | 작성 순서와 논리적 처리 순서 | PDF E-05 | SCOTT |
| [ex03](examples/ex03_select_basics.md) | SELECT·DISTINCT·ALIAS·산술·결합·DUAL | PDF E-07, §7 | SCOTT |
| [ex04](examples/ex04_equi_join.md) | EQUI JOIN, 별칭 규칙 | PDF E-09, E-14 | 가상 |
| [ex05](examples/ex05_non_equi_join.md) | NON EQUI JOIN | PDF E-10 | PDF |
| [ex06](examples/ex06_multi_table_join.md) | 3개 이상 테이블 조인 | PDF E-11 | 가상 |
| [ex07](examples/ex07_self_join.md) | SELF JOIN | PDF E-02, E-12 | PDF |
| [ex08](examples/ex08_using_natural.md) | ON·USING·NATURAL JOIN | PDF E-15~E-17 | PDF |
| [ex09](examples/ex09_cross_join.md) | CROSS JOIN | PDF E-18 | PDF |
| [ex10](examples/ex10_outer_join.md) | LEFT·RIGHT·FULL OUTER, Oracle (+) | PDF E-19 | PDF |
| [ex11](examples/ex11_on_vs_where.md) | LEFT JOIN 에서 ON 과 WHERE | §9 | 가상 |
| [ex12](examples/ex12_one_to_many_rows.md) | 1:N 조인과 행 수 증가 | §9 | 가상 |
| [ex13](examples/ex13_relational_ops.md) | 순수 관계 연산자, DIVIDE | PDF E-13 | 가상 |

## 실행 방법

```bash
python3 tools/run_labs.py 00_common 04_select_from_join
```

* 결과 전문은 `expected_results/*.txt`에 저장된다. 각 예제 문서의 E 칸은 이 파일에서 자동으로 채워진다.
* 검증 환경: Oracle Database 21c XE 21.3.0.0.0, SQL Server 2022 16.0.4305.5. Oracle 19c에서는 실행하지 않았다.
  이 단원에는 19c에 없는 기능을 쓰지 않았다. 단, `*_oracle23ai.sql`은 23ai 계열 전용이다.

## 이 단원에서 실행으로 확인한 PDF 서술 (외부검증)

| PDF 서술 | 실행 결과 | 판정 |
|---|---|---|
| E-12 SELF JOIN 쿼리 `WHERE E1.EMP_ID = E2.EMP_ID` | 각 행이 자기 자신과 조인되어 6행이 나온다. PDF 결과표(사원-관리자 5행)는 `E1.MGR_ID = E2.EMP_ID`로 실행해야 나온다 | PDF 쿼리 오기로 판단 |
| E-02 `WHERE a.직원ID = b.상사ID`, `a.이름 AS 직원이름, b.이름 AS 상사` | 4행. a가 상사 쪽이 되어 열 이름과 내용이 뒤바뀐다. PDF 결과표의 "나사장-NULL" 행은 INNER 조인으로는 나올 수 없다 | 결과표는 `a.상사ID = b.직원ID` + LEFT JOIN 결과와 같다 |
| E-19 `WHERE (+)b.Publisher_id = p.Publisher_id` | Oracle ORA-00936 | `(+)`는 컬럼 뒤에 붙는다: `b.publisher_id(+) = p.publisher_id` |
| E-16·E-17 USING·NATURAL은 SQL Server 미지원 | SQL Server 2022 Msg 102. NATURAL은 테이블 별칭으로 해석된 뒤 ON이 없어 오류가 난다 | 일치 |
| E-05 GROUP BY와 HAVING 순서를 바꿀 수 있음 | Oracle 21c는 실행된다. SQL Server는 Msg 156 | **Oracle 한정** |
| E-07 23c 이전 Oracle은 FROM 필수 | 21c ORA-00923, 23ai 계열(26ai Free 23.26.3)은 실행된다 | 일치 |
