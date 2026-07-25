# 11. NULL과 제약조건 — CHECK / UNIQUE / PRIMARY KEY / FOREIGN KEY

## 1. 학습 목표

- `CHECK` 제약조건이 특정 행에서 UNKNOWN으로 평가되면 그 행이 제약을
  **통과한다**(위반이 아니다)는 것을 실제 INSERT로 확인한다 — `WHERE`가
  UNKNOWN을 버리는 것과 정반대라는 것을 이해한다.
- `UNIQUE` 제약조건에서 NULL을 몇 번까지 허용하는지가 Oracle과 SQL
  Server에서 **다르다**는 것을 직접 실행으로 확인한다.
- `PRIMARY KEY`는 두 DBMS 모두 NULL을 절대 허용하지 않는다는 공통점을
  확인한다.
- `FOREIGN KEY` 컬럼에는 NULL이 허용되며, 이것이 부모 테이블과 매칭할
  필요가 없는 상태로 취급되기 때문이라는 것을 이해한다.

## 2. 핵심 원리

- **CHECK와 NULL**: `CHECK` 제약조건은 그 조건식이 **FALSE로 평가되는
  행만** 위반으로 거부한다. TRUE는 물론이고 **UNKNOWN도 위반이 아니라서
  통과**시킨다. `CHECK (score >= 0)`가 걸린 컬럼에 `score = NULL`인 행을
  넣으면 `NULL >= 0`은 UNKNOWN이고, UNKNOWN은 FALSE가 아니므로 그 INSERT는
  **성공한다.** 이는 `WHERE`(그리고 `06` 폴더의 `CASE WHEN`)가 TRUE인
  행만 통과시키고 UNKNOWN을 FALSE와 똑같이 버리는 것과 **정확히 반대되는
  방향**이다 — "제약조건을 통과했다"가 "값이 조건을 실제로 만족했다"는
  뜻이 아닐 수 있다는 것이 이 폴더 최대의 함정이다.
- **UNIQUE와 NULL — DBMS 차이**: 표준 SQL과 Oracle은 `UNIQUE` 컬럼에
  NULL을 **여러 번** 허용한다. NULL은 비교 연산에서 서로 "같다"고
  판정되지 않으므로(3값 논리, `00`/`01` 폴더) 유일성 위반의 근거가 될 수
  없다고 보기 때문이다. **SQL Server의 일반 `UNIQUE` 제약조건/인덱스는
  NULL을 딱 한 번만 허용한다** — 두 번째 NULL을 넣으면 유일성 위반
  에러가 난다. 이는 Microsoft 공식 문서에 명시된, 표준/Oracle과 다른
  SQL Server 고유의 동작이다.
- **PRIMARY KEY와 NULL**: 두 DBMS 모두 PK 컬럼에는 NULL을 절대 허용하지
  않는다(공통). PK는 내부적으로 `NOT NULL` + `UNIQUE`가 합쳐진 제약이라,
  UNIQUE의 DBMS별 NULL 허용 개수 차이(0개 vs 1개 이상)와 무관하게 PK는
  항상 0개다.
- **FOREIGN KEY와 NULL**: FK 컬럼에 NULL은 허용된다 — "이 행은 부모
  테이블의 어떤 행과도 관계를 맺지 않는 상태"로 취급되기 때문이다. 반면
  NULL이 아닌 값인데 부모 테이블에 그 값이 없으면(예: `'D99'`) FK
  위반이다. "NULL은 봐주지만 잘못된 실제 값은 안 봐준다"는 점에서
  `CHECK` 제약조건과 같은 결의 원리다.

## 3. 공통 입력 데이터

`00-NULL의미와3값논리`와 완전히 같은 `null_lab_customer`/`null_lab_dept`/
`null_lab_excluded_codes`를 재사용한다. 이 폴더는 추가로 전용 데모
테이블 3개를 정의한다(두 DBMS 파일에 동일하게 정의).

- `null_lab_check_demo`(`demo_id` PK, `score` + `CHECK (score >= 0)`) —
  CHECK와 NULL 실습.
- `null_lab_unique_demo`(`demo_id` PK, `email` UNIQUE) — UNIQUE와 NULL의
  DBMS별 차이 실습.
- `null_lab_fk_demo`(`demo_id` PK, `dept_code` + `null_lab_dept` 참조
  FK) — FK와 NULL 실습. `null_lab_customer.dept_code`에는 이미 부모에
  없는 값(`'D99'`, customer_id=8)이 있어 그 테이블에 직접 FK를 걸면
  기존 데이터 때문에 즉시 실패하므로, NULL 허용 여부만 깔끔하게 보기
  위해 별도 테이블을 둔다.

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — 공통 데이터셋 생성 후 4단계.

1. `null_lab_check_demo`에 `score=NULL`인 행을 INSERT — 성공(직관과
   다름)
2. `null_lab_unique_demo`에 NULL을 두 번 INSERT — **둘 다 성공**
3. PK 컬럼에 NULL을 INSERT하는 시도 — 에러(주석 처리된 데모)
4. `null_lab_fk_demo`에 NULL dept_code를 INSERT — 성공, 참고로
   `null_lab_customer`에 `ENABLE NOVALIDATE` FK를 거는 예시 주석

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — STEP 1, 3, 4는 Oracle과 결과가
같다. STEP 2가 Oracle과 가장 크게 갈리는 지점 — 두 번째 NULL INSERT가
**실패**한다.

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고.

## 7. 결과 차이의 이유

`CHECK`가 UNKNOWN을 통과시키는 규칙과 `PRIMARY KEY`/`FOREIGN KEY`의 NULL
허용 규칙은 ANSI SQL 표준에 정의된 공통 규칙이라 Oracle과 SQL Server가
같은 결과를 낸다. 유일하게 갈리는 것은 `UNIQUE` 제약조건의 NULL 허용
개수다 — ANSI SQL 표준은 이 부분을 벤더가 자유롭게 구현하도록 남겨뒀고
(표준 자체가 "NULL은 서로 다르다고 봐야 한다"와 "그래도 구현은 하나만
허용해도 표준 위반이 아니다"를 모두 허용하는 회색지대), Oracle은 3값
논리 원칙(NULL은 비교 불가하므로 무제한 허용)을 그대로 따랐고 SQL
Server는 실무적 이유로 NULL도 "유일해야 하는 값 하나"로 취급해 1개까지만
허용하는 쪽을 선택했다. 이는 옳고 그름의 문제가 아니라 벤더의 설계
선택 차이다.

## 8. SQLD 함정

- **"CHECK 제약조건은 값이 조건을 실제로 만족할 때만 통과시킨다"는
  착각** — NULL이라서 UNKNOWN이 된 행도 통과한다. "제약조건 통과 =
  값이 유효함"이 아니라 "제약조건 통과 = FALSE가 아님"이라는 것을
  정확히 기억해야 한다.
- **"UNIQUE는 어느 DBMS든 NULL을 무제한 허용한다"는 암기 함정** —
  SQL Server의 일반 UNIQUE 제약조건/인덱스는 NULL을 1개만 허용한다.
  두 번째 NULL부터는 에러가 난다는 것을 놓치면 시험에서 결과 예측을
  틀린다(SQL Server의 필터링된 유니크 인덱스(`WHERE col IS NOT NULL`을
  포함한 인덱스)를 쓰면 이 제한을 우회할 수 있지만, 이는 이 저장소의
  실습 범위를 넘는 고급 주제다).
- **"NULL이 들어간 값은 뭐든 제약조건을 통과 못한다"는 반대 방향 착각** —
  오히려 CHECK/FK는 NULL에 관대하다. 엄격한 건 PRIMARY KEY뿐이다.
- **"CHECK로 특정 컬럼을 NULL이 못 들어오게 막을 수 있다"는 착각** —
  `CHECK (col >= 0)` 같은 조건은 col이 NULL이면 통과시켜버리므로 NULL을
  막는 수단이 될 수 없다. NULL을 막으려면 `NOT NULL` 제약을 별도로
  걸어야 한다.

## 9. 빅분기 결측치 처리와의 연결

빅데이터분석기사 실기에서 원본 데이터를 DB에 적재하기 전에 결측치를
어떻게 처리할지 결정할 때, "DB 제약조건이 결측치를 걸러줄 것"이라고
기대하면 안 된다는 것이 이 폴더의 실무적 결론이다 — `CHECK` 제약조건은
결측(NULL)행을 걸러내지 못하고 통과시킨다. 따라서 특정 컬럼에 결측이
있으면 안 되는 비즈니스 규칙이 있다면 `CHECK`가 아니라 `NOT NULL`을
명시적으로 걸어야 하며, 적재 파이프라인(ETL) 단계에서 `pandas`의
`dropna()`/`fillna()` 같은 별도의 결측치 처리 로직으로 사전에 정제하는
것이 안전하다. DB 제약조건에만 의존해 데이터 품질을 보장하려는 설계는
NULL 관련 함정에 취약하다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) 참고.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증** — 이 세션에는 두 DBMS를 실행할 환경이
없다(저장소 루트 `README.md` §5, `../README.md` 참고). `CHECK` 제약조건의
3값 논리 처리, SQL Server `UNIQUE` 제약조건의 NULL 1개 제한, `PRIMARY
KEY`/`FOREIGN KEY`의 NULL 허용 규칙은 각 벤더 공식 문서(Microsoft Learn의
`UNIQUE Constraints and Check Constraints` 문서 등)와 ANSI SQL 표준에
근거해 작성했으며, `oracle.sql`/`sqlserver.sql`은 각자의 환경에 그대로
복사해 실행할 수 있는 완전한 스크립트다. 실행했다고 보고하지 않는다 —
실제 결과는 각 환경에서 재확인이 필요하다.
