# 학습 순서 (curriculum)

## 1. 큰 흐름

```
업무 규칙 → 엔터티·속성·관계 → ERD(IE·Barker) → 키·제약조건 → CREATE TABLE → 정규화 → 테스트 데이터 INSERT
   → FROM·JOIN·ON → WHERE → GROUP BY → HAVING → SELECT·DISTINCT → ORDER BY → 행 제한 → 결과 검증
```

| 단계 | 단원 | 핵심 질문 | 산출물 |
|---|---|---|---|
| 업무 규칙 → 엔터티·속성·관계 → ERD | [01_modeling](01_modeling/explanation.md) | 무엇을 관리하는가? 몇 대 몇이고, 반드시 참여하는가? | IE·Barker ERD, 규칙 R1~R10 |
| 키·제약조건 → CREATE TABLE | [02_erd_to_ddl](02_erd_to_ddl/explanation.md) | 규칙마다 어떤 제약으로 지키는가? 제약으로 못 지키는 규칙은 무엇인가? | DDL, 규칙↔제약 대응표, 자료형 매핑 |
| 정규화 | [03_normalization](03_normalization/explanation.md) | 어떤 함수 종속이 이상현상을 만드는가? 분해 후 JOIN으로 원래대로 돌아오는가? | 1NF~BCNF 분해, 무손실 검증, 반정규화 |
| 테스트 데이터 INSERT | 각 단원 `setup_*.sql`, [00_common](00_common/) | 결과를 예측할 수 있는 작은 데이터인가? | 다시 실행 가능한 데이터 |
| FROM·JOIN·ON | [04_select_from_join](04_select_from_join/explanation.md) | 처리 대상 행 집합은 무엇인가? 1:N 조인에서 행이 늘어나는가? | 조인 결과, 행 수 |
| WHERE | [05_where_conditions](05_where_conditions/explanation.md) | 어떤 행이 남는가? NULL은 어떻게 되는가? | 필터 결과 |
| GROUP BY → HAVING → SELECT·DISTINCT → ORDER BY → 행 제한 | [06_group_having](06_group_having/explanation.md) | 그룹 하나가 몇 행인가? 정렬 없이 순서를 말할 수 있는가? | 집계·정렬·TOP-N |
| 결과 검증 | [15_integrated_exam](15_integrated_exam/explanation.md) | 보기 SQL 네 개 가운데 요구 결과와 같은 것은 무엇인가? | MATCH/DIFF 판정 |

## 2. 분기 (큰 흐름의 어느 단계에 붙는가)

```
                 ┌─ 07 단일행 함수 ────────── SELECT·WHERE 안의 식
                 ├─ 08 서브쿼리 ───────────── WHERE·SELECT·FROM·HAVING·UPDATE 안의 질의
 04→05→06 ──────┼─ 09 집합 연산 ──────────── 완성된 SELECT 결과끼리의 결합
                 ├─ 10 그룹 확장·PIVOT ────── GROUP BY 단계의 확장
                 ├─ 11 윈도우 함수 ────────── SELECT 단계(GROUP BY·HAVING 다음, ORDER BY 앞)
                 └─ 12 계층형 질의 ────────── FROM·WHERE 단계의 특수 전개
 02→03 ─────────── 13 DML·DDL·제약조건 ───── 데이터·구조 변경
                   14 TCL·DCL ────────────── 변경의 확정·취소, 동시성, 권한
```

권장 순서: **01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10 → 11 → 12 → 13 → 14 → 15**.
분기 단원(07~14)은 04~06을 끝낸 뒤라면 순서를 바꿔도 된다. 다만 다음 의존 관계는 지킨다.
* 08 서브쿼리 ex05(EXISTS) → 15 Q5·Q6
* 06 GROUP BY → 10 그룹 확장, 11 윈도우 함수 ex06(GROUP BY와 비교) → 15 Q7
* 05 ex05(NULL 3값 논리) → 05 ex02(NOT IN), 06 ex01(집계와 NULL) → 15 Q6·Q8
* 13 DML → 14 TCL (커밋 전후를 비교하려면 DML을 먼저 알아야 한다)

## 3. 세 가지 순서를 구분한다

| 구분 | 순서 | 무엇을 결정하는가 | 확인한 실습 |
|---|---|---|---|
| **작성 순서** | SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → (FETCH / TOP은 SELECT 안) | 문법상 올바른가 | 04 ex02: Oracle은 GROUP BY·HAVING 순서를 바꿔 써도 실행되지만, SQL Server는 Msg 156으로 거부한다 |
| **논리적 처리 순서** | FROM(JOIN·ON) → WHERE → GROUP BY(ROLLUP·CUBE) → HAVING → SELECT(윈도우 함수) → DISTINCT → ORDER BY → 행 제한(FETCH·TOP·OFFSET) | 결과가 무엇인가. 별칭을 어디서 쓸 수 있고, 집계를 어디서 쓸 수 있는가 | 06 ex04에서 단계별 중간 결과를 추적했다 |
| **물리적 실행 순서** | 옵티마이저가 정한 실행 계획(인덱스, 조인 방식, 조건 밀어 넣기, 서브쿼리 변환) | 얼마나 빨리 실행되는가. 결과는 논리적 순서로 해석한 것과 같아야 한다 | 08 ex08: Oracle 21.3 XE에서 서브쿼리 변환(VW_WIF_1)이 정렬 결과를 틀리게 만든 사례. 물리 계획이 논리적 의미를 어긴 엔진 결함으로 기록했다 |

논리적 순서에서 나오는 결과:
* WHERE에는 SELECT 별칭도 집계함수도 쓸 수 없다. 둘 다 아직 만들어지지 않았다(04 ex02, 05 ex06).
* ORDER BY에는 SELECT 별칭을 쓸 수 있다(06 ex05).
* 윈도우 함수는 WHERE·HAVING에 쓸 수 없다. 그 결과로 거르려면 인라인 뷰가 필요하다(11 ex01·ex03).
* ROWNUM은 ORDER BY보다 먼저 붙는다. 그래서 정렬 후 TOP-N을 하려면 인라인 뷰가 필요하다(06 ex06).
* LEFT JOIN 오른쪽 테이블의 조건을 WHERE에 쓰면, 조인이 끝난 뒤에 필터가 적용된다. 그래서 OUTER가 INNER처럼 된다(04 ex11, 15 Q3·Q4).

## 4. 단원별 실습 목록과 학습 순서

| # | 단원 | 실습 | 처리 방식 |
|---|---|---|---|
| 1 | 01_modeling | ex01 업무 규칙→ERD(IE·Barker) · ex02 차수·선택성 · ex03 식별/비식별 관계 · ex04 키의 종류 · ex05 순환 관계 · ex06 제약으로 구현할 수 없는 규칙 | ex01 설계·도식, ex02~06 실행 |
| 2 | 02_erd_to_ddl | ex01 도서관 DDL과 규칙↔제약 대응표 · ex02 자료형 매핑 | 실행 |
| 3 | 03_normalization | ex01 함수 종속 · ex02 이상현상 · ex03 1NF · ex04 2NF · ex05 3NF(PDF E-01) · ex06 BCNF와 손실 분해 · ex07 반정규화 | 실행(4NF·5NF는 explanation.md 이론) |
| 4 | 04_select_from_join | ex01 SQL 문장 종류 · ex02 절 순서 · ex03 SELECT 기초·DUAL · ex04 EQUI · ex05 NON EQUI · ex06 3개 이상 테이블 · ex07 SELF · ex08 USING·NATURAL · ex09 CROSS · ex10 OUTER·(+) · ex11 ON vs WHERE · ex12 1:N 행 증가 · ex13 관계 연산자 | ex01 이론, 나머지 실행 |
| 5 | 05_where_conditions | ex01 연산자·우선순위 · ex02 IN·NOT IN · ex03 LIKE · ex04 BETWEEN · ex05 NULL 3값 논리 · ex06 WHERE의 집계 · ex07 형변환 | 실행 |
| 6 | 06_group_having | ex01 집계와 NULL · ex02 GROUP BY 규칙 · ex03 HAVING · ex04 논리 순서 추적 · ex05 ORDER BY · ex06 TOP-N | 실행 |
| 7 | 07_single_row_functions | ex01 문자 · ex02 숫자 · ex03 날짜 · ex04 변환 · ex05 NULL 함수 · ex06 CASE·DECODE · ex07 정규식 | 실행(PDF 본문 판독 불가 구간) |
| 8 | 08_subqueries | ex01 단일행 · ex02 ANY·ALL · ex03 다중컬럼 · ex04 연관 · ex05 EXISTS · ex06 스칼라 · ex07 인라인 뷰 · ex08 HAVING·UPDATE · ex09 복합키 · ex10 뷰 | 실행 |
| 9 | 09_set_operations | ex01 UNION·INTERSECT·MINUS · ex02 규칙·우선순위 · ex03 집합 연산 vs EXISTS·JOIN | 실행 |
| 10 | 10_grouping_extensions | ex01 ROLLUP · ex02 GROUPING · ex03 CUBE · ex04 GROUPING SETS · ex05 PIVOT·UNPIVOT | 실행 |
| 11 | 11_window_functions | ex01 기본·PARTITION BY · ex02 ROWS·RANGE · ex03 순위 · ex04 LAG·LEAD·FIRST·LAST · ex05 NTILE·비율 · ex06 GROUP BY vs 윈도우 | 실행 |
| 12 | 12_hierarchical_queries | ex01 CONNECT BY · ex02 NOCYCLE · ex03 재귀 WITH | 실행 |
| 13 | 13_dml_ddl_constraints | ex01 INSERT·UPDATE·DELETE · ex02 MERGE · ex03 CREATE·ALTER · ex04 DELETE·TRUNCATE·DROP · ex05 제약조건 · ex06 CTAS | 실행 |
| 14 | 14_transactions_permissions | ex01 TCL · ex02 격리 수준·두 세션 실험 · ex03 GRANT·REVOKE·ROLE | 실행(Non-repeatable·Phantom Read, RCSI·SNAPSHOT은 미실행) |
| 15 | 15_integrated_exam | Q1 PK·FK 누락 · Q2 1:N 중복 집계 · Q3 LEFT JOIN+WHERE · Q4 ON vs WHERE · Q5 고객ID vs 고객ID+컨텐츠ID · Q6 NOT IN과 NULL · Q7 GROUP BY vs 윈도우 · Q8 NULL과 집계 | 실행(보기마다 MATCH/DIFF 판정) |

## 5. 실습 한 개를 공부하는 방법 (A~H)
1. **A 개념** 읽기 → **B 입력 데이터** 표를 보고 직접 결과를 손으로 적는다.
2. **D 결과 예측**에 답한 뒤 **E 실제 출력**과 비교한다. 행 순서는 ORDER BY가 있을 때만 맞춰 본다.
3. **F 변형**에서 조건 하나를 바꾸면 결과가 어떻게 바뀌는지 예측한다.
4. **G 직접 작성**(`exercises/`)을 풀고, **H 정답**(`answers/`)을 실행해 `CHECK_PASS`인지 확인한다.
5. Oracle과 SQL Server 결과를 나란히 보고, 다르면 그 이유를 explanation.md에서 확인한다.
