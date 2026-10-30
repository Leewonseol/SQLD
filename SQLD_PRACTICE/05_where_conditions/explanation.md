# 05 WHERE — 단원 안내

학습 흐름에서의 위치: **FROM·JOIN·ON → WHERE**. WHERE는 FROM이 만든 중간 결과의 **각 행**에 조건을 적용한다.
조건이 TRUE인 행만 다음 단계(GROUP BY)로 넘어간다. FALSE와 **UNKNOWN(NULL 비교)** 인 행은 모두 버려진다.
WHERE는 행 단위로 평가하므로 여러 행을 요약하는 집계함수를 쓸 수 없다(PDF E-06).

| 실습 | 주제 | 근거 |
|---|---|---|
| [ex01](examples/ex01_operators_precedence.md) | 비교·논리·부정 연산자, 연산자 우선순위 | PDF E-06 |
| [ex02](examples/ex02_in_not_in.md) | IN, NOT IN과 NULL, 다중 컬럼 IN | PDF E-06, §7 |
| [ex03](examples/ex03_like.md) | LIKE `%` `_` ESCAPE, 대소문자 | PDF E-06, §7 |
| [ex04](examples/ex04_between.md) | BETWEEN 경계, 날짜·시각 함정 | PDF E-06, §7 |
| [ex05](examples/ex05_null_three_valued.md) | NULL과 3값 논리, `''`와 NULL | PDF E-06, §7 |
| [ex06](examples/ex06_aggregate_in_where.md) | WHERE의 집계함수 금지 → HAVING·서브쿼리 | PDF E-06 |
| [ex07](examples/ex07_type_conversion_in_where.md) | 비교 자료형 일치와 암시적 형변환 | PDF E-06 |

## 이 단원에서 실행으로 확인한 DBMS 차이
| 항목 | Oracle 21c | SQL Server 2022 |
|---|---|---|
| `^=` 부정 연산자 | 지원 | 구문 오류 Msg 102 |
| 다중 컬럼 `(a,b) IN ((..),(..))` | 지원 | Msg 4145 |
| LIKE 대소문자 | 구분(기본 BINARY) | 구분 안 함(기본 데이터 정렬 `SQL_Latin1_General_CP1_CI_AS`) |
| LIKE `[ ]` 문자 집합 | 없음 | 지원 |
| 빈 문자열 `''` | NULL로 취급 | NULL이 아닌 값 |
| `SET ANSI_NULLS OFF` | 없음 | `= NULL`이 참이 됨(비권장) |
| 문자 컬럼 = 숫자 상수 | 컬럼을 TO_NUMBER, 실패 시 ORA-01722 | 자료형 우선순위로 INT 변환, 실패 시 Msg 245 (실패 전 행이 일부 출력됨) |
| AVG 결과 표시 | 2916.66666…(ROUND 시 2916.67) | DECIMAL 평균은 소수 6자리 `2916.670000` |
