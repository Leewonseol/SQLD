# 07. NULL과 JOIN / 집합연산 — JOIN 키 NULL, UNION/INTERSECT/MINUS(EXCEPT)

## 1. 학습 목표

- JOIN 키(`dept_code`)에 NULL이나 대응 값이 없는 코드가 있을 때
  `INNER JOIN`과 `LEFT JOIN`의 결과가 어떻게 달라지는지 직접 확인한다.
- JOIN의 `ON` 조건도 결국 `=` 비교이므로 `NULL = NULL`이 여전히 UNKNOWN이라
  NULL끼리도 서로 매칭되지 않는다는 것을 재확인한다.
- 반대로 **집합연산(`UNION`/`INTERSECT`/`MINUS`(Oracle)/`EXCEPT`(SQL
  Server))은 행을 비교할 때 NULL과 NULL을 "같다"고 취급한다**는, `=`
  비교와 정반대되는 규칙을 실제 쿼리로 증명한다.

## 2. 핵심 원리

- `INNER JOIN ... ON c.dept_code = d.dept_code`는 `dept_code`가 NULL인 행
  (customer_id 4, 10)과 대응 부서가 없는 값('D99', customer_id 8)을
  결과에서 완전히 제외한다 — `ON` 조건이 UNKNOWN이거나 FALSE인 행은 다른
  `WHERE`와 마찬가지로 버려지기 때문이다.
- `LEFT JOIN`은 왼쪽 테이블(`null_lab_customer`)의 행을 모두 보존하고,
  매칭되는 오른쪽 행이 없으면 오른쪽 테이블의 컬럼(`dept_name`)을 NULL로
  채운다 — 그래서 4, 8, 10행도 결과에 남되 `dept_name`이 NULL이 된다.
- **`=` 비교에서 NULL = NULL은 UNKNOWN**이다(00/01 폴더에서 이미 확인) —
  JOIN의 `ON` 절도 예외가 아니라서, `dept_code`가 둘 다 NULL인 두 행을
  SELF JOIN으로 이어붙이려 해도 절대 매칭되지 않는다.
- **집합연산(`UNION`의 중복 제거, `UNION`이 아닌 `INTERSECT`/`MINUS`/
  `EXCEPT`)은 행을 비교할 때 NULL과 NULL을 "같은 값"으로 취급**한다. 이는
  `=` 비교 규칙과 정반대다 — `WHERE a = b`에서는 `a`, `b`가 둘 다 NULL이어도
  UNKNOWN이라 TRUE가 될 수 없지만, `UNION`으로 두 결과 집합을 합칠 때는
  두 NULL 행이 "중복"으로 인식되어 하나로 합쳐진다.

## 3. 공통 입력 데이터

`00-NULL의미와3값논리`와 완전히 같은 `null_lab_customer`/`null_lab_dept`/
`null_lab_excluded_codes`를 재사용한다. 이 폴더의 핵심 컬럼은
`null_lab_customer.dept_code`(customer_id 4,10=NULL, 8=`'D99'` 불일치,
나머지는 `null_lab_dept`의 `D01`/`D02`/`D03`와 정상 매칭)와
`null_lab_dept.dept_code`(PK, 3행)다. 자세한 배치는
[`../README.md`](../README.md)의 "공통 테스트 데이터" 표 참고.

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — 공통 데이터셋 생성 후 4단계로 진행한다.

1. `INNER JOIN`(9행, 4/8/10 제외)과 `LEFT JOIN`(12행, 4/8/10은
   `dept_name` NULL)을 나란히 실행해 비교
2. `NULL = NULL`이 여전히 UNKNOWN임을 리터럴 비교와 SELF JOIN(customer_id
   4와 10)으로 재확인 — 0행
3. `dept_code`가 NULL인 4, 10행의 `dept_code`만 뽑아 `UNION`(1행으로
   합쳐짐)과 `UNION ALL`(2행 그대로 남음)을 비교
4. 같은 두 집합에 `INTERSECT`(1행)와 `MINUS`(0행)를 적용해 규칙이 일관됨을 확인

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — 로직과 결과는 Oracle과 완전히 같다.
문법 차이는 딱 하나, Oracle의 `MINUS`가 SQL Server에서는 `EXCEPT`라는 것뿐이다
(NULL 취급 규칙은 동일).

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고.

## 7. 결과 차이의 이유

JOIN의 `ON` 조건과 집합연산의 행 비교 규칙 모두 ANSI SQL 표준에 정의되어
있어 Oracle과 SQL Server의 계산 결과는 완전히 같다. 두 규칙이 겉보기에
모순돼 보이는 이유는 목적이 다르기 때문이다 — `=`는 "이 두 값이 같은지
판정"하는 연산이라 정보가 없으면(NULL) 판정을 유보(UNKNOWN)하지만,
`UNION`/`INTERSECT`/`MINUS`(`EXCEPT`)는 "이 두 행을 같은 그룹으로 묶을지"를
정하는 **집합 소속 판정**이라 표준이 아예 별도 규칙(NULL을 그룹화 목적으로는
"같다"고 취급)을 정의해 둔 것이다. `GROUP BY`와 `DISTINCT`도 같은 이유로
NULL을 하나의 그룹으로 묶는다(집합연산과 동일한 계열의 규칙).

## 8. SQLD 함정

| 상황 | `=` 비교(WHERE, JOIN ON) | 집합연산(UNION 중복제거, INTERSECT, MINUS/EXCEPT) |
|---|---|---|
| NULL과 NULL을 비교하면? | **UNKNOWN** (절대 TRUE 아님) | **"같다"고 취급** |
| dept_code가 둘 다 NULL인 두 행 | JOIN에서 서로 매칭되지 않음 | UNION에서 중복으로 묶여 1행이 됨 |

- **"NULL이 관여하는 비교는 항상 UNKNOWN이니 집합연산에서도 중복 제거가
  안 될 것"이라는 착각** — `UNION`/`INTERSECT`/`MINUS`(`EXCEPT`)는 예외적으로
  NULL을 "같다"고 취급해서 중복을 제거하거나 교집합/차집합을 계산한다.
- **"JOIN 키가 둘 다 NULL이면 서로 매칭될 것"이라는 착각** — JOIN의 `ON`은
  결국 `=` 비교라서 NULL끼리도 절대 매칭되지 않는다. NULL을 강제로 매칭하고
  싶다면 `ON (c.dept_code = d.dept_code OR (c.dept_code IS NULL AND
  d.dept_code IS NULL))`처럼 명시적으로 조건을 추가해야 한다.
- **"INNER JOIN 결과가 적으면 데이터가 없는 것"이라고 오판하는 함정** —
  실제로는 데이터(고객 12명)가 다 있어도 JOIN 키의 NULL/불일치 때문에 3명이
  결과에서 빠진 것뿐이다. `LEFT JOIN`으로 먼저 전체를 보고 `dept_name IS
  NULL`인 행을 따로 확인하는 습관이 필요하다.
- **`GROUP BY dept_code`도 NULL을 하나의 그룹으로 묶는다는 것을 놓치는
  함정** — `WHERE dept_code = dept_code`류 자기비교와 달리 `GROUP BY`는
  집합연산과 같은 계열의 규칙을 따른다(NULL 그룹 하나만 생김).

## 9. 빅분기 결측치 처리와의 연결

`pandas.merge`(SQL의 JOIN에 대응)는 기본적으로 결측 키(`NaN`)를 서로
매칭시키지 않는다(SQL의 `=` 규칙과 동일한 결과). 반면 `pandas.concat` +
`drop_duplicates()`(SQL의 `UNION`에 대응)는 `NaN`과 `NaN`을 같은 값으로
보고 중복을 제거한다 — SQL의 "JOIN은 NULL을 안 묶고, 집합연산은 NULL을
묶는다"는 비대칭이 pandas에도 그대로 나타난다. 결측치가 있는 키로 데이터를
병합(merge)할지, 단순히 합쳐서 중복만 제거(concat + drop_duplicates)할지를
정할 때 이 비대칭을 모르면 예상보다 행이 적게 남거나(merge) 예상과 다르게
합쳐지는(drop_duplicates) 실수를 하기 쉽다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) 참고.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증** — 이 세션에는 두 DBMS를 실행할 환경이
없다(`../README.md`, 저장소 루트 `README.md` §5 참고). `oracle.sql`/
`sqlserver.sql`은 문법·NULL 처리 규칙 기준으로 작성한 완전한 스크립트이며,
사용자가 각자의 Oracle/SQL Server 환경에 그대로 복사해 실행할 수 있다.
실행했다고 보고하지 않는다 — 실제 결과는 각 환경에서 재확인이 필요하다.
