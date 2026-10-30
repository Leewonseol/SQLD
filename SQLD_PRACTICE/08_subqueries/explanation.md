# 08 서브쿼리 — 단원 안내 (별도 학습 분기)

서브쿼리는 SQL 안의 SQL이다. **놓이는 위치**에 따라 처리 순서의 어느 단계에 끼어드는지가 정해진다.

| 위치 | 이름 | 처리 단계 | 실습 |
|---|---|---|---|
| SELECT 절 | 스칼라 서브쿼리 | SELECT(5) 단계에서 행마다 값 1개 | ex06 |
| FROM 절 | 인라인 뷰(동적 뷰) | FROM(1) 단계에서 임시 테이블 | ex07 |
| WHERE / HAVING 절 | 중첩 서브쿼리 | WHERE(2) / HAVING(4) 조건 | ex01~ex05, ex08 |
| UPDATE SET 절 | — | DML | ex08 |

반환 형태에 따라 단일행(ex01)·다중행(ex02)·다중컬럼(ex03)으로 나눈다. 바깥 쿼리 참조 여부에 따라 연관·비연관(ex04)으로 나눈다.
저장된 서브쿼리인 **뷰**는 ex10에서 다룬다(추출본에서 뷰 본문은 확인하지 못했다).

| 실습 | 주제 | 근거 |
|---|---|---|
| [ex01](examples/ex01_single_row_subquery.md) | 단일행 서브쿼리 | PDF E-22 ① |
| [ex02](examples/ex02_multi_row_any_all.md) | 다중행 IN·ANY·ALL | PDF E-22 ② |
| [ex03](examples/ex03_multi_column_subquery.md) | 다중컬럼 서브쿼리 | PDF E-22 ③ |
| [ex04](examples/ex04_correlated_subquery.md) | 연관·비연관 | §7 |
| [ex05](examples/ex05_exists_not_exists.md) | EXISTS·NOT EXISTS, NOT IN 함정 | PDF E-26, §9 |
| [ex06](examples/ex06_scalar_subquery.md) | 스칼라 서브쿼리 | PDF E-20 |
| [ex07](examples/ex07_inline_view.md) | 인라인 뷰 | PDF E-21 |
| [ex08](examples/ex08_having_update_subquery.md) | HAVING 서브쿼리, UPDATE SET 서브쿼리 | PDF E-24, E-25 |
| [ex09](examples/ex09_composite_key_subquery.md) | 복합키와 서브쿼리 | PDF E-23 |
| [ex10](examples/ex10_view.md) | 뷰, WITH CHECK OPTION, READ ONLY | 추출본 미확인 |

## 실행으로 확인한 내용
* PDF E-22 "다중컬럼 서브쿼리 SQL Server 지원 X" → Msg 4145로 일치한다. EXISTS나 JOIN으로 바꿔 쓴다.
* SQL Server의 ANY/ALL은 서브쿼리만 받는다. Oracle은 값 목록 `> ANY (1000, 3000)`도 받는다.
* 빈 집합에 ALL을 쓰면 항상 참, ANY는 항상 거짓이다(두 DBMS 같음).
* SQL Server 파생 테이블은 별칭이 필수다(Msg 102). Oracle은 선택이다.
* **검증 환경 주의(Oracle 21c XE 21.3)**: ex08 Q1 `HAVING AVG(sal) > (SELECT AVG(sal) FROM emp) ORDER BY deptno`가 정렬되지 않은 순서(20, 10)로 나왔다. 실행 계획의 `VW_WIF_1`(집계 서브쿼리를 윈도우 함수로 바꾸는 변환)과 관련 있어 보인다. `OPT_PARAM('_remove_aggr_subquery' 'false')`를 주면 10, 20으로 맞게 나온다. 23ai 계열에서도 맞게 나온다. **패치되지 않은 21.3 XE의 잘못된 결과로 판단한다.** 19c에서는 확인하지 못했다. SQL 표준상 정답은 10, 20이다.
