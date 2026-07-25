# 11. 예상 결과

미검증(12절 참고) — 각 DBMS 공식 문서의 표준 동작을 근거로 도출한 예상값이다.

## STEP 1. CHECK 제약조건과 NULL (`null_lab_check_demo`, `CHECK (score >= 0)`)

| INSERT | score | 조건 평가 | Oracle 결과 | SQL Server 결과 |
|---|---|---|---|---|
| demo_id=1 | 50 | TRUE | 성공 | 성공 |
| demo_id=2 | NULL | UNKNOWN | **성공**(직관과 다름) | **성공**(직관과 다름) |
| demo_id=3(주석 처리) | -10 | FALSE | 실패(위반 에러) | 실패(위반 에러) |

최종 `null_lab_check_demo` 내용(두 DBMS 동일): `(1, 50)`, `(2, NULL)` — 2행.

## STEP 2. UNIQUE 제약조건과 NULL (`null_lab_unique_demo`, `email UNIQUE`)

| INSERT | email | Oracle 결과 | SQL Server 결과 |
|---|---|---|---|
| demo_id=1 | 'a@test.com' | 성공 | 성공 |
| demo_id=2 | NULL | 성공(첫 NULL) | 성공(첫 NULL) |
| demo_id=3 | NULL | **성공**(NULL 여러 번 허용) | **실패**(UNIQUE 위반 — NULL 1개만 허용) |

최종 `null_lab_unique_demo` 내용:

| DBMS | 최종 행 |
|---|---|
| Oracle | `(1,'a@test.com')`, `(2,NULL)`, `(3,NULL)` — 3행 |
| SQL Server | `(1,'a@test.com')`, `(2,NULL)` — 2행(demo_id=3 INSERT 실패) |

## STEP 3. PRIMARY KEY와 NULL (공통)

| INSERT | Oracle 결과 | SQL Server 결과 |
|---|---|---|
| `(demo_id=NULL, score=10)` | 실패(`ORA-01400: cannot insert NULL into ...DEMO_ID`) | 실패(`Cannot insert the value NULL into column 'demo_id' ...`) |

두 DBMS 모두 PK 컬럼에는 NULL을 절대 허용하지 않는다 — 유일하게 예외
없는 공통 규칙.

## STEP 4. FOREIGN KEY와 NULL (`null_lab_fk_demo`, `dept_code` → `null_lab_dept`)

| INSERT | dept_code | Oracle 결과 | SQL Server 결과 |
|---|---|---|---|
| demo_id=1 | 'D01' | 성공(부모 존재) | 성공(부모 존재) |
| demo_id=2 | NULL | 성공(FK는 NULL 허용) | 성공(FK는 NULL 허용) |
| demo_id=3(주석 처리) | 'D99' | 실패(`ORA-02291: parent key not found`) | 실패(FOREIGN KEY 제약 위반) |

최종 `null_lab_fk_demo` 내용(두 DBMS 동일): `(1,'D01')`, `(2,NULL)` — 2행.

## 요약 — 이 폴더의 핵심 결론

| 제약조건 | NULL을 만나면 | Oracle | SQL Server |
|---|---|---|---|
| CHECK | 조건이 UNKNOWN → 통과(위반 아님) | 통과 | 통과 |
| UNIQUE | 몇 번까지 허용? | 여러 번 허용 | **1번만 허용** |
| PRIMARY KEY | 허용? | 허용 안 함 | 허용 안 함 |
| FOREIGN KEY | 허용? | 허용 | 허용 |

## 12. 실제 실행 검증 여부

미검증. Oracle/SQL Server 공식 문서와 ANSI SQL 표준의 제약조건 NULL 처리
규칙에 근거했으나, 이 세션에서 실제 DBMS로 실행해 재확인하지 않았다.
