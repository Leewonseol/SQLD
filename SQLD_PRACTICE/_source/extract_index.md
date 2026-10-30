# 텍스트 추출본 조각 색인 (E-01 ~ E-38)

* 출처는 Drive `read_file_content`로 받은 `2024개정판_SQLD_개념정리.pdf`의 텍스트 추출본이다.
* 페이지 번호는 **없다**. 순서는 추출본에 나온 순서다.
* 인용은 추출본 문구를 그대로 옮겼다. 오탈자도 고치지 않았다. `[…]`는 생략 표시다.
* 오른쪽 열은 PDF 서술을 실제 DBMS 실행 결과와 대조할 항목이다. 대조 결과는 각 실습 문서의 "외부검증" 칸에 따로 적었다.

| ID | 추출본 위치(절 표기) | 원문 인용(요약) | 실행으로 대조할 PDF 서술 |
|---|---|---|---|
| E-01 | 정규화 / 3차 정규화 | "제 3차 정규화를 통해 사원 테이블은 사원 테이블과 부서 테이블로 분해 […] 조인을 사용해야 한다", "조인 키는 보통 외래 키로 설정된다" (사원 2401 김지민 100 영업부 서울 …) | 분해 후 JOIN으로 원래 테이블이 복원되는가 |
| E-02 | 4. 관계형 데이터 모델 | "자기 자신끼리의 관계 […] 셀프 조인", 직원(직원ID, 이름, 상사ID) 1 나사장 NULL, 2 김철수 1, 3 이지현 1, 4 황수지 2, 박현석 3 | PDF 쿼리 `WHERE a.직원ID = b.상사ID`의 별칭 의미와 결과표(나사장-NULL 행 포함)가 일치하는가 |
| E-03 | 관계형 데이터 모델 | "FK는 자기 자신이 속한 릴레이션을 참조할 수 있다. ex) 멘토" | 자기참조 FK 생성 가능 여부 |
| E-04 | 제 2절 SELECT 문 / 1. SQL 문장들의 종류 | DML(SELECT·INSERT·UPDATE·DELETE), DDL(CREATE·ALTER·DROP·RENAME), DCL(GRANT·REVOKE), TCL(COMMIT·ROLLBACK), "추가 DDL: TRUNCATE(오토커밋이라) DML: MERGE TCL: SAVEPOOINT + DQL: SELECT", "DML: 사용자가 COMMIT 해야 함", "DDL: AUTO COMMIT ROLLBACK 불가능" | DDL 자동 커밋: Oracle과 SQL Server에서 실제로 같은가 |
| E-05 | 2. SELECT 문의 구조 | "6개의 절로 구성", 작성 순서 SELECT-FROM-WHERE-GROUP BY-HAVING-ORDER BY, "(GROUPBY HAVING의 순서는 서로 바꿀 수 있으나 보통 사용 X)", 논리적 실행순서 FROM-WHERE-GROUP BY-HAVING-SELECT-ORDER BY (1)~(6) | HAVING을 GROUP BY 앞에 써도 실행되는가 |
| E-06 | 제 4절 WHERE 문 | "NULL은 ''로 조회가 불가능, IS NULL / IS NOT NULL", "비교 대상끼리 데이터 타입이 일치하는 것이 좋음", "집계 함수 사용 불가", 연산자 표(비교·SQL·논리·부정), 우선순위 1 괄호 2 NOT 3 비교·SQL 4 AND 5 OR | WHERE에 집계함수를 쓰면 어떤 오류가 나는가, 우선순위 |
| E-07 | DUAL 테이블의 특성 | "23c이전 버전의 오라클에서는 SELECT 문 작성시 FROM 절 필수", "(Sybase나 SQL Server의 경우 SELECT 절만으로도 수행 가능)", SYS 소유, "DUMMY라는 문자열 유형의 칼럼에 'X'" | 21c에서 FROM 생략 시 오류, 23ai에서는 허용되는가 |
| E-08 | 제6절 ORDER BY 절 | "ORDER BY 절을 명시해야 데이터 정렬", 기본 ASC, "유일하게 SELECT 절에 정의한 컬럼 별칭 사용 가능", "ORACLE에서 NULL 은 최댓값, SQL Server에서는 최솟값", "NULL LAST \| NULL FISRT", "GROUP BY로 그룹화를 했을 시 ORDER BY에 올 수 있는 컬럼은 SELECT 절에 있는 컬럼만 가능" | NULL 정렬 위치, GROUP BY 후 SELECT에 없는 그룹 컬럼·집계로 정렬 가능한가 |
| E-09 | 3. EQUI JOIN | "보통 PK FK 관계를 기반 […] (반드시 PK FK 의 관계로만 EQUI JOIN이 성립한다는 게 아님)", Oracle WHERE / ANSI INNER JOIN ON, PLAYER·TEAM GK 예제, "ALIAS를 적용했을 경우 […] 본래 테이블명이 아닌 ALIAS를 사용해야만 한다 […] 오류" | 별칭 지정 후 원래 테이블명 사용 시 오류 코드 |
| E-10 | 3. NON EQUI JOIN | EMP(SMITH 800, ALLEN 1600, WARD 1250, JONES 2975, MARTIN 1280, KING 8000), SALGRADE(1 800-1200, 2 1201-1400, 3 1401-2000, 4 2001-3000, 5 3001-9999), 결과표 | 결과표와 실제 결과 일치 |
| E-11 | 4. 3개 이상의 테이블 조인 | "3개의 테이블 조인이면 최소 2개의 조인 조건 필요", PLAYER·TEAM·STADIUM | — |
| E-12 | 5. SELF JOIN | "FROM 절에 동일 테이블이 2번 이상 […] 반드시 테이블 ALIAS", EMPLOYEES(100 KING, 101 ALLEN 100, 102 WARD 100, 103 JONES 102, 104 MARTIN 101, 105 SMITH 103), 쿼리 `WHERE E1.EMP_ID = E2.EMP_ID`, 결과 5행, "MANAGER_ID NULL인 KING은 조건에 맞지 않으니 제외", "OUTER JOIN을 사용해야" | PDF 쿼리 조건(`E1.EMP_ID = E2.EMP_ID`)이 실제로 PDF 결과표를 만드는가 |
| E-13 | 제 8절 표준 조인 | ANSI INNER/CROSS/NATURAL/OUTER JOIN, 순수 관계 연산자 SELECT·PROJECT·(NATURAL) JOIN·DIVIDE, "SELECT → WHERE 절로 구현", "PROJECT → SELECT 절로 구현", "DIVIDE 연산 현재 사용X" | DIVIDE를 SQL로 구현 |
| E-14 | 3. INNER JOIN | "JOIN 조건이 일치하는 행만 반환", "ANSI 표준에서는 USING 조건절이나 ON 조건절이 필수", "JOIN으로 생략 가능" | INNER JOIN에서 ON 생략 시 오류 |
| E-15 | 4. ON 조건절 | "컬럼명이 서로 달라도 사용 가능", "ON 조건절: JOIN 조건 명시, WHERE 조건절: 일반 조건 명시", "괄호 씌우는 건 옵션" | — |
| E-16 | 5. USING 조건절 | "괄호 필수", "ALIAS 사용 불가, 출처 테이블 명시 불가", "SQL Server에서는 지원X", "SELECT * […] USING 조건절의 기준 컬럼이 1번째 출력 컬럼" | 접두사 사용 시 오류 코드, SQL Server 오류 |
| E-17 | 6. NATURAL JOIN | "동일한 이름을 갖는 모든 컬럼들에 대해 EQUI JOIN", "추가로 USING 절, ON 절, WHERE 절에서 JOIN 조건을 정의할 수 없다", "SQL Server 에서는 지원X", "JOIN되는 컬럼이 NULL 값을 가지면 일치하다고 볼 수 없다", Table1/Table2(NO, NAME) 예, (NO, POS) 예 | NATURAL JOIN 결과표 재현 |
| E-18 | 7. CROSS JOIN | "PRODUCT 개념", "양쪽 테이블의 데이터 수끼리 곱한 만큼(M*N)", Table1(X1,X2: a 12, b 3, NULL 8) × Table2(X1,Y2: a 4.8, b 1.2, C 3.6) = 9행 | 9행 재현 |
| E-19 | OUTER JOIN | BOOK_LIST(b01 데미안 1, b02 어린왕자 2, b03 1984 8, b04 나미야 잡화점의 기적 3), PUBLISHER(1 열린책들, 2 민음사, 3 현대문학, 4 한빛미디어), LEFT/RIGHT/FULL, Oracle `(+)`, RIGHT 예로 `WHERE (+)b.Publisher_id = p.Publisher_id`, FULL을 `(+)` 두 쿼리의 UNION으로 | `(+)`를 왼쪽에 쓴 구문이 실행되는가, 결과표 재현 |
| E-20 | 1) 스칼라 서브쿼리 | "메인쿼리의 각 행마다 하나의 단일값", "스칼라 서브쿼리는 OUTER JOIN 연산을 사용한 결과와 같다", paintings(101~108)·artists(1~5), "매칭되는 데이터가 없는 경우 […] NULL로 표현 (생략되는 게 아님)", DEPT 이름 예, SUM(SAL) 총계 예 | LEFT JOIN과 결과 동일한가, 108 여행 NULL |
| E-21 | 인라인 뷰 | "동적 뷰", "다른 테이블과 조인 시 반드시 테이블 별칭", "일회성", 작가별 평균 가격보다 비싼 그림, 실행 원리 (1)~(4) | 결과 재현 |
| E-22 | 중첩 서브쿼리 | 단일행(= <> > >= < <=), 다중행(IN·ANY·ALL·EXISTS), ">ANY 최소값 […] <ALL 최소값" 표, "다중컬럼 서브쿼리 (SQL Server 지원 X)", "대소 비교 전달 불가", (DEPTNO, SAL) IN, (TEAM_ID, HEIGHT) IN | SQL Server의 다중컬럼 IN 오류, 빈 집합에 ALL·ANY 적용 |
| E-23 | 7. 서브쿼리 사용 시 주의사항2 | order_items(order_id, product_id, …, PRIMARY KEY(order_id, product_id)), "기본키가 2개 이상이라면 […] 두 키를 모두 사용" | 한 키만 쓰면 결과가 어떻게 달라지는가 |
| E-24 | 8. HAVING절에서 서브쿼리 | "그룹핑된 결과에 대해 부가 조건" | — |
| E-25 | 9. UPDATE문의 SET절에서 서브쿼리 | "서브쿼리 결과가 NULL을 반환하면 해당 컬럼 결과가 NULL이 될 수 있기 때문에 주의" | 매칭 없는 행이 NULL로 덮이는가 |
| E-26 | 10. NOT EXISTS / 11. EXISTS | "NOT EXISTS는 서브쿼리 테이블의 결과물을 제외한 나머지 […] (차집합)", "EXISTS는 […] 겹치는 데이터만" | — |
| E-27 | 제 2절 집합 연산자 | "두 집합의 각 컬럼의 순서와 데이터 타입이 상호 호환", "전체 집합의 컬럼명과 데이터 타입은 첫 번째 집합에 의해 결정", UNION/UNION ALL/INTERSECT/EXCEPT 도식 | 컬럼명 결정, 타입 불일치 오류 |
| E-28 | ROLLUP 인수 순서 | ANIMAL_HOTEL `GROUP BY ROLLUP(species, breed)` vs `ROLLUP(breed, species)` 결과표, NVL(species,'합계') | (원본 데이터 없음 → 학습용 가상 데이터로 성질만 확인) |
| E-29 | GROUPING + DECODE | `DECODE(GROUPING(DNAME), 1, 'All Departments', DNAME)`, ROLLUP(DNAME, JOB) 결과표(14, 29025 …) | 결과표 재현 |
| E-30 | CUBE 함수 | "결합 가능한 모든 값", "시스템에 많은 부담", "인수의 순서가 바뀌어도 […] 데이터의 결과는 같다", "18개의 행", "UNION ALL […] 총 4개의 SELECT" | 18행 재현 |
| E-31 | 3 GROUPING SETS | "컬럼의 나열 순서는 중요하지 않는다", "자동으로 총계가 출력되지 않는다", "GROUPING SETS (A, B, ()) 나 GROUPING SETS (A, B, NULL) → […] 총계까지", "8개의 행", UNION ALL 대체 | `NULL` 표기가 두 DBMS에서 모두 되는가 |
| E-32 | 2. 윈도우 함수의 효과 / 3. 일반 집계 함수 | "집계함수결과와 각 컬럼별 행 정보는 동시 출력 불가" 오류, 서브쿼리 / `SUM(SAL) OVER()` 해결, BOOKSHELF 8권, `집계함수(price) OVER (PARTITION BY publisher ORDER BY price)`, "ORDER BY를 명시하지 않을 경우엔 합이 누적으로 계산되지 않음", 평균값 "13,566.57" | 누적 합·평균 값 재현 |
| E-33 | 5. ROWS RANGE | "RANGE: 값이 같으면 같은 범위로 취급하여 동시 연산", EMP 6행(7369 CLERK 800, 7900 JAMES 950, 7876 ADAMS 1100, 7521 WARD 1250, 7654 MARTIN 1250, 7934 MILLER 1300) 결과표 4개 | 결과표 숫자 재현(2050 등) |
| E-34 | LAG/LEAD, FIRST_VALUE/LAST_VALUE | "LAG(SAL, N, NULL 대체값)", "FIRST_VALUE, LAST_VALUE (SQL Server AIX)" [지원X로 추정], "윈도우 함수의 연산 범위 default 값이 첫 행부터 현재 행이니 V1은 1300, 2450, 5000" | SQL Server 지원 여부, 기본 프레임 |
| E-35 | 7. NTILE(N) | "(SQL Server는 지원X)", "ORDER BY 필수", "앞 그룹의 크기가 더 크게 […] 14명을 3 그룹 […] 5, 5, 4" | SQL Server 지원 여부, 5·5·4 |
| E-36 | ROWNUM / TOP-N | "☛ 예외: TOP-N 분석", `WHERE ROWNUM>1` → 아무 행도 반환 안함, `ROWNUM = 3` 불가, `ROWNUM <= 3` 가능, "ROWNUM >= 1은 전체 데이터", `WHERE ROWNUM <= 3 ORDER BY SAL DESC` 잘못된 상위 3명 | 결과 재현 |
| E-37 | 2. 계층형 질의 가상 컬럼 / 3. 가상 함수 | LEVEL, CONNECT_BY_ISLEAF, CONNECT_BY_ROOT, SYS_CONNECT_BY_PATH, ORDER SIBLINGS BY, CONNECT_BY_ISCYCLE, 사원(A, B-A, C-A, D-C) 결과표, EMP1 순환(1000↔2000) "NOCYCLE 명시하지 않아 오류" | 순환 시 오류 코드, IS_CYCLE 값 |
| E-38 | 계층형 질의 구문 도식 | "☛ PRIOR PRIOR PRIOR : = = ~> [ ~> [ → → ] ]" | **판독 불가**(방향 도식이 기호만 남음) |

## 실행으로 대조할 PDF 서술 목록 (요약)

1. E-07 Oracle 23c 이전 FROM 필수 → 21c XE와 23ai Free에서 실행
2. E-08 GROUP BY 후 ORDER BY는 SELECT 컬럼만 → 실행
3. E-12 SELF JOIN 쿼리의 조인 조건 → 실행
4. E-02 셀프 조인 쿼리와 결과표 → 실행
5. E-19 `(+)b.Publisher_id` 구문 → 실행
6. E-31 GROUPING SETS 안의 NULL → 두 DBMS에서 실행
7. E-32 평균 13,566.57 → 실행
8. E-33 ROWS 결과표 2050 → 실행
9. E-34·E-35 SQL Server의 FIRST_VALUE·LAST_VALUE·NTILE 지원 여부 → SQL Server 2022에서 실행
10. E-22 SQL Server 다중컬럼 IN → 실행
11. E-04 DDL 자동 커밋 → 두 DBMS에서 실행
