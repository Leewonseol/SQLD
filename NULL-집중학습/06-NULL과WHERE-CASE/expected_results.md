# 06. 예상 결과

미검증(12절 참고) — Oracle과 SQL Server의 3값 논리·CASE 처리는 ANSI SQL
표준 공통 규칙이므로 두 DBMS 결과는 완전히 동일하다.

## STEP 1. `WHERE score > 80 AND dept_code = 'D01'`

결과: **customer_id = 1** 딱 1행 (score=85, dept_code='D01').

전체 12행 T/F/U 분류(Oracle·SQL Server 공통):

| customer_id | score | dept_code | score_gt80 | dept_eq_d01 | and_result | 빠진 이유 |
|---|---|---|---|---|---|---|
| 1 | 85 | D01 | T | T | PASS(T) | (통과) |
| 2 | 92 | D02 | T | F | FAIL(F) | 확정 FALSE |
| 3 | NULL | D03 | U | F | FAIL(F) | 확정 FALSE (dept_code 불일치가 결정) |
| 4 | 77 | NULL | F | U | FAIL(F) | 확정 FALSE (score가 결정) |
| 5 | 60 | D01 | F | T | FAIL(F) | 확정 FALSE |
| 6 | 0 | D02 | F | F | FAIL(F) | 확정 FALSE |
| 7 | 88 | D03 | T | F | FAIL(F) | 확정 FALSE |
| 8 | 95 | D99 | T | F | FAIL(F) | 확정 FALSE |
| 9 | NULL | D01 | U | T | **FAIL(U)** | **진짜 UNKNOWN** |
| 10 | 70 | NULL | F | U | FAIL(F) | 확정 FALSE (score가 결정) |
| 11 | 82 | D02 | T | F | FAIL(F) | 확정 FALSE |
| 12 | 99 | D03 | T | F | FAIL(F) | 확정 FALSE |

12행 중 NULL이 실제로 관여한 행은 3, 4, 9, 10 네 개지만, **UNKNOWN 때문에
진짜로 빠진 행은 9뿐**이다. 3, 4, 10은 다른 조건이 확정적 FALSE라서
단축평가로 빠졌다.

## STEP 2. Simple CASE (`CASE dept_code WHEN NULL THEN ...`)

| customer_id | dept_code | simple_case_result |
|---|---|---|
| 1 | D01 | ELSE로 떨어짐 |
| 4 | NULL | **ELSE로 떨어짐** |
| 8 | D99 | ELSE로 떨어짐 |
| 10 | NULL | **ELSE로 떨어짐** |

dept_code가 실제 NULL인 4, 10행도 'NULL부서' 분기를 타지 못한다.

## STEP 3. Searched CASE (`CASE WHEN dept_code IS NULL THEN ...`)

| customer_id | dept_code | searched_case_result |
|---|---|---|
| 1 | D01 | 부서 있음 |
| 4 | NULL | **NULL부서(정상 판정)** |
| 8 | D99 | 부서 있음 |
| 10 | NULL | **NULL부서(정상 판정)** |

## STEP 4. `WHERE score > 80` vs `WHERE (CASE WHEN score > 80 THEN 'Y' END) = 'Y'`

두 쿼리 모두 동일하게 **customer_id = 1, 2, 7, 8, 11, 12** (6행) 반환.

| customer_id | score | 원래 조건(score>80) | CASE 결과 | 배제 이유 |
|---|---|---|---|---|
| 3 | NULL | UNKNOWN | NULL | CASE도 UNKNOWN 반환 → 배제 |
| 4 | 77 | FALSE | NULL(ELSE 없음) | 원래는 FALSE인데 CASE를 거치며 NULL로 바뀜 → 배제 |
| 9 | NULL | UNKNOWN | NULL | CASE도 UNKNOWN 반환 → 배제 |
| 10 | 70 | FALSE | NULL(ELSE 없음) | 원래는 FALSE인데 CASE를 거치며 NULL로 바뀜 → 배제 |

결과 행 집합은 같지만, 4·10행은 "원래 FALSE였던 조건"이 ELSE 없는 CASE를
거치면서 NULL(UNKNOWN)로 성격이 바뀐다는 점이 핵심 관찰이다.

## 12. 실제 실행 검증 여부

미검증. 3값 논리와 CASE의 NULL 처리는 ANSI SQL 표준에 근거했으나, 이
세션에서 실제 DBMS로 실행해 재확인하지 않았다.
