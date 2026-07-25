# 08. 예상 결과

미검증(12절 참고) — ANSI SQL 3값 논리 규칙을 근거로 도출한 예상값이다.
이 폴더는 Oracle·SQL Server 결과가 **완전히 동일**하다(문법 차이 없음).

## 공통 참고 — dept_code 분포

| customer_id | dept_code |
|---|---|
| 1 | D01 |
| 2 | D02 |
| 3 | D03 |
| 4 | NULL |
| 5 | D01 |
| 6 | D02 |
| 7 | D03 |
| 8 | D99(부서 테이블에 없는 값) |
| 9 | D01 |
| 10 | NULL |
| 11 | D02 |
| 12 | D03 |

`null_lab_excluded_codes` = `{'D02', 'D03', NULL}`

## STEP 1. NOT IN (원본, NULL 포함 서브쿼리)

```sql
WHERE dept_code NOT IN (SELECT dept_code FROM null_lab_excluded_codes)
```

| DBMS | 결과 행 수 |
|---|---|
| Oracle | **0** |
| SQL Server | **0** |

이유: `dept_code <> 'D02' AND dept_code <> 'D03' AND dept_code <> NULL`에서
마지막 항이 항상 UNKNOWN → AND 전체가 UNKNOWN → 모든 행이 WHERE에서 버려짐.

## STEP 2. NOT EXISTS

```sql
WHERE NOT EXISTS (SELECT 1 FROM null_lab_excluded_codes e WHERE e.dept_code = c.dept_code)
```

| customer_id | dept_code | 포함 여부 |
|---|---|---|
| 1 | D01 | 포함 |
| 2 | D02 | 제외(매칭됨) |
| 3 | D03 | 제외(매칭됨) |
| 4 | NULL | 포함 |
| 5 | D01 | 포함 |
| 6 | D02 | 제외(매칭됨) |
| 7 | D03 | 제외(매칭됨) |
| 8 | D99 | 포함 |
| 9 | D01 | 포함 |
| 10 | NULL | 포함 |
| 11 | D02 | 제외(매칭됨) |
| 12 | D03 | 제외(매칭됨) |

결과: customer_id **1, 4, 5, 8, 9, 10** → **6행** (Oracle·SQL Server 동일)

## STEP 3. NOT IN + 서브쿼리 IS NOT NULL

```sql
WHERE dept_code NOT IN (SELECT dept_code FROM null_lab_excluded_codes WHERE dept_code IS NOT NULL)
```

서브쿼리는 `{'D02', 'D03'}`만 반환(NULL 제거됨)하지만, 바깥 `dept_code`가
NULL인 4, 10행은 `dept_code <> 'D02' AND dept_code <> 'D03'` 자체가
UNKNOWN이라 여전히 제외된다.

결과: customer_id **1, 5, 8, 9** → **4행** (Oracle·SQL Server 동일)

## STEP 4. 세 방식 비교 (COUNT 요약)

| approach | row_count |
|---|---|
| NOT IN (원본, NULL 포함 서브쿼리) | 0 |
| NOT EXISTS | 6 |
| NOT IN (서브쿼리에 IS NOT NULL 추가) | 4 |

세 값이 모두 다르다는 것 자체가 이 폴더의 핵심 결론이다 — 겉보기엔 같은
의도의 조건이라도 NULL이 어디에 있느냐에 따라 결과가 완전히 달라진다.

## 12. 실제 실행 검증 여부

미검증. ANSI SQL 3값 논리 표준 규칙에 근거했으나, 이 세션에서 실제 DBMS로
실행해 재확인하지 않았다.
