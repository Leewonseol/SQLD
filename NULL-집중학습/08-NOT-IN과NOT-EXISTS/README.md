# 08. NOT IN과 NOT EXISTS — NULL이 섞인 서브쿼리의 함정

## 1. 학습 목표

- `NOT IN` 서브쿼리 결과에 NULL이 단 하나라도 섞이면 전체 결과가 **0행**이
  되어버리는 SQLD 최빈출 함정을 직접 실행으로 확인한다.
- 같은 의도를 `NOT EXISTS`(상관 서브쿼리)로 바꾸면 NULL이 섞여 있어도
  정상적으로 원하는 행이 나온다는 것을 확인한다.
- `NOT IN` 서브쿼리에 `IS NOT NULL`을 추가하는 안전한 대안이 서브쿼리의
  NULL은 없애지만, **바깥쪽(outer) 컬럼 자체가 NULL인 행**은 여전히
  걸러진다는 남은 함정까지 구분해서 이해한다.
- "NOT IN 서브쿼리에는 항상 NULL 가능성을 점검하라"는 실무/SQLD 공통의
  정석을 근거를 갖고 설명할 수 있게 된다.

## 2. 핵심 원리

- `col NOT IN (v1, v2, ..., vn)`은 SQL 내부적으로
  `col <> v1 AND col <> v2 AND ... AND col <> vn`으로 풀린다.
- 이 중 어느 `vi`라도 NULL이면 `col <> vi`는 `col`이 무엇이든 **항상
  UNKNOWN**이다(`00` 폴더 3값 논리 — 비교 연산자에 NULL이 관여하면 결과는
  항상 UNKNOWN). AND 체인에서 나머지 항이 전부 TRUE라도 하나가 UNKNOWN이면
  `TRUE AND TRUE AND UNKNOWN = UNKNOWN`이 되어 전체가 UNKNOWN이다.
  `WHERE`는 TRUE인 행만 통과시키므로(UNKNOWN은 FALSE와 똑같이 버려짐),
  서브쿼리에 NULL이 하나라도 있으면 **어떤 행도 NOT IN 조건을 만족할 수
  없다** — 그래서 전체가 0행이 된다.
- `NOT EXISTS (상관 서브쿼리)`는 다르다. `EXISTS`/`NOT EXISTS`는 "매칭되는
  행이 존재하는가"만 확인하는 **술어(predicate)**라서 그 자체는 절대
  UNKNOWN이 되지 않고 언제나 TRUE 또는 FALSE로만 평가된다. 서브쿼리 내부의
  `e.dept_code = c.dept_code` 비교가 NULL 때문에 UNKNOWN이 되어도, 그건
  "그 행은 매칭 후보에서 빠진다"는 뜻일 뿐 `EXISTS` 판정 자체를 UNKNOWN으로
  만들지 않는다 — 매칭되는 행이 하나도 없으면 `EXISTS`는 그냥 FALSE,
  `NOT EXISTS`는 TRUE다.
- 단, `NOT IN` 서브쿼리에 `IS NOT NULL`을 추가해 서브쿼리 자체를 깨끗하게
  만들어도 **바깥쪽(outer) 컬럼이 NULL인 행**은 여전히 걸러진다 —
  `col <> 'D02' AND col <> 'D03'`에서 `col`이 NULL이면 두 항 모두
  UNKNOWN이라 AND 결과도 UNKNOWN이기 때문이다. 이는 서브쿼리의 NULL 문제와
  **별개의 함정**이며, `NOT EXISTS`는 이 경우에도 영향을 받지 않는다
  (상관 조건 `e.dept_code = c.dept_code`가 매칭되는 행이 없으면 그냥
  `NOT EXISTS = TRUE`).

## 3. 공통 입력 데이터

`00-NULL의미와3값논리`와 완전히 같은 `null_lab_customer`/`null_lab_dept`/
`null_lab_excluded_codes`를 재사용한다. 이 폴더가 실제로 쓰는 부분:

- `null_lab_customer.dept_code` — D01(1,5,9), D02(2,6,11), D03(3,7,12),
  D99(8, `null_lab_dept`에 없는 값), NULL(4, 10).
- `null_lab_excluded_codes`(3행, `'D02'`, `'D03'`, `NULL`) — 이 폴더의
  핵심 실습 테이블. `NOT IN` 서브쿼리 결과에 NULL이 섞이는 상황을 만들기
  위해 일부러 NULL 한 행을 포함시켰다.

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — 공통 데이터셋 생성 후 4단계.

1. `dept_code NOT IN (SELECT dept_code FROM null_lab_excluded_codes)` → 0행
   (함정을 직접 실행으로 확인)
2. 같은 의도의 `NOT EXISTS` 상관 서브쿼리 → 정상적으로 6행
3. 서브쿼리에 `IS NOT NULL`을 추가한 안전한 `NOT IN` → 4행(바깥 NULL 행은
   여전히 제외됨을 확인)
4. 세 방식의 `COUNT(*)`를 `UNION ALL`로 한 번에 비교(0, 6, 4)

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — 로직과 결과 모두 Oracle과 완전히
동일하다. `NOT IN`의 NULL 함정과 `NOT EXISTS`의 안전함은 **ANSI SQL
표준의 3값 논리 자체에서 비롯된 것**이라 특정 DBMS의 문법 차이가 아니다 —
이 폴더는 `00`~`07`과 달리 Oracle/SQL Server 간에 결과값 차이가 전혀
없는 드문 주제다.

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고.

## 7. 결과 차이의 이유

이 폴더의 세 쿼리(0행 / 6행 / 4행)는 DBMS 차이가 아니라 **같은 데이터에
대해 서로 다른 SQL 구문을 썼을 때 3값 논리가 어떻게 다르게 작동하는가**를
보여준다.

- `NOT IN`(원본): 서브쿼리 결과에 NULL이 섞여 AND 체인 전체가 UNKNOWN →
  0행.
- `NOT EXISTS`: EXISTS 술어 자체가 TRUE/FALSE만 반환 → NULL이 섞여 있어도
  "매칭 안 됨"을 정확히 TRUE로 판정 → 6행(의도한 결과).
- `NOT IN` + 서브쿼리 `IS NOT NULL`: 서브쿼리는 깨끗해졌지만 바깥 컬럼이
  NULL인 행(4, 10)은 `col <> 'D02' AND col <> 'D03'` 자체가 UNKNOWN이라
  여전히 빠짐 → 4행. `NOT EXISTS`의 6행보다 2행 적다.

## 8. SQLD 함정

- **"NOT IN과 NOT EXISTS는 완전히 같은 결과를 낸다"는 착각** — 서브쿼리나
  바깥 컬럼에 NULL이 하나도 없을 때만 두 방식이 같은 결과를 낸다. 이
  데이터셋처럼 NULL이 섞이면 결과 행 수 자체가 달라진다.
- **"서브쿼리에 `IS NOT NULL`만 추가하면 NOT IN이 완전히 안전해진다"는
  착각** — 서브쿼리 쪽 NULL은 없앨 수 있지만, 바깥 컬럼이 NULL인 행은
  여전히 결과에서 빠진다. 완전히 `NOT EXISTS`와 동일한 결과를 원한다면
  처음부터 `NOT EXISTS`를 쓰는 것이 가장 안전하다.
- **`NOT IN`이 0행을 반환하면 "조건에 맞는 데이터가 없나 보다"라고 오판** —
  실제로는 데이터가 있어도 서브쿼리의 NULL 때문에 구조적으로 0행이 나온
  것일 수 있다. `NOT IN` 서브쿼리를 쓸 때는 습관적으로 그 서브쿼리 컬럼에
  NULL이 있는지부터 점검해야 한다.
- **NOT IN 서브쿼리 안에 NULL이 있는지 확인하지 않고 프로덕션에 배포** —
  실무에서 흔히 발생하는 실제 버그 패턴이다. 서브쿼리 대상 컬럼이 NULL을
  허용하는 컬럼이라면 원칙적으로 `NOT EXISTS`를 기본으로 쓰거나
  `WHERE 대상컬럼 IS NOT NULL`을 반드시 추가해야 한다.

## 9. 빅분기 결측치 처리와의 연결

빅데이터분석기사 실기의 pandas 파이프라인에서 `~df['dept_code'].isin(excluded_list)`
같은 필터를 쓸 때, `excluded_list`(파이썬 리스트나 Series)에 `NaN`/`None`이
섞여 있으면 pandas의 `isin()`은 SQL의 `NOT IN`과 달리 NaN을 "다른 모든
값과 다르다"고 취급해 조용히 계속 동작한다(SQL처럼 전체가 사라지지
않는다) — 즉 **pandas와 SQL이 NULL/NaN을 다루는 3값 논리 여부 자체가
다르다.** 데이터 파이프라인을 SQL에서 Python으로, 또는 그 반대로 옮길 때
이 차이를 모르면 "SQL에서는 0행이 나왔는데 pandas에서는 잘 걸러지네"
같은 불일치를 겪게 된다 — 결측치 필터링 로직을 옮길 때는 반드시 각 도구의
NULL/NaN 비교 규칙을 따로 확인해야 한다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) 참고.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증** — 이 세션에는 두 DBMS를 실행할 환경이
없다(저장소 루트 `README.md` §5, `../README.md` 참고). `NOT IN`/`NOT EXISTS`의
3값 논리 동작은 ANSI SQL 표준과 각 벤더 공식 문서에 근거해 작성했으며,
`oracle.sql`/`sqlserver.sql`은 각자의 환경에 그대로 복사해 실행할 수 있는
완전한 스크립트다. 실행했다고 보고하지 않는다 — 실제 결과는 각 환경에서
재확인이 필요하다.
