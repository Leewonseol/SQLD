# SQLD PDF 전개념 종합 SQL 스크립트와 정석 해설

## 0. 이 문서의 목적

이 문서는 실제 SQLD 한 문항을 흉내 낸 것이 아니라, 여러 PDF에서 다룬 개념을 한 업무 시나리오에 연결한 **종합 실행·감사 실습**이다. 한 쿼리에 모든 문법을 무조건 중첩하면 읽을 수도 검증할 수도 없으므로, 하나의 스크립트를 다음 순서로 나눈다.

1. 정규화된 업무 구조와 제약조건 생성
2. 반례가 포함된 데이터 입력
3. SELECT·함수·WHERE·NULL 계산
4. 조인과 조인 증폭 검증
5. 서브쿼리와 집합 연산자
6. GROUP BY·HAVING·ROLLUP·CUBE·GROUPING SETS
7. 윈도우 함수와 Top-N
8. 계층형 질의와 셀프 조인
9. PIVOT·UNPIVOT
10. 위 개념을 연결한 최종 종합 조회
11. 역질의를 이용한 결과 감사
12. 트랜잭션 예제

“정석”이라는 말은 모든 기능을 한 쿼리에 넣는 것이 가장 빠르다는 뜻이 아니다. 여기서 정석은 다음을 뜻한다.

- 먼저 결과의 한 행이 무엇을 의미하는지 정한다.
- 1:N 상세 데이터는 필요한 입도로 먼저 집계한다.
- 행을 제거하는 조건과 행을 보존하는 조건을 구분한다.
- GROUP BY로 행을 줄이는 연산과 윈도우 함수로 행을 유지하는 연산을 구분한다.
- 윈도우 함수 결과는 한 단계 바깥에서 필터링한다.
- OUTER JOIN의 NULL 확장 행을 WHERE에서 실수로 제거하지 않는다.
- DBMS별 차이를 표준 SQL인 것처럼 숨기지 않는다.
- 최종 행 수, 중복, 누락, 합계를 역질의로 검산한다.

---

## 1. PDF 개념 반영표

| 자료 | 이 문서에서 반영한 핵심 개념 |
|---|---|
| `01_SQLD_Collaboration_Text(1).pdf` | 모델링 단계, 엔터티·속성·식별자, 관계, 정규화, 무결성, NULL, 트랜잭션 |
| `02_SQLD_Weighted_Problems(1).pdf` | 식별/비식별 관계, 함수 종속, 1NF·2NF·3NF·BCNF, 반정규화, 조인, 참조무결성 |
| `04_SQLD_NULL_Calculation_Problems.pdf` | NULL 전파, IS NULL, 3값 논리, NOT IN 함정, 집계와 NULL, GROUP BY의 NULL 그룹 |
| 데이터 모델링 3종 PDF | 개념·논리·물리 모델, IE/Barker, 관계차수·선택성, 무결성, 정규화·반정규화, 트랜잭션 |
| 날짜명이 `2026. 7. 30.*`, `2026. 7. 31.*`인 스캔 | SELECT, 함수, WHERE, 집합 연산, GROUP BY/HAVING, JOIN, 표준 조인, NULL 계산 |
| `서브쿼리.pdf` | 스칼라·인라인 뷰·중첩·상관 서브쿼리, 단일행·다중행, IN·ANY·ALL·EXISTS |
| `그룹 함수.pdf` | GROUP BY, HAVING, ROLLUP, CUBE, GROUPING SETS, GROUPING, GROUPING_ID |
| `윈도우 함수.pdf` | 순위·집계·행 순서·분포 함수, PARTITION BY, ORDER BY, 윈도우 프레임 |
| `TOP-N 쿼리.pdf` | ROWNUM, 인라인 뷰, ROW_NUMBER, FETCH FIRST/OFFSET |
| `계층형 질의와 셀프 조인.pdf` | START WITH, CONNECT BY PRIOR, LEVEL, 루트·경로·리프·사이클, 셀프 조인 |
| `PIVOT절과 UNPIVOT절.pdf` | PIVOT, 암시적 그룹화, 다중 집계, 별칭, UNPIVOT, NULL 포함 여부, CASE 대안 |
| `SQLD_Section1_Passage_Revised.md` | 개체·참조·도메인 무결성, ACID, 조회와 구조 설계의 구분 |
| `SQLD_Section2_Problems_27-31.md` | 슈퍼·서브타입, 점·선분 이력, 물리 설계, 분산 투명성 개념 |

---

# PART A. Oracle 실행용 데이터 모델과 반례 데이터

## 2. 문제의 업무 규칙

최종 조회는 다음을 만족해야 한다.

1. `DEPARTMENT`를 기준으로 **모든 부서**를 출력한다.
2. 각 부서의 `ACTIVE` 사원만 후보로 삼는다.
3. 각 사원의 급여는 같은 부서 ACTIVE 사원 평균 급여의 80% 이상이어야 한다.
4. 조건을 통과한 사원 중 **각 부서별** 급여 상위 2명을 출력한다.
5. 급여가 같으면 사원번호가 작은 사원을 우선하며 부서당 최대 2명만 출력한다.
6. 사원이 존재하지만 보너스가 없거나 모든 보너스 금액이 NULL이면 0을 출력한다.
7. 조건을 만족하는 사원이 없는 부서는 사원 관련 열을 NULL로 출력한다.
8. 부서에 없는 부서번호 또는 NULL 부서번호를 가진 원천 사원은 정제 대상에서 제외한다.
9. 최종 출력 열은 부서경로, 부서번호, 부서명, 사원번호, 사원명, 급여, 보너스합계, 매출합계, 부서내순위다.

이 명세는 이전 검토에서 발견된 세 모호성, 즉 `부서별` 누락, 고아·NULL 부서 처리 미규정, 출력 컬럼 미지정을 제거한다.

## 3. DDL: 정규화·식별자·관계·무결성

아래 DDL은 새 사용자 또는 빈 스키마에서 실행하는 것을 전제로 한다.

```sql
/* 부모 엔터티이면서 자기참조 계층을 가진 부서 */
CREATE TABLE department (
    dept_id         NUMBER(4)       CONSTRAINT pk_department PRIMARY KEY,
    parent_dept_id  NUMBER(4),
    dept_name       VARCHAR2(40)    CONSTRAINT nn_department_name NOT NULL,
    dept_type       VARCHAR2(10)    DEFAULT 'TEAM' NOT NULL,
    CONSTRAINT uq_department_name UNIQUE (dept_name),
    CONSTRAINT ck_department_type CHECK (dept_type IN ('ROOT', 'DIVISION', 'TEAM')),
    CONSTRAINT fk_department_parent
        FOREIGN KEY (parent_dept_id) REFERENCES department(dept_id)
);

/* 사원: 부서와는 비식별관계, 관리자와는 자기참조 비식별관계 */
CREATE TABLE employee (
    emp_id       NUMBER(6)       CONSTRAINT pk_employee PRIMARY KEY,
    dept_id      NUMBER(4),
    manager_id   NUMBER(6),
    emp_name     VARCHAR2(30)    CONSTRAINT nn_employee_name NOT NULL,
    email        VARCHAR2(80),
    salary       NUMBER(10,2),
    status       VARCHAR2(10)    DEFAULT 'ACTIVE' NOT NULL,
    hire_date    DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT uq_employee_email UNIQUE (email),
    CONSTRAINT ck_employee_salary CHECK (salary >= 0),
    CONSTRAINT ck_employee_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'LEAVE')),
    CONSTRAINT fk_employee_department
        FOREIGN KEY (dept_id) REFERENCES department(dept_id),
    CONSTRAINT fk_employee_manager
        FOREIGN KEY (manager_id) REFERENCES employee(emp_id)
);

/* 슈퍼타입 EMPLOYEE의 상호 배타적 서브타입 예시 */
CREATE TABLE regular_employee (
    emp_id         NUMBER(6) CONSTRAINT pk_regular_employee PRIMARY KEY,
    pension_grade  VARCHAR2(10) NOT NULL,
    CONSTRAINT fk_regular_employee
        FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE contract_employee (
    emp_id        NUMBER(6) CONSTRAINT pk_contract_employee PRIMARY KEY,
    contract_end  DATE NOT NULL,
    CONSTRAINT fk_contract_employee
        FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE bonus (
    bonus_id    NUMBER(8)      CONSTRAINT pk_bonus PRIMARY KEY,
    emp_id      NUMBER(6)      CONSTRAINT nn_bonus_emp NOT NULL,
    bonus_date  DATE           CONSTRAINT nn_bonus_date NOT NULL,
    amount      NUMBER(10,2),
    CONSTRAINT fk_bonus_employee
        FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE product (
    product_id    NUMBER(6)      CONSTRAINT pk_product PRIMARY KEY,
    category      VARCHAR2(20)   NOT NULL,
    product_name  VARCHAR2(40)   NOT NULL,
    list_price    NUMBER(10,2)   CHECK (list_price >= 0),
    CONSTRAINT uq_product_name UNIQUE (product_name)
);

CREATE TABLE sales (
    sale_id      NUMBER(8)       CONSTRAINT pk_sales PRIMARY KEY,
    emp_id       NUMBER(6)       NOT NULL,
    product_id   NUMBER(6)       NOT NULL,
    sale_date    DATE            NOT NULL,
    channel      VARCHAR2(10)    NOT NULL,
    amount       NUMBER(12,2),
    CONSTRAINT ck_sales_channel CHECK (channel IN ('ONLINE', 'OFFLINE')),
    CONSTRAINT fk_sales_employee FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    CONSTRAINT fk_sales_product FOREIGN KEY (product_id) REFERENCES product(product_id)
);

/* 비등가 조인을 연습하기 위한 급여 구간 */
CREATE TABLE salary_grade (
    grade_name  VARCHAR2(10) CONSTRAINT pk_salary_grade PRIMARY KEY,
    min_salary  NUMBER(10,2) NOT NULL,
    max_salary  NUMBER(10,2) NOT NULL,
    CONSTRAINT ck_salary_grade_range CHECK (max_salary >= min_salary)
);

/* M:N 관계를 해소한 교차 엔터티: 두 부모 키가 복합 PK가 되는 식별관계 */
CREATE TABLE project (
    project_id    NUMBER(6)      CONSTRAINT pk_project PRIMARY KEY,
    project_name  VARCHAR2(50)   NOT NULL
);

CREATE TABLE employee_project (
    emp_id       NUMBER(6),
    project_id   NUMBER(6),
    role_name    VARCHAR2(30),
    CONSTRAINT pk_employee_project PRIMARY KEY (emp_id, project_id),
    CONSTRAINT fk_ep_employee FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    CONSTRAINT fk_ep_project FOREIGN KEY (project_id) REFERENCES project(project_id)
);

/* 선분이력: 종료일은 변경되므로 PK에 넣지 않고 (사원, 시작일)을 식별자로 사용 */
CREATE TABLE employee_status_history (
    emp_id      NUMBER(6),
    start_date  DATE,
    end_date    DATE,
    status      VARCHAR2(10) NOT NULL,
    CONSTRAINT pk_employee_status_history PRIMARY KEY (emp_id, start_date),
    CONSTRAINT ck_history_period CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT fk_history_employee FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

/* 원천 적재 테이블에는 일부러 FK를 두지 않는다. 품질검사 후 본 테이블로 이동한다. */
CREATE TABLE stg_employee_raw (
    emp_id       NUMBER(6),
    dept_id      NUMBER(4),
    emp_name     VARCHAR2(30),
    salary       NUMBER(10,2),
    status       VARCHAR2(10)
);
```

### 왜 이 구조가 정석인가

- 부서명, 상품명 같은 반복 사실을 거래 테이블에 매번 저장하지 않고 독립 엔터티로 분리했다. 갱신·삽입·삭제 이상을 줄이는 정규화다.
- `EMPLOYEE_PROJECT`는 사원과 프로젝트의 M:N 관계를 해소하며 두 부모 키가 자식 PK에 포함되는 식별관계다.
- `EMPLOYEE.DEPT_ID`는 사원 PK의 일부가 아니므로 부서와 사원은 비식별관계다. 부모 없이는 업무적으로 곤란하다는 사실만으로 식별관계가 되지는 않는다.
- `NOT NULL`, `UNIQUE`, `CHECK`, `PK`, `FK`, `DEFAULT`를 통해 개체·참조·도메인 무결성을 나눠 구현했다.
- 이력의 종료일은 나중에 갱신될 수 있으므로 PK에서 제외했다. 변하는 값을 식별자에 넣지 않는다는 불변성 원칙에 맞는다.
- 잘못된 원천 데이터를 보여주기 위해 운영 테이블의 FK를 제거하지 않고 별도 스테이징 테이블을 뒀다. 제약조건을 포기해서 오류를 허용하는 것보다 정석적이다.

## 4. 반례 데이터 입력

```sql
INSERT ALL
  INTO department VALUES (1,  NULL, '전사',     'ROOT')
  INTO department VALUES (10, 1,    '기술본부', 'DIVISION')
  INTO department VALUES (11, 10,   '개발팀',   'TEAM')
  INTO department VALUES (12, 10,   '분석팀',   'TEAM')
  INTO department VALUES (20, 1,    '영업본부', 'DIVISION')
  INTO department VALUES (21, 20,   '온라인팀', 'TEAM')
  INTO department VALUES (22, 20,   '오프라인팀','TEAM')
  INTO department VALUES (30, 1,    '품질팀',   'TEAM')
  INTO department VALUES (40, 1,    '무인부서', 'TEAM')
SELECT 1 FROM dual;

/* 관리자를 먼저 넣어 자기참조 FK를 만족시킨다. */
INSERT INTO employee VALUES
  (100, 1, NULL, '대표', 'ceo@example.com', 10000, 'ACTIVE', DATE '2020-01-01');

INSERT ALL
  INTO employee VALUES (110, 10, 100, '기술본부장', 'cto@example.com', 8000, 'ACTIVE', DATE '2021-01-01')
  INTO employee VALUES (120, 20, 100, '영업본부장', 'cso@example.com', 7800, 'ACTIVE', DATE '2021-02-01')
  INTO employee VALUES (101, 11, 110, '김개발', 'dev1@example.com', 5000, 'ACTIVE', DATE '2023-01-10')
  INTO employee VALUES (102, 11, 110, '이개발', 'dev2@example.com', 4000, 'ACTIVE', DATE '2023-02-10')
  INTO employee VALUES (103, 11, 110, '박휴직', 'dev3@example.com', 3000, 'INACTIVE', DATE '2023-03-10')
  INTO employee VALUES (201, 12, 110, '최분석', 'ana1@example.com', 6000, 'ACTIVE', DATE '2022-01-10')
  INTO employee VALUES (202, 12, 110, '정분석', 'ana2@example.com', 6000, 'ACTIVE', DATE '2022-02-10')
  INTO employee VALUES (301, 21, 120, '온영업', 'on1@example.com', 4500, 'ACTIVE', DATE '2024-01-10')
  INTO employee VALUES (302, 21, 120, '온신입', 'on2@example.com', 3500, 'ACTIVE', DATE '2025-01-10')
  INTO employee VALUES (401, 22, 120, '한운영', 'off1@example.com', 4500, 'INACTIVE', DATE '2024-02-10')
SELECT 1 FROM dual;

INSERT ALL
  INTO regular_employee VALUES (100, 'P1')
  INTO regular_employee VALUES (110, 'P2')
  INTO regular_employee VALUES (120, 'P2')
  INTO regular_employee VALUES (101, 'P3')
  INTO regular_employee VALUES (102, 'P3')
  INTO regular_employee VALUES (201, 'P3')
  INTO regular_employee VALUES (202, 'P3')
  INTO regular_employee VALUES (301, 'P3')
  INTO contract_employee VALUES (302, DATE '2026-12-31')
SELECT 1 FROM dual;

INSERT ALL
  INTO bonus VALUES (1, 101, DATE '2026-01-31', 100)
  INTO bonus VALUES (2, 101, DATE '2026-02-28', 200)
  INTO bonus VALUES (3, 102, DATE '2026-01-31', 50)
  INTO bonus VALUES (4, 202, DATE '2026-01-31', NULL)
  INTO bonus VALUES (5, 301, DATE '2026-01-31', 150)
SELECT 1 FROM dual;

INSERT ALL
  INTO product VALUES (1, 'DB', 'SQLD교재', 30000)
  INTO product VALUES (2, 'AI', 'AI교재', 40000)
  INTO product VALUES (3, 'QA', '데이터품질교재', 35000)
SELECT 1 FROM dual;

INSERT ALL
  INTO salary_grade VALUES ('LOW',  0,    3999.99)
  INTO salary_grade VALUES ('MID',  4000, 5999.99)
  INTO salary_grade VALUES ('HIGH', 6000, 99999999)
SELECT 1 FROM dual;

INSERT ALL
  INTO sales VALUES (1, 101, 1, DATE '2026-01-05', 'ONLINE', 1000)
  INTO sales VALUES (2, 101, 2, DATE '2026-04-05', 'ONLINE', 1200)
  INTO sales VALUES (3, 101, 3, DATE '2026-07-05', 'OFFLINE', 900)
  INTO sales VALUES (4, 102, 1, DATE '2026-01-06', 'ONLINE', 700)
  INTO sales VALUES (5, 102, 3, DATE '2026-10-06', 'OFFLINE', NULL)
  INTO sales VALUES (6, 201, 2, DATE '2026-02-05', 'ONLINE', 1500)
  INTO sales VALUES (7, 201, 3, DATE '2026-05-05', 'OFFLINE', 1300)
  INTO sales VALUES (8, 202, 1, DATE '2026-08-05', 'ONLINE', 1100)
  INTO sales VALUES (9, 301, 1, DATE '2026-01-07', 'ONLINE', 2000)
  INTO sales VALUES (10,301, 2, DATE '2026-04-07', 'ONLINE', 1800)
  INTO sales VALUES (11,302, 1, DATE '2026-01-08', 'OFFLINE', 600)
SELECT 1 FROM dual;

INSERT ALL
  INTO project VALUES (1, '데이터감사')
  INTO project VALUES (2, 'SQL교육')
  INTO employee_project VALUES (101, 1, '개발')
  INTO employee_project VALUES (201, 1, '분석')
  INTO employee_project VALUES (101, 2, '강사')
  INTO employee_project VALUES (102, 2, '검수')
SELECT 1 FROM dual;

INSERT ALL
  INTO employee_status_history VALUES (101, DATE '2023-01-10', NULL, 'ACTIVE')
  INTO employee_status_history VALUES (103, DATE '2023-03-10', DATE '2025-12-31', 'ACTIVE')
  INTO employee_status_history VALUES (103, DATE '2026-01-01', NULL, 'INACTIVE')
SELECT 1 FROM dual;

/* 스테이징에만 존재하는 정상·고아·미배정 사례 */
INSERT ALL
  INTO stg_employee_raw VALUES (901, 99,   '고아키', 7000, 'ACTIVE')
  INTO stg_employee_raw VALUES (902, NULL, '미배정', 3500, 'ACTIVE')
  INTO stg_employee_raw VALUES (903, 11,   '정상원천', 4200, 'ACTIVE')
SELECT 1 FROM dual;

COMMIT;
```

---

# PART B. SELECT·함수·WHERE·NULL

## 5. 함수 종합 조회

```sql
SELECT
    e.emp_id,

    /* 문자 함수 */
    UPPER(e.email)                         AS upper_email,
    LOWER(e.email)                         AS lower_email,
    SUBSTR(e.emp_name, 1, 1)               AS family_name,
    LENGTH(e.emp_name)                     AS name_length,
    ASCII(SUBSTR(e.email, 1, 1))            AS first_ascii,
    CHR(65)                                 AS char_a,
    INSTR(e.email, '@')                     AS at_position,
    LPAD(e.emp_id, 6, '0')                  AS padded_emp_id,
    RPAD(e.emp_name, 8, '.')                AS padded_name,
    LTRIM('  ' || e.emp_name)               AS left_trimmed,
    RTRIM(e.emp_name || '  ')               AS right_trimmed,
    TRIM('  ' || e.emp_name || '  ')       AS trimmed_name,
    REPLACE(e.email, 'example.com', 'sql.kr') AS replaced_email,
    CONCAT(e.emp_name, '님')                AS display_name,

    /* 숫자 함수 */
    ABS(e.salary - 5000)                   AS distance_from_5000,
    SIGN(e.salary - 5000)                  AS salary_sign,
    MOD(e.emp_id, 2)                       AS odd_even,
    CEIL(e.salary / 3)                     AS ceil_value,
    FLOOR(e.salary / 3)                    AS floor_value,
    ROUND(e.salary / 3, 2)                 AS rounded_value,
    TRUNC(e.salary / 3, 2)                 AS truncated_value,
    POWER(e.salary / 1000, 2)              AS squared_scale,
    SQRT(e.salary)                          AS salary_square_root,

    /* 날짜 함수 */
    SYSDATE                                AS current_datetime,
    EXTRACT(YEAR FROM e.hire_date)         AS hire_year,
    ADD_MONTHS(e.hire_date, 6)             AS after_six_months,
    MONTHS_BETWEEN(SYSDATE, e.hire_date)   AS months_worked,
    LAST_DAY(e.hire_date)                  AS hire_month_end,
    NEXT_DAY(e.hire_date, 'MONDAY')         AS next_monday,
    TRUNC(e.hire_date, 'MM')                AS hire_month_start,

    /* 형변환 함수 */
    TO_CHAR(e.hire_date, 'YYYY-MM-DD')      AS hire_date_text,
    TO_DATE('2026-08-22', 'YYYY-MM-DD')     AS exam_date,
    TO_NUMBER('1234')                      AS parsed_number,
    CAST(e.salary AS NUMBER(12,0))          AS cast_salary,

    /* NULL·조건 함수 */
    NVL(e.salary, 0)                       AS salary_nvl,
    NVL2(e.email, 'EMAIL_OK', 'NO_EMAIL')  AS email_state,
    NULLIF(e.salary, 5000)                 AS null_if_5000,
    COALESCE(e.salary, 0)                  AS salary_coalesce,
    CASE
        WHEN e.salary >= 6000 THEN 'HIGH'
        WHEN e.salary >= 4000 THEN 'MID'
        ELSE 'LOW'
    END                                    AS salary_band,
    DECODE(e.status,
           'ACTIVE', '재직',
           'INACTIVE', '비재직',
           'LEAVE', '휴직',
           '기타')                          AS status_name
FROM employee e
WHERE e.status IN ('ACTIVE', 'LEAVE')
  AND e.salary BETWEEN 3000 AND 10000
  AND e.emp_name LIKE '%개발%'
ORDER BY e.salary DESC, e.emp_id;

/* DISTINCT는 선택한 열 조합 전체를 기준으로 중복을 제거한다. */
SELECT DISTINCT dept_id, status
FROM employee
ORDER BY dept_id, status;
```

### 정석 해설

- `WHERE`는 행을 고르고 `SELECT`는 통과한 행의 표시값을 만든다. SELECT 별칭을 같은 단계의 WHERE에서 사용할 수 없는 이유도 이 처리 순서 때문이다.
- 날짜 문자열은 암시적 변환에 맡기지 않고 `TO_DATE`와 형식을 함께 쓴다. 세션의 날짜 형식이 달라도 의미가 변하지 않는다.
- `CASE`는 표준 SQL이고 `DECODE`는 Oracle 전용이다. 이식성이 중요하면 CASE가 우선이다.
- `ROUND`는 반올림하고 `TRUNC`는 버린다. 이름이 비슷하지만 계산 결과가 다르므로 시험에서 자주 섞인다.

## 6. NULL 계산 실험

```sql
/* NULL 전파: amount가 NULL이면 amount + 100도 NULL */
SELECT sale_id, amount, amount + 100 AS propagated
FROM sales
ORDER BY sale_id;

/* NULL 비교는 = NULL이 아니라 IS NULL */
SELECT sale_id, amount
FROM sales
WHERE amount IS NULL;

/* COUNT(*)는 행, COUNT(amount)는 NULL이 아닌 값만 센다. */
SELECT
    COUNT(*)      AS all_rows,
    COUNT(amount) AS nonnull_amounts,
    SUM(amount)   AS sum_ignoring_null,
    AVG(amount)   AS avg_ignoring_null
FROM sales;

/* GROUP BY에서 NULL들은 제거되지 않고 하나의 NULL 그룹을 이룬다. */
SELECT amount, COUNT(*)
FROM sales
GROUP BY amount
ORDER BY amount NULLS LAST;

/* NOT IN 목록에 NULL이 있으면 전체 조건이 UNKNOWN이 될 수 있다. */
SELECT e.emp_id
FROM employee e
WHERE e.dept_id NOT IN (11, 12, NULL);

/* 같은 의도를 안전하게 표현하는 반상관 서브쿼리 */
SELECT e.emp_id
FROM employee e
WHERE NOT EXISTS (
    SELECT 1
    FROM department d
    WHERE d.dept_id IN (11, 12)
      AND d.dept_id = e.dept_id
);
```

`SUM(amount)`는 일부 NULL을 무시하지만 모든 입력이 NULL이면 0이 아니라 NULL이다. 0이 필요한 업무 규칙은 `NVL(SUM(amount), 0)`처럼 명시해야 한다.

---

# PART C. JOIN과 입도 감사

## 7. 조인 유형

```sql
/* INNER JOIN: 매칭되는 부서와 사원만 */
SELECT d.dept_name, e.emp_name
FROM department d
JOIN employee e
  ON e.dept_id = d.dept_id;

/* LEFT OUTER JOIN: 모든 부서 보존 */
SELECT d.dept_name, e.emp_name
FROM department d
LEFT JOIN employee e
  ON e.dept_id = d.dept_id
 AND e.status = 'ACTIVE'
ORDER BY d.dept_id, e.emp_id;

/* RIGHT OUTER JOIN: 오른쪽 EMPLOYEE를 보존. 방향을 바꾼 LEFT JOIN과 동치로 쓸 수 있다. */
SELECT d.dept_name, e.emp_name
FROM department d
RIGHT JOIN employee e
  ON e.dept_id = d.dept_id
ORDER BY e.emp_id;

/* FULL OUTER JOIN: 양쪽의 비매칭 행까지 보존 */
SELECT d.dept_id AS department_id, r.dept_id AS raw_dept_id, r.emp_name
FROM department d
FULL OUTER JOIN stg_employee_raw r
  ON r.dept_id = d.dept_id
ORDER BY COALESCE(d.dept_id, r.dept_id);

/* CROSS JOIN: 가능한 모든 조합. 의도하지 않으면 카티션 곱 오류 */
SELECT d.dept_name, p.product_name
FROM department d
CROSS JOIN product p;

/* USING: 같은 이름의 조인 열이 양쪽에 하나씩 있을 때 */
SELECT dept_id, d.dept_name, e.emp_name
FROM department d
JOIN employee e USING (dept_id)
ORDER BY dept_id, e.emp_id;

/* NATURAL JOIN: 같은 이름의 모든 열을 자동 조인하므로 스키마 변경에 취약하다. */
SELECT dept_id, dept_name, emp_name
FROM department
NATURAL JOIN employee;

/* NON-EQUI JOIN: 범위 조건으로 급여 등급 연결 */
SELECT e.emp_id, e.emp_name, e.salary, g.grade_name
FROM employee e
JOIN salary_grade g
  ON e.salary BETWEEN g.min_salary AND g.max_salary
ORDER BY e.emp_id;

/* SELF JOIN: 사원과 직속 관리자 */
SELECT e.emp_name AS employee_name,
       m.emp_name AS manager_name
FROM employee e
LEFT JOIN employee m
  ON m.emp_id = e.manager_id
ORDER BY e.emp_id;
```

## 8. 조인 증폭 확인

```sql
/* 잘못된 순서: 보너스 상세를 조인하면 사원 101이 두 행으로 증가한다. */
SELECT e.emp_id, e.emp_name, b.bonus_id, b.amount
FROM employee e
LEFT JOIN bonus b
  ON b.emp_id = e.emp_id
WHERE e.emp_id IN (101, 102)
ORDER BY e.emp_id, b.bonus_id;

/* 정석: 사원당 한 행이 필요하면 먼저 사원 단위로 집계한다. */
WITH bonus_sum AS (
    SELECT emp_id, SUM(amount) AS total_bonus
    FROM bonus
    GROUP BY emp_id
)
SELECT e.emp_id,
       e.emp_name,
       NVL(b.total_bonus, 0) AS total_bonus
FROM employee e
LEFT JOIN bonus_sum b
  ON b.emp_id = e.emp_id
WHERE e.emp_id IN (101, 102)
ORDER BY e.emp_id;
```

행 수가 맞는지만 확인하면 중복과 누락이 서로 상쇄되는 오류를 놓칠 수 있다. 반드시 PK별 중복도 함께 확인한다.

`NATURAL JOIN`은 현재는 `DEPT_ID`만 공통 열이어서 의도대로 보이지만, 나중에 양쪽에 같은 이름의 다른 열이 추가되면 조인 조건이 자동으로 늘어난다. 실무와 감사 로그에서는 조건이 드러나는 `ON`을 우선하는 편이 안전하다. Oracle 구식 `(+)` 외부조인 문법보다 ANSI JOIN을 쓰는 이유도 방향과 조건을 분명하게 기록하기 위해서다.

---

# PART D. 서브쿼리와 집합 연산자

## 9. 서브쿼리 유형 전체

```sql
/* 1. 스칼라 서브쿼리: 한 행의 한 값만 반환해야 한다. */
SELECT e.emp_id,
       e.emp_name,
       (SELECT d.dept_name
        FROM department d
        WHERE d.dept_id = e.dept_id) AS dept_name
FROM employee e;

/* 2. 인라인 뷰: FROM절에서 임시 결과집합으로 사용 */
SELECT x.dept_id, x.avg_salary
FROM (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employee
    WHERE status = 'ACTIVE'
    GROUP BY dept_id
) x
WHERE x.avg_salary >= 4000;

/* 3. 비상관 단일행 서브쿼리 */
SELECT emp_id, emp_name, salary
FROM employee
WHERE salary > (SELECT AVG(salary) FROM employee);

/* 4. 상관 서브쿼리: 외부 행의 dept_id를 내부가 참조 */
SELECT e.emp_id, e.emp_name, e.salary
FROM employee e
WHERE e.salary >= (
    SELECT AVG(e2.salary)
    FROM employee e2
    WHERE e2.dept_id = e.dept_id
      AND e2.status = 'ACTIVE'
);

/* 5. 다중행 IN */
SELECT emp_id, emp_name
FROM employee
WHERE dept_id IN (
    SELECT dept_id
    FROM department
    WHERE parent_dept_id = 10
);

/* 6. ANY: 반환값 중 하나보다 크면 TRUE */
SELECT emp_id, emp_name, salary
FROM employee
WHERE salary > ANY (
    SELECT salary
    FROM employee
    WHERE dept_id = 11
);

/* 7. ALL: 반환값 모두보다 커야 TRUE */
SELECT emp_id, emp_name, salary
FROM employee
WHERE salary > ALL (
    SELECT salary
    FROM employee
    WHERE dept_id = 11
);

/* 8. EXISTS: 실제 반환 열보다 행의 존재 여부가 중요 */
SELECT e.emp_id, e.emp_name
FROM employee e
WHERE EXISTS (
    SELECT 1
    FROM bonus b
    WHERE b.emp_id = e.emp_id
);

/* 9. NOT EXISTS: NULL에 안전한 반조인 패턴 */
SELECT e.emp_id, e.emp_name
FROM employee e
WHERE NOT EXISTS (
    SELECT 1
    FROM bonus b
    WHERE b.emp_id = e.emp_id
);
```

`=`는 단일행 결과를 전제로 하고 `IN`, `ANY`, `ALL`은 다중행 결과를 받을 수 있다. 스칼라 위치에서 두 행 이상이 나오면 오류이므로 “서브쿼리니까 된다”가 아니라 반환 행 수를 먼저 판단해야 한다.

### ANY·ALL의 공집합과 NULL 판단

`ANY`는 비교 결과 중 하나라도 TRUE이면 TRUE이고, `ALL`은 모든 비교 결과가 TRUE여야 TRUE이다. 따라서 서브쿼리가 한 행도 반환하지 않는 **공집합**일 때는 다음처럼 판단한다.

| 조건 | 공집합 결과 | 판단 근거 |
|---|---:|---|
| `x > ANY (공집합)` | FALSE | TRUE가 되는 비교 대상이 하나도 없음 |
| `x > ALL (공집합)` | TRUE | 조건을 위반하는 비교 대상이 하나도 없음 |

공집합과 **NULL 한 행을 반환하는 서브쿼리**는 다르다. 예를 들어 서브쿼리의 결과 집합이 `{NULL}`이라면, 그 서브쿼리를 대상으로 한 `x > ANY (서브쿼리)`와 `x > ALL (서브쿼리)`는 모두 UNKNOWN이다. 여러 행에 NULL이 섞이면 다음 규칙을 적용한다.

- `ANY`: TRUE가 하나라도 있으면 TRUE, TRUE 없이 FALSE와 UNKNOWN만 있으면 UNKNOWN
- `ALL`: FALSE가 하나라도 있으면 FALSE, FALSE 없이 TRUE와 UNKNOWN만 있으면 UNKNOWN
- WHERE절은 TRUE인 행만 통과시키므로 FALSE와 UNKNOWN은 모두 제거된다.

## 10. 집합 연산자

집합 연산의 양쪽 SELECT는 컬럼 수가 같고 대응 컬럼의 자료형이 호환돼야 한다. 최종 ORDER BY는 전체 집합 연산의 마지막에 한 번 둔다.

```sql
/* UNION: 합집합 후 중복 제거 */
SELECT emp_id FROM regular_employee
UNION
SELECT emp_id FROM contract_employee
ORDER BY emp_id;

/* UNION ALL: 중복을 보존하므로 중복 제거 비용이 없다. */
SELECT emp_id, 'BONUS' AS source_name FROM bonus
UNION ALL
SELECT emp_id, 'SALES' AS source_name FROM sales
ORDER BY emp_id, source_name;

/* INTERSECT: 보너스도 있고 매출도 있는 사원 */
SELECT emp_id FROM bonus
INTERSECT
SELECT emp_id FROM sales
ORDER BY emp_id;

/* MINUS: 매출은 있지만 보너스는 없는 사원. SQL Server는 EXCEPT */
SELECT emp_id FROM sales
MINUS
SELECT emp_id FROM bonus
ORDER BY emp_id;
```

`UNION`을 습관적으로 쓰면 실제 중복 원인을 가릴 수 있다. 중복을 제거해야 한다는 업무 규칙이 있을 때만 UNION을 선택하고, 단순 결합이면 UNION ALL을 먼저 검토한다.

---

# PART E. 그룹 함수

## 11. GROUP BY와 HAVING

```sql
SELECT
    e.dept_id,
    COUNT(*)          AS employee_count,
    COUNT(e.salary)   AS salary_count,
    SUM(e.salary)     AS salary_sum,
    AVG(e.salary)     AS salary_avg,
    MIN(e.salary)     AS salary_min,
    MAX(e.salary)     AS salary_max,
    VAR_POP(e.salary) AS salary_population_variance,
    VARIANCE(e.salary) AS salary_sample_variance,
    STDDEV_POP(e.salary) AS salary_population_stddev,
    STDDEV(e.salary)  AS salary_sample_stddev
FROM employee e
WHERE e.status = 'ACTIVE'
GROUP BY e.dept_id
HAVING COUNT(*) >= 2
   AND AVG(e.salary) >= 4000
ORDER BY e.dept_id;
```

- WHERE는 그룹화 전 개별 행을 제거한다.
- GROUP BY는 남은 행을 그룹당 한 행으로 축약한다.
- HAVING은 만들어진 그룹을 제거한다.
- SELECT의 일반 컬럼은 GROUP BY에 있어야 한다. 집계되지도 그룹화되지도 않은 열을 임의로 출력할 수 없다.

## 12. ROLLUP·CUBE·GROUPING SETS

```sql
/* 계층적 소계: (부서, 채널) → 부서 소계 → 전체 합계 */
SELECT
    e.dept_id,
    s.channel,
    SUM(s.amount) AS sales_amount,
    GROUPING(e.dept_id) AS g_dept,
    GROUPING(s.channel) AS g_channel,
    GROUPING_ID(e.dept_id, s.channel) AS grouping_code
FROM employee e
JOIN sales s
  ON s.emp_id = e.emp_id
GROUP BY ROLLUP(e.dept_id, s.channel)
ORDER BY e.dept_id, s.channel;

/* 가능한 모든 조합 소계: 상세, 부서별, 채널별, 전체 */
SELECT e.dept_id, s.channel, SUM(s.amount) AS sales_amount
FROM employee e
JOIN sales s ON s.emp_id = e.emp_id
GROUP BY CUBE(e.dept_id, s.channel)
ORDER BY e.dept_id, s.channel;

/* 필요한 그룹 조합만 직접 지정 */
SELECT e.dept_id, s.channel, SUM(s.amount) AS sales_amount
FROM employee e
JOIN sales s ON s.emp_id = e.emp_id
GROUP BY GROUPING SETS (
    (e.dept_id, s.channel),
    (e.dept_id),
    (s.channel),
    ()
)
ORDER BY e.dept_id, s.channel;
```

`GROUPING(column)=1`은 해당 열이 원본 NULL이어서가 아니라 소계 생성을 위해 NULL처럼 표시됐다는 뜻이다. 실제 NULL과 소계 표지를 구별할 때 사용한다.

---

# PART F. 윈도우 함수와 Top-N

## 13. 윈도우 함수 종합

```sql
SELECT
    e.emp_id,
    e.dept_id,
    e.emp_name,
    e.salary,

    ROW_NUMBER() OVER (
        PARTITION BY e.dept_id
        ORDER BY e.salary DESC, e.emp_id
    ) AS row_no,

    RANK() OVER (
        PARTITION BY e.dept_id
        ORDER BY e.salary DESC
    ) AS salary_rank,

    DENSE_RANK() OVER (
        PARTITION BY e.dept_id
        ORDER BY e.salary DESC
    ) AS dense_salary_rank,

    SUM(e.salary) OVER (
        PARTITION BY e.dept_id
    ) AS dept_salary_sum,

    AVG(e.salary) OVER (
        PARTITION BY e.dept_id
    ) AS dept_salary_avg,

    COUNT(*) OVER (
        PARTITION BY e.dept_id
    ) AS dept_employee_count,

    MIN(e.salary) OVER (
        PARTITION BY e.dept_id
    ) AS dept_salary_min,

    MAX(e.salary) OVER (
        PARTITION BY e.dept_id
    ) AS dept_salary_max,

    SUM(e.salary) OVER (
        PARTITION BY e.dept_id
        ORDER BY e.hire_date, e.emp_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_salary,

    LAG(e.salary, 1) OVER (
        PARTITION BY e.dept_id
        ORDER BY e.hire_date, e.emp_id
    ) AS previous_salary,

    LEAD(e.salary, 1) OVER (
        PARTITION BY e.dept_id
        ORDER BY e.hire_date, e.emp_id
    ) AS next_salary,

    FIRST_VALUE(e.emp_name) OVER (
        PARTITION BY e.dept_id
        ORDER BY e.salary DESC, e.emp_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS highest_paid_name,

    LAST_VALUE(e.emp_name) OVER (
        PARTITION BY e.dept_id
        ORDER BY e.salary DESC, e.emp_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_paid_name,

    NTILE(4) OVER (
        ORDER BY e.salary DESC, e.emp_id
    ) AS salary_quartile,

    CUME_DIST() OVER (
        ORDER BY e.salary
    ) AS cumulative_distribution,

    PERCENT_RANK() OVER (
        ORDER BY e.salary
    ) AS percent_rank_value,

    RATIO_TO_REPORT(e.salary) OVER (
        PARTITION BY e.dept_id
    ) AS dept_salary_ratio
FROM employee e
WHERE e.status = 'ACTIVE'
ORDER BY e.dept_id, row_no;
```

`RATIO_TO_REPORT`는 Oracle 전용 분석 함수다. SQL Server에서는 분자와 파티션 합계를 직접 나누어 같은 의미를 구현한다. 정수 나눗셈과 0으로 나누는 오류를 함께 피하려면 다음 형태가 안전하다.

```sql
/* SQL Server: Oracle RATIO_TO_REPORT의 대체식 */
e.salary * 1.0
    / NULLIF(SUM(e.salary) OVER (PARTITION BY e.dept_id), 0)
    AS dept_salary_ratio
```

### GROUP BY와 윈도우 함수의 차이

GROUP BY는 여러 입력 행을 그룹당 한 행으로 줄인다. 윈도우 함수는 원래 행을 유지하면서 같은 파티션의 집계·순위·이전·다음 값을 붙인다. 사원 개별 행과 부서 평균을 동시에 보고 싶다면 윈도우 함수가 자연스럽다.

`LAST_VALUE`는 프레임을 생략하면 현재 행까지를 마지막으로 볼 수 있다. 파티션 전체의 진짜 마지막 값을 원하면 `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`을 명시하는 것이 안전하다.

`ROWS`는 물리적인 행 수를 기준으로 프레임을 정하고, `RANGE`는 ORDER BY 값이 같은 동료 행을 같은 범위로 포함할 수 있다. 중복 정렬값이 있는 누적합에서 결과가 달라질 수 있으므로 행 단위 누적이 목적이면 `ROWS`를 명시하는 편이 안전하다.

## 14. Top-N의 세 방식

```sql
/* Oracle 구식 전체 Top-N: 먼저 정렬하고 바깥에서 ROWNUM 제한 */
SELECT *
FROM (
    SELECT emp_id, emp_name, salary
    FROM employee
    WHERE status = 'ACTIVE'
    ORDER BY salary DESC, emp_id
)
WHERE ROWNUM <= 3;

/* Oracle 12c+ 표준형 전체 Top-N */
SELECT emp_id, emp_name, salary
FROM employee
WHERE status = 'ACTIVE'
ORDER BY salary DESC, emp_id
FETCH FIRST 3 ROWS ONLY;

/* 동점자를 함께 포함하는 전체 Top-N */
SELECT emp_id, emp_name, salary
FROM employee
WHERE status = 'ACTIVE'
ORDER BY salary DESC
FETCH FIRST 3 ROWS WITH TIES;

/* 페이지 단위 조회 */
SELECT emp_id, emp_name, salary
FROM employee
WHERE status = 'ACTIVE'
ORDER BY salary DESC, emp_id
OFFSET 3 ROWS FETCH NEXT 3 ROWS ONLY;

/* 그룹별 Top-N: 윈도우 결과를 인라인 뷰로 감싼 뒤 바깥에서 필터 */
SELECT dept_id, emp_id, emp_name, salary, rn
FROM (
    SELECT e.dept_id,
           e.emp_id,
           e.emp_name,
           e.salary,
           ROW_NUMBER() OVER (
               PARTITION BY e.dept_id
               ORDER BY e.salary DESC, e.emp_id
           ) AS rn
    FROM employee e
    WHERE e.status = 'ACTIVE'
)
WHERE rn <= 2
ORDER BY dept_id, rn;
```

다음은 잘못된 패턴이다.

```sql
/* SELECT에서 만든 rn을 같은 쿼리 블록의 WHERE에서 사용할 수 없다. */
SELECT e.*,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
FROM employee e
WHERE rn <= 3;
```

또한 `ROWNUM > 1`을 같은 단계에서 바로 요구하면 첫 행부터 조건을 만족하지 못해 진행되지 않는다. 정렬과 번호 부여의 순서를 분리해야 한다.

---

# PART G. 계층형 질의와 셀프 조인

## 15. Oracle 계층형 질의

```sql
SELECT
    LEVEL AS hierarchy_level,
    d.dept_id,
    d.parent_dept_id,
    d.dept_name,
    CONNECT_BY_ROOT d.dept_name AS root_department,
    SYS_CONNECT_BY_PATH(d.dept_name, ' > ') AS department_path,
    CONNECT_BY_ISLEAF AS is_leaf,
    CONNECT_BY_ISCYCLE AS is_cycle
FROM department d
START WITH d.parent_dept_id IS NULL
CONNECT BY NOCYCLE PRIOR d.dept_id = d.parent_dept_id
ORDER SIBLINGS BY d.dept_id;
```

- `START WITH`는 루트를 고른다.
- `CONNECT BY PRIOR 부모키 = 자식의 부모키`는 부모에서 자식으로 내려간다.
- `PRIOR`의 위치가 방향을 결정한다.
- `LEVEL`은 루트가 1이다.
- `ORDER SIBLINGS BY`는 계층 구조를 깨뜨리지 않고 같은 부모의 자식끼리 정렬한다.
- `NOCYCLE`은 순환 데이터 때문에 조회가 중단되는 것을 방지하고 `CONNECT_BY_ISCYCLE`로 순환 지점을 표시한다.

## 16. 같은 구조를 셀프 조인으로 한 단계만 조회

```sql
SELECT
    child.dept_name  AS child_department,
    parent.dept_name AS parent_department
FROM department child
LEFT JOIN department parent
  ON parent.dept_id = child.parent_dept_id
ORDER BY child.dept_id;
```

셀프 조인은 한 단계 부모를 붙이는 데 단순하다. 깊이가 가변적인 전체 조직도는 Oracle의 계층형 질의나 SQL Server의 재귀 CTE가 맞다.

---

# PART H. PIVOT과 UNPIVOT

## 17. PIVOT

```sql
/* 분기별 매출을 행에서 열로 회전 */
SELECT *
FROM (
    SELECT
        e.dept_id,
        'Q' || TO_CHAR(s.sale_date, 'Q') AS quarter_name,
        s.amount
    FROM employee e
    JOIN sales s
      ON s.emp_id = e.emp_id
)
PIVOT (
    SUM(amount) AS amount,
    COUNT(amount) AS cnt
    FOR quarter_name IN (
        'Q1' AS q1,
        'Q2' AS q2,
        'Q3' AS q3,
        'Q4' AS q4
    )
)
ORDER BY dept_id;
```

PIVOT 절에 쓰지 않은 입력 열은 암시적 GROUP BY 대상이 된다. 따라서 원본 인라인 뷰에 불필요한 `sale_id` 같은 열을 넣으면 원치 않는 세분화가 생긴다. 필요한 세 열만 먼저 투영한 이유가 여기에 있다.

## 18. CASE를 이용한 조건부 집계

```sql
SELECT
    e.dept_id,
    SUM(CASE WHEN TO_CHAR(s.sale_date, 'Q') = '1' THEN s.amount END) AS q1_amount,
    SUM(CASE WHEN TO_CHAR(s.sale_date, 'Q') = '2' THEN s.amount END) AS q2_amount,
    SUM(CASE WHEN TO_CHAR(s.sale_date, 'Q') = '3' THEN s.amount END) AS q3_amount,
    SUM(CASE WHEN TO_CHAR(s.sale_date, 'Q') = '4' THEN s.amount END) AS q4_amount
FROM employee e
JOIN sales s ON s.emp_id = e.emp_id
GROUP BY e.dept_id
ORDER BY e.dept_id;
```

CASE 조건부 집계는 DBMS 간 이식성이 높고 동적 범주에 대응하기 쉽다. PIVOT은 열 목록이 고정된 보고서에서 읽기 좋다.

## 19. UNPIVOT

```sql
WITH quarterly_sales AS (
    SELECT
        e.dept_id,
        SUM(CASE WHEN TO_CHAR(s.sale_date, 'Q') = '1' THEN s.amount END) AS q1,
        SUM(CASE WHEN TO_CHAR(s.sale_date, 'Q') = '2' THEN s.amount END) AS q2,
        SUM(CASE WHEN TO_CHAR(s.sale_date, 'Q') = '3' THEN s.amount END) AS q3,
        SUM(CASE WHEN TO_CHAR(s.sale_date, 'Q') = '4' THEN s.amount END) AS q4
    FROM employee e
    JOIN sales s ON s.emp_id = e.emp_id
    GROUP BY e.dept_id
)
SELECT dept_id, quarter_name, amount
FROM quarterly_sales
UNPIVOT INCLUDE NULLS (
    amount FOR quarter_name IN (
        q1 AS 'Q1',
        q2 AS 'Q2',
        q3 AS 'Q3',
        q4 AS 'Q4'
    )
)
ORDER BY dept_id, quarter_name;
```

UNPIVOT의 기본 동작은 NULL 값을 제외한다. 누락 분기도 행으로 보존해야 한다는 업무 규칙이 있으므로 여기서는 `INCLUDE NULLS`를 명시했다. 다만 `INCLUDE NULLS`는 Oracle 문법이며 SQL Server의 `UNPIVOT` 구문에서는 지원되지 않는다.

SQL Server에서 NULL인 분기까지 행으로 보존하려면 `CROSS APPLY (VALUES ...)`로 열을 직접 행으로 변환한다. 아래 쿼리는 NULL을 제거하는 WHERE 조건이 없으므로 네 분기를 모두 보존한다.

```sql
/* SQL Server: INCLUDE NULLS와 같은 결과를 만드는 대안 */
SELECT
    q.dept_id,
    v.quarter_name,
    v.amount
FROM quarterly_sales q
CROSS APPLY (VALUES
    ('Q1', q.q1),
    ('Q2', q.q2),
    ('Q3', q.q3),
    ('Q4', q.q4)
) v(quarter_name, amount)
ORDER BY q.dept_id, v.quarter_name;
```

---

# PART I. 최종 종합 조회

## 20. 모든 핵심 연산을 연결한 정답 SQL

집합 연산자와 PIVOT은 결과 모양 자체를 바꾸므로 별도 보고서로 두었다. 아래 최종 조회는 데이터 모델, NULL, 그룹 함수, HAVING, 조인, 상관 서브쿼리, 윈도우 함수, Top-N, 계층형 질의를 하나의 검증 가능한 흐름으로 연결한다.

```sql
WITH
/* 1:N 보너스 상세를 사원당 1행으로 축약 */
bonus_sum AS (
    SELECT
        b.emp_id,
        SUM(b.amount) AS total_bonus,
        COUNT(*) AS bonus_row_count,
        COUNT(b.amount) AS nonnull_bonus_count
    FROM bonus b
    GROUP BY b.emp_id
),

/* 1:N 매출 상세를 사원당 1행으로 축약하고 HAVING으로 의미 있는 그룹만 유지 */
sales_sum AS (
    SELECT
        s.emp_id,
        SUM(s.amount) AS total_sales,
        COUNT(*) AS sales_row_count
    FROM sales s
    GROUP BY s.emp_id
    HAVING COUNT(*) >= 1
),

/* 실제 부서에 속한 ACTIVE 사원과 급여 기준을 모두 통과한 ID 집합 */
eligible_ids AS (
    SELECT e.emp_id
    FROM employee e
    WHERE e.status = 'ACTIVE'
      AND EXISTS (
          SELECT 1
          FROM department d
          WHERE d.dept_id = e.dept_id
      )

    INTERSECT

    SELECT e.emp_id
    FROM employee e
    WHERE e.salary >= (
        SELECT AVG(CAST(e2.salary AS NUMBER(12,2))) * 0.8
        FROM employee e2
        WHERE e2.dept_id = e.dept_id
          AND e2.status = 'ACTIVE'
    )
),

/* 행 입도가 사원 1명 = 1행인 상태에서 표시값과 집계를 결합 */
eligible AS (
    SELECT
        e.emp_id,
        e.dept_id,
        e.emp_name,
        e.salary,
        NVL(bs.total_bonus, 0) AS total_bonus,
        NVL(ss.total_sales, 0) AS total_sales,
        CASE
            WHEN ss.total_sales >= 2500 THEN 'A'
            WHEN ss.total_sales >= 1000 THEN 'B'
            ELSE 'C'
        END AS sales_grade
    FROM employee e
    JOIN eligible_ids i
      ON i.emp_id = e.emp_id
    LEFT JOIN bonus_sum bs
      ON bs.emp_id = e.emp_id
    LEFT JOIN sales_sum ss
      ON ss.emp_id = e.emp_id
),

/* 윈도우 함수는 사원 행을 유지한 채 부서별 순위와 비교값을 붙인다. */
ranked AS (
    SELECT
        e.*,
        ROW_NUMBER() OVER (
            PARTITION BY e.dept_id
            ORDER BY e.salary DESC, e.emp_id
        ) AS rn,
        RANK() OVER (
            PARTITION BY e.dept_id
            ORDER BY e.salary DESC
        ) AS salary_rank,
        AVG(e.salary) OVER (
            PARTITION BY e.dept_id
        ) AS eligible_avg_salary,
        SUM(e.total_sales) OVER (
            PARTITION BY e.dept_id
            ORDER BY e.salary DESC, e.emp_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_sales
    FROM eligible e
),

/* 모든 부서를 계층 순서와 경로로 확장 */
org_tree AS (
    SELECT
        d.dept_id,
        d.dept_name,
        LEVEL AS hierarchy_level,
        SYS_CONNECT_BY_PATH(d.dept_name, ' > ') AS department_path,
        CONNECT_BY_ISLEAF AS is_leaf
    FROM department d
    START WITH d.parent_dept_id IS NULL
    CONNECT BY NOCYCLE PRIOR d.dept_id = d.parent_dept_id
)
SELECT
    o.department_path,
    o.dept_id,
    o.dept_name,
    r.emp_id,
    r.emp_name,
    r.salary,
    r.total_bonus,
    r.total_sales,
    r.rn AS department_row_number
FROM org_tree o
LEFT JOIN ranked r
  ON r.dept_id = o.dept_id
 AND r.rn <= 2
ORDER BY o.department_path, r.rn;
```

### 공통 관계 논리 재실행 결과

Oracle 전용 계층 문법을 재귀 CTE로 치환한 뒤 SQLite에서 동일한 관계 논리를 다시 실행했다.

| 지표 | 확인값 |
|---|---:|
| 출력 행 수 | 12 |
| 출력된 고유 부서 수 | 9 |
| 중복 출력된 비NULL 사원 수 | 0 |
| 개발팀 101 보너스·매출 | 300·3100 |
| 개발팀 102 보너스·매출 | 50·700 |
| 분석팀 202의 전부 NULL인 보너스 합계 | 0 |
| 사원이 없는 부서의 사원 관련 열 | NULL |

이 실행은 조인·집계·상관 조건·윈도우 Top-N·부서 보존 논리를 검증한다. Oracle의 `CONNECT BY`, PIVOT, 자료형, NULL 기본 정렬과 SQL Server의 정수 AVG까지 검증한 것은 아니므로 DBMS별 실행은 별도로 필요하다.

## 21. 왜 이 순서가 정석인가

### 21.1 상세를 먼저 집계한다

`BONUS`와 `SALES`는 모두 사원 한 명에 여러 행이 대응한다. 이 둘을 원본 상태로 동시에 조인하면 보너스 수 × 매출 수만큼 행이 증가할 수 있다. 합계가 부풀고 같은 사원이 여러 순위를 차지한다. 따라서 각각을 사원 단위로 집계한 뒤 조인한다.

### 21.2 상관 서브쿼리의 비교 범위를 외부 행과 맞춘다

급여 기준은 전사 평균이 아니라 같은 부서 ACTIVE 평균이다. 내부 별칭 `e2`의 부서번호를 외부 사원 `e.dept_id`와 연결하고, 평균 계산에도 ACTIVE 조건을 반복한다. 외부만 ACTIVE로 제한하고 평균에는 휴직자를 포함하는 흔한 오류를 막는다.

### 21.3 SQL Server의 정수 AVG 차이까지 차단한다

`AVG(INT)`가 정수로 계산되는 DBMS가 있으므로 평균 전에 명시적으로 소수 자료형으로 CAST한다. 현재 데이터처럼 평균이 우연히 정수일 때도 이식성 문제를 숨기지 않는다.

### 21.4 집합 연산은 교육 목적으로만 넣었다

`eligible_ids`의 INTERSECT는 “ACTIVE이면서 급여 기준도 통과”를 집합의 교집합으로 표현한다. 논리는 맞지만 실무에서는 같은 테이블을 두 번 읽을 수 있으므로 다음 AND 조건이 더 단순할 수 있다.

```sql
WHERE e.status = 'ACTIVE'
  AND EXISTS (...)
  AND e.salary >= (...)
```

즉, 집합 연산자의 올바른 의미를 종합 실습에 포함한 것이지 INTERSECT가 언제나 가장 빠른 정석이라는 뜻은 아니다.

### 21.5 GROUP BY와 윈도우 함수를 순서대로 쓴다

먼저 GROUP BY로 사원당 한 행을 만들고, 그 다음 윈도우 함수로 부서별 순위를 매긴다. 순위를 먼저 매긴 뒤 상세 조인을 하면 순위가 왜곡된다.

### 21.6 Top-N은 윈도우 함수와 다른 쿼리 단계에서 자른다

`ROW_NUMBER`는 SELECT 단계에서 계산되므로 같은 SELECT의 WHERE에서 사용할 수 없다. `ranked` CTE에서 번호를 만든 뒤 최종 단계의 JOIN 조건에서 `rn <= 2`를 적용한다.

### 21.7 `rn <= 2`를 ON에 둔다

모든 부서를 보존해야 하므로 `ORG_TREE`가 최종 기준 집합이다. 사원이 없는 부서는 `r.*`가 NULL인 확장 행으로 남아야 한다. `WHERE r.rn <= 2`로 옮기면 `NULL <= 2`가 UNKNOWN이 되어 빈 부서가 제거된다.

다만 “오른쪽 조건은 언제나 ON”이라는 절대 규칙은 아니다. 인라인 뷰에서 미리 제한하거나, 업무에 따라 `WHERE r.rn <= 2 OR r.rn IS NULL` 같은 형태도 가능하다. 여기서는 의도를 가장 직접적으로 표현하는 ON이 적절하다.

### 21.8 보너스 0과 빈 부서 NULL을 구분한다

`NVL(bs.total_bonus, 0)`은 사원 행이 존재하는 `eligible` 단계에서만 적용된다. 최종 OUTER JOIN에서 사원 자체가 없는 부서에는 `r.total_bonus`가 NULL로 남는다. “보너스 없는 사원은 0, 사원 없는 부서는 NULL”이라는 수정된 명세와 일치한다.

### 21.9 ROW_NUMBER가 유일한 논리적 구현은 아니다

정확히 두 명을 선발하는 의도를 가장 명료하게 표현하므로 ROW_NUMBER를 사용했다. 하지만 `ORDER BY salary DESC, emp_id`처럼 고유한 보조키가 포함되면 RANK나 DENSE_RANK도 같은 결과를 낼 수 있다. 함수 이름만 외우지 말고 동률을 만드는 ORDER BY 값 전체를 확인해야 한다.

### 21.10 계층을 먼저 보존 집합으로 만든다

조직 경로와 모든 부서를 먼저 만들고 여기에 사원 Top-N을 붙인다. 사원에서 시작해 부서를 조인하면 사원이 없는 부서를 복원할 수 없다. “무엇을 반드시 보존해야 하는가”가 FROM의 출발점을 결정한다.

---

# PART J. 감사용 역질의

## 22. 원천 품질과 최종 결과 검증

```sql
/* 원천의 고아 부서번호 */
SELECT r.*
FROM stg_employee_raw r
WHERE r.dept_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM department d
      WHERE d.dept_id = r.dept_id
  );

/* 원천의 NULL 부서번호 */
SELECT r.*
FROM stg_employee_raw r
WHERE r.dept_id IS NULL;

/* 조인 전후 행 수와 고유 사원 수 비교 */
SELECT COUNT(*) AS employee_rows,
       COUNT(DISTINCT emp_id) AS distinct_employees
FROM employee;

SELECT COUNT(*) AS joined_rows,
       COUNT(DISTINCT e.emp_id) AS distinct_employees
FROM employee e
LEFT JOIN bonus b ON b.emp_id = e.emp_id;

/* 사원별 보너스 원본 합계 */
SELECT emp_id,
       COUNT(*) AS bonus_rows,
       COUNT(amount) AS nonnull_amounts,
       NVL(SUM(amount), 0) AS total_bonus
FROM bonus
GROUP BY emp_id
ORDER BY emp_id;

/* 한 사원이 최종 Top-N 결과에서 중복되는지 확인하는 기본 형태 */
SELECT emp_id, COUNT(*) AS cnt
FROM final_result
WHERE emp_id IS NOT NULL
GROUP BY emp_id
HAVING COUNT(*) > 1;

/* 부서별 사원이 최대 2명인지 확인 */
SELECT dept_id, COUNT(emp_id) AS employee_count
FROM final_result
GROUP BY dept_id
HAVING COUNT(emp_id) > 2;
```

`FINAL_RESULT`는 최종 SELECT를 뷰나 CTE로 감쌌다고 가정한 이름이다. 검증 쿼리에서 결과가 0행이어야 하는 조건과 특정 수치가 나와야 하는 조건을 미리 정해야 실행이 감사로 완성된다.

---

# PART K. 트랜잭션

## 23. 원자성과 SAVEPOINT

```sql
SAVEPOINT before_salary_change;

UPDATE employee
SET salary = salary * 1.05
WHERE dept_id = 11;

INSERT INTO bonus (bonus_id, emp_id, bonus_date, amount)
VALUES (99, 101, SYSDATE, 250);

/* 검증 실패를 가정하면 두 변경을 함께 되돌린다. */
ROLLBACK TO before_salary_change;

/* 검증에 성공한 경우에만 COMMIT을 실행한다. */
-- COMMIT;
```

트랜잭션의 원자성은 여러 변경을 모두 반영하거나 모두 취소하는 처리 규칙이다. ERD의 필수참여나 식별관계와 같은 구조 규칙과 동일한 개념이 아니다.

---

# PART L. SQL Server 변환 핵심

## 24. DBMS 차이표

| 목적 | Oracle | SQL Server |
|---|---|---|
| 현재 시각 | `SYSDATE` | `GETDATE()` |
| NULL 대체 2항 | `NVL(x, 0)` | `ISNULL(x, 0)` |
| 표준 다항 NULL 대체 | `COALESCE(...)` | `COALESCE(...)` |
| 문자열 길이 | `LENGTH(x)` | `LEN(x)` |
| 문자열 일부 | `SUBSTR(x,1,2)` | `SUBSTRING(x,1,2)` |
| 숫자 버림 | `TRUNC(x,2)` | 별도 계산 또는 `ROUND(x,2,1)` 검토 |
| 날짜 문자화 | `TO_CHAR(date, format)` | `CONVERT` 또는 `FORMAT` |
| 문자열 날짜화 | `TO_DATE` | `CONVERT`·`CAST` |
| 집합 차집합 | `MINUS` | `EXCEPT` |
| 전체 Top-N | `FETCH FIRST`, `ROWNUM` | `TOP`, `OFFSET ... FETCH` |
| 계층 | `CONNECT BY` | 재귀 CTE |
| 모집단 분산 | `VAR_POP(x)` | `VARP(x)` |
| 표본 분산 | `VARIANCE(x)` 또는 `VAR_SAMP(x)` | `VAR(x)` |
| 모집단 표준편차 | `STDDEV_POP(x)` | `STDEVP(x)` |
| 표본 표준편차 | `STDDEV(x)` 또는 `STDDEV_SAMP(x)` | `STDEV(x)` |
| 구성비 분석 함수 | `RATIO_TO_REPORT(x) OVER (...)` | `x * 1.0 / NULLIF(SUM(x) OVER (...), 0)` |
| UNPIVOT의 NULL 행 보존 | `UNPIVOT INCLUDE NULLS` | `CROSS APPLY (VALUES ...)` 등으로 구현 |
| Oracle 전용 조건함수 | `DECODE` | `CASE` |
| NULL 기본 정렬 | ASC 뒤, DESC 앞 | NULL을 낮은 값으로 취급 |
| CTE 시작 | `WITH` | 앞 문장과 충돌 방지를 위해 `;WITH` 권장 |

## 25. SQL Server 재귀 CTE 계층형 질의

```sql
;WITH org_tree AS (
    SELECT
        d.dept_id,
        d.parent_dept_id,
        d.dept_name,
        1 AS hierarchy_level,
        CAST(d.dept_name AS VARCHAR(4000)) AS department_path
    FROM department d
    WHERE d.parent_dept_id IS NULL

    UNION ALL

    SELECT
        c.dept_id,
        c.parent_dept_id,
        c.dept_name,
        p.hierarchy_level + 1,
        CAST(p.department_path + ' > ' + c.dept_name AS VARCHAR(4000))
    FROM department c
    JOIN org_tree p
      ON p.dept_id = c.parent_dept_id
)
SELECT *
FROM org_tree
ORDER BY department_path
OPTION (MAXRECURSION 100);
```

SQL Server에서 급여가 정수형이라면 평균 전에 다음처럼 변환한다.

```sql
AVG(CAST(e2.salary AS DECIMAL(12,2))) * 0.8
```

SQLite에서 관계 논리를 검증했더라도 Oracle·SQL Server의 자료형, NULL 정렬, 계층 문법, PIVOT 문법, 실행 계획까지 검증한 것은 아니다. DBMS별 예제는 해당 DBMS에서 다시 실행해야 한다.

---

# PART M. 시험용으로 쪼개는 방법

이 종합 스크립트를 SQLD 한 문제로 그대로 내면 과도하다. 다음처럼 한 판단씩 분리하면 시험형 문제가 된다.

1. `LEFT JOIN`의 오른쪽 조건을 ON과 WHERE 중 어디에 둘 것인가
2. 보너스 상세 조인 전 GROUP BY가 필요한 이유
3. `COUNT(*)`, `COUNT(amount)`, `SUM(amount)`의 NULL 처리 차이
4. `NOT IN (..., NULL)`과 `NOT EXISTS`의 결과 차이
5. 상관 서브쿼리의 외부 참조 위치
6. UNION과 UNION ALL의 중복 처리
7. WHERE와 HAVING의 적용 시점
8. ROLLUP·CUBE·GROUPING SETS 결과 행 수
9. ROW_NUMBER·RANK·DENSE_RANK의 동률 처리
10. LAST_VALUE의 기본 프레임 함정
11. 전체 Top-N과 그룹별 Top-N의 차이
12. CONNECT BY PRIOR 방향과 LEVEL
13. PIVOT의 암시적 그룹화
14. UNPIVOT의 NULL 제외와 INCLUDE NULLS
15. SQL Server의 정수 AVG와 Oracle의 숫자 계산 차이

종합 실습에서는 이 개념들이 실제로 어떤 순서로 연결되는지 보고, 시험 연습에서는 한 번에 하나의 결과를 직접 계산하는 것이 가장 효율적이다.

---

# PART N. SQL 관리 구문

## 26. 관리 구문 전체 지도

| 분류 | 핵심 목적 | 대표 명령 |
|---|---|---|
| DML | 테이블의 행을 삽입·수정·삭제·병합 | `INSERT`, `UPDATE`, `DELETE`, `MERGE` |
| TCL | 트랜잭션의 확정·취소·중간점 제어 | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |
| DDL | 데이터베이스 객체의 구조 정의·변경·삭제 | `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME` |
| DCL | 권한 부여·회수 | `GRANT`, `REVOKE` |

SQLD에서는 명령 이름뿐 아니라 다음 세 질문을 함께 묻는다.

1. 행만 바꾸는가, 객체 구조까지 바꾸는가?
2. WHERE 조건을 사용할 수 있는가?
3. 트랜잭션에서 취소할 수 있는가? 이때 Oracle과 SQL Server가 같은가?

## 27. DML - 행 데이터 조작

### 27.1 INSERT

```sql
/* 컬럼 목록을 명시하는 기본형 - 유지보수에 가장 안전 */
INSERT INTO product (
    product_id,
    category,
    product_name,
    list_price
)
VALUES (
    4,
    'DB',
    'SQL관리구문교재',
    32000
);

/* 컬럼을 생략하면 DEFAULT가 있으면 기본값, 없으면 NULL */
INSERT INTO employee (
    emp_id,
    dept_id,
    manager_id,
    emp_name,
    email,
    salary
)
VALUES (
    501,
    30,
    100,
    '품질담당',
    'qa1@example.com',
    4300
);

/* EMPLOYEE.STATUS와 HIRE_DATE는 DEFAULT 사용 */

/* INSERT ... SELECT: 조회 결과 여러 행을 한 번에 적재 */
CREATE TABLE active_employee_snapshot AS
SELECT *
FROM employee
WHERE 1 = 0;

INSERT INTO active_employee_snapshot
SELECT *
FROM employee
WHERE status = 'ACTIVE';
```

컬럼 목록을 생략하는 문법도 가능하지만 테이블 컬럼 순서·개수·자료형을 모두 맞춰야 하고, 이후 컬럼이 추가되면 기존 INSERT가 깨질 수 있다. 시험에서 생략 가능 여부와 실무상 권장 여부는 다른 질문이다.

대표 오류는 다음과 같다.

- 기본키에 NULL 입력
- NOT NULL 컬럼에 NULL 입력
- PK 또는 UNIQUE 값 중복
- 부모에 없는 값을 외래키에 입력
- CHECK 범위 위반
- 대응할 수 없는 자료형 입력
- INSERT 컬럼 수와 VALUES 값 수 불일치

### 27.2 UPDATE

```sql
UPDATE employee
SET salary = salary * 1.05,
    status = 'ACTIVE'
WHERE dept_id = 11;
```

`WHERE`를 생략하면 테이블의 모든 행이 수정된다. 실행 전에 같은 WHERE를 SELECT에 적용하여 대상 PK와 행 수를 확인하는 것이 안전하다.

```sql
SELECT emp_id, salary
FROM employee
WHERE dept_id = 11;
```

### 27.3 DELETE

```sql
DELETE FROM bonus
WHERE bonus_date < DATE '2025-01-01';
```

- WHERE를 생략하면 모든 행을 삭제한다.
- 테이블 구조와 제약조건은 남는다.
- 아직 COMMIT하지 않은 같은 트랜잭션의 DELETE는 일반적으로 ROLLBACK할 수 있다.
- 부모 행을 삭제할 때 자식 FK가 존재하면 참조 동작에 따라 거부·연쇄삭제·NULL 변경 등이 발생한다.

### 27.4 MERGE

MERGE는 소스와 대상의 대응 여부에 따라 UPDATE·INSERT를 한 문장으로 분기한다.

```sql
MERGE INTO product target
USING (
    SELECT 1 AS product_id,
           'DB' AS category,
           'SQLD교재 개정판' AS product_name,
           33000 AS list_price
    FROM dual
    UNION ALL
    SELECT 5, 'QA', '감사실습교재', 37000
    FROM dual
) source
ON (target.product_id = source.product_id)
WHEN MATCHED THEN
    UPDATE SET
        target.category = source.category,
        target.product_name = source.product_name,
        target.list_price = source.list_price
WHEN NOT MATCHED THEN
    INSERT (
        product_id,
        category,
        product_name,
        list_price
    )
    VALUES (
        source.product_id,
        source.category,
        source.product_name,
        source.list_price
    );
```

- `MATCHED`는 ON 조건이 일치한 대상 행을 처리한다.
- `NOT MATCHED`는 대응 대상이 없는 소스 행을 삽입한다.
- Oracle은 MATCHED의 UPDATE 뒤에 조건부 `DELETE WHERE`를 둘 수 있고, SQL Server는 별도의 `WHEN MATCHED ... THEN DELETE` 형태를 지원한다. 삭제 문법을 두 DBMS 공통이라고 외우면 안 된다.
- 한 대상 행에 여러 소스 행이 대응하지 않도록 MERGE 키의 유일성을 먼저 감사해야 한다.

## 28. TCL - 트랜잭션 제어

### 28.1 트랜잭션과 ACID

트랜잭션은 하나의 업무를 구성하는 하나 이상의 SQL 작업 단위다.

| 성질 | 의미 | 이 스크립트의 예 |
|---|---|---|
| Atomicity | 모두 성공하거나 모두 취소 | 급여 수정과 보너스 입력을 함께 확정·취소 |
| Consistency | 실행 전후 제약과 업무 규칙 유지 | FK·CHECK·잔액 규칙 유지 |
| Isolation | 동시 트랜잭션의 부적절한 간섭 방지 | 다른 세션의 중간 변경을 함부로 읽지 않음 |
| Durability | COMMIT 결과를 장애 후에도 보존 | 확정된 급여 변경의 영구 보존 |

원자성은 ERD의 필수참여나 식별관계와 다르다. 원자성은 **처리 단위**, 관계 선택성과 식별관계는 **데이터 구조 규칙**이다.

### 28.2 Oracle 트랜잭션

Oracle은 보통 첫 DML에서 트랜잭션이 시작되고 COMMIT 또는 ROLLBACK까지 유지된다.

```sql
SAVEPOINT sv_before_change;

UPDATE employee
SET salary = salary + 100
WHERE emp_id = 101;

INSERT INTO bonus (bonus_id, emp_id, bonus_date, amount)
VALUES (100, 101, SYSDATE, 100);

/* 중간점 이후만 취소 */
ROLLBACK TO sv_before_change;

/* 전체 변경 확정 */
COMMIT;
```

COMMIT 이후에는 이전 상태로 일반 ROLLBACK할 수 없다. Oracle에서 DDL을 실행하면 앞선 트랜잭션이 암시적으로 COMMIT될 수 있으므로 DML 사이에 DDL을 섞지 않는다.

### 28.3 SQL Server 명시적 트랜잭션

```sql
BEGIN TRANSACTION;

SAVE TRANSACTION sv_before_change;

UPDATE employee
SET salary = salary + 100
WHERE emp_id = 101;

INSERT INTO bonus (bonus_id, emp_id, bonus_date, amount)
VALUES (100, 101, GETDATE(), 100);

ROLLBACK TRANSACTION sv_before_change;

COMMIT TRANSACTION;
```

SQL Server의 기본 연결 동작은 보통 각 문장을 하나의 트랜잭션으로 즉시 확정하는 autocommit 모드다. `BEGIN TRANSACTION`을 사용하거나 `SET IMPLICIT_TRANSACTIONS ON`을 설정하면 직접 종료해야 한다.

### 28.4 LOCK

LOCK은 동시에 접근하는 트랜잭션이 같은 데이터에 충돌하는 것을 조정한다.

- 행·키·페이지·테이블 또는 키 범위 등에 잠금이 설정될 수 있다.
- 변경 작업의 트랜잭션 잠금은 일반적으로 COMMIT이나 ROLLBACK에서 해제된다.
- 잠금을 강하게 오래 유지하면 일관성은 높아질 수 있지만 대기·교착상태·동시성 저하가 발생할 수 있다.
- “LOCK은 무조건 행 하나만 잠근다” 또는 “SELECT는 잠금과 무관하다”라고 단정하면 안 된다.

Oracle에서 현재 조회한 행을 다른 세션이 수정하지 못하게 선점하는 대표 문법은 다음과 같다.

```sql
SELECT emp_id, salary
FROM employee
WHERE emp_id = 101
FOR UPDATE;
```

### 28.5 격리 수준과 동시성 문제

| ANSI 수준 | Dirty Read | Non-repeatable Read | Phantom Read |
|---|---:|---:|---:|
| READ UNCOMMITTED | 가능 | 가능 | 가능 |
| READ COMMITTED | 방지 | 가능 | 가능 |
| REPEATABLE READ | 방지 | 방지 | 가능 |
| SERIALIZABLE | 방지 | 방지 | 방지 |

- Dirty Read: 다른 트랜잭션이 아직 COMMIT하지 않은 값을 읽는다.
- Non-repeatable Read: 같은 행을 다시 읽었더니 UPDATE·DELETE 때문에 값이 달라졌다.
- Phantom Read: 같은 조건으로 다시 조회했더니 INSERT·DELETE 때문에 행 집합이 달라졌다.

이 표는 ANSI 현상 기반의 시험용 분류다. DBMS 구현은 추가 수준과 버전 관리 방식을 가질 수 있다.

- Oracle은 일반적으로 `READ COMMITTED`, `SERIALIZABLE`, 읽기 전용 트랜잭션을 제공하며 `READ UNCOMMITTED`와 `REPEATABLE READ`를 같은 이름으로 제공하지 않는다.
- SQL Server는 네 수준 외에도 `SNAPSHOT`, `READ_COMMITTED_SNAPSHOT` 같은 행 버전 관리 방식을 제공할 수 있다.

## 29. DDL - 객체 구조 정의

### 29.1 CREATE

```sql
CREATE TABLE sql_exam_result (
    attempt_id    NUMBER(8)      CONSTRAINT pk_sql_exam_result PRIMARY KEY,
    emp_id        NUMBER(6)      NOT NULL,
    exam_name     VARCHAR2(50)   DEFAULT 'SQLD' NOT NULL,
    score         NUMBER(5,2),
    taken_at      TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT ck_sql_exam_score CHECK (score BETWEEN 0 AND 100),
    CONSTRAINT fk_sql_exam_employee
        FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);
```

주요 Oracle 자료형은 `VARCHAR2(n)`, `CHAR(n)`, `NUMBER(m,n)`, `DATE`, `TIMESTAMP`다. SQL Server에서는 보통 `VARCHAR`, `CHAR`, `INT`·`DECIMAL`, `DATE`, `DATETIME2` 등을 사용한다.

제약조건의 역할:

- PRIMARY KEY: 행 식별, 중복·NULL 금지, 테이블당 하나지만 복합키 가능
- UNIQUE: 후보키 유일성 보장, 한 테이블에 여러 개 가능
- NOT NULL: 필수 속성의 값 부재 금지
- CHECK: 값의 범위·조건 제한
- FOREIGN KEY: 부모의 PK 또는 UNIQUE 후보키 참조
- DEFAULT: INSERT에서 값이 생략될 때 적용되는 기본값

`UNIQUE는 NULL을 허용한다`는 요약만 외우면 부족하다. Oracle은 NULL을 일반 값처럼 동일 비교하지 않아 여러 NULL이 가능할 수 있지만, SQL Server의 일반 단일 컬럼 UNIQUE 제약은 보통 NULL 하나만 허용한다. DBMS별 동작을 확인해야 한다.

외래키 참조 동작도 다르다.

- Oracle: 대표적으로 `ON DELETE CASCADE`, `ON DELETE SET NULL`
- SQL Server: `ON DELETE`·`ON UPDATE`에 `CASCADE`, `SET NULL`, `SET DEFAULT`, `NO ACTION` 등을 지정 가능

따라서 `SET DEFAULT`와 `ON UPDATE CASCADE`를 Oracle에서도 같은 문법으로 쓸 수 있다고 암기하면 안 된다.

### 29.2 ALTER

```sql
/* Oracle: 컬럼 추가 */
ALTER TABLE sql_exam_result
ADD result_note VARCHAR2(200);

/* Oracle: 자료형·속성 변경 */
ALTER TABLE sql_exam_result
MODIFY result_note VARCHAR2(500);

/* Oracle: 컬럼명 변경 */
ALTER TABLE sql_exam_result
RENAME COLUMN result_note TO review_note;

/* 제약조건 추가 */
ALTER TABLE sql_exam_result
ADD CONSTRAINT uq_sql_exam_attempt UNIQUE (emp_id, exam_name, taken_at);
```

SQL Server에서는 자료형 변경에 `ALTER COLUMN`을 사용하고 컬럼명 변경은 일반적으로 `sp_rename`을 사용한다.

```sql
ALTER TABLE sql_exam_result
ALTER COLUMN review_note VARCHAR(500) NULL;

EXEC sp_rename
    'sql_exam_result.review_note',
    'audit_note',
    'COLUMN';
```

### 29.3 RENAME·TRUNCATE·DROP

```sql
/* Oracle */
RENAME sql_exam_result TO sql_exam_result_old;

/* 전체 행 제거, WHERE 사용 불가, 구조 유지 */
TRUNCATE TABLE active_employee_snapshot;

/* 객체와 데이터·종속 구조 삭제 */
DROP TABLE sql_exam_result_old CASCADE CONSTRAINTS;
```

### 29.4 DELETE·TRUNCATE·DROP 비교

| 항목 | DELETE | TRUNCATE | DROP |
|---|---|---|---|
| 분류 | DML | DDL | DDL |
| 일부 행 조건 | WHERE 가능 | 불가 | 해당 없음 |
| 모든 행 제거 | 가능 | 가능 | 가능 |
| 테이블 구조 | 유지 | 유지 | 삭제 |
| 일반적 용도 | 조건부 행 삭제 | 전체 행의 빠른 제거 | 객체 제거 |
| Oracle 일반 ROLLBACK | COMMIT 전 가능 | 불가 | 불가 |

“TRUNCATE와 DDL은 항상 ROLLBACK 불가”는 Oracle 중심의 시험 요약이다. SQL Server에서는 많은 DDL과 TRUNCATE를 명시적 트랜잭션 안에서 ROLLBACK할 수 있다.

```sql
/* SQL Server 예시 */
BEGIN TRANSACTION;
TRUNCATE TABLE active_employee_snapshot;
ROLLBACK TRANSACTION;
```

따라서 문제에서 DBMS를 지정했는지 먼저 확인해야 한다.

## 30. VIEW

VIEW는 SELECT 정의를 객체로 저장해 테이블처럼 조회하게 한다.

```sql
CREATE OR REPLACE VIEW v_active_employee_public AS
SELECT
    e.emp_id,
    e.dept_id,
    e.emp_name,
    e.status
FROM employee e
WHERE e.status = 'ACTIVE'
WITH CHECK OPTION;
```

```sql
SELECT *
FROM v_active_employee_public
ORDER BY dept_id, emp_id;
```

### 30.1 장점

- 편의성: 반복되는 SELECT를 재사용한다.
- 보안성: 급여·이메일 같은 열을 제외해 필요한 정보만 노출할 수 있다.
- 논리적 독립성: 사용자에게 안정된 조회 인터페이스를 제공한다.

### 30.2 DML 가능 여부

- 단일 기반 테이블의 단순 뷰는 일정 조건에서 INSERT·UPDATE·DELETE가 가능하다.
- 집계, GROUP BY, DISTINCT, 집합 연산, 일부 조인 등이 포함된 복합 뷰는 DML이 제한될 수 있다.
- `WITH CHECK OPTION`은 뷰의 WHERE 조건을 벗어나는 변경을 막는다.
- Oracle의 조인 뷰에서는 키 보존 테이블 여부 같은 추가 조건을 확인해야 한다.

### 30.3 저장과 인덱스에 대한 정확한 표현

일반 뷰는 결과 행을 자체 저장하지 않고 조회 시 정의된 SELECT를 수행한다. 다만 “모든 VIEW는 어떤 DBMS에서도 자체 인덱스를 가질 수 없다”는 절대 명제는 틀릴 수 있다.

- SQL Server에는 조건을 만족하는 `indexed view`가 있다.
- Oracle에는 결과를 물리적으로 저장하는 별도 객체인 `materialized view`가 있다.

SQLD 기본 문제에서 단순히 VIEW라고 하면 일반적인 가상 테이블을 전제로 판단하되, DBMS 예외를 표준 규칙처럼 섞지 않는다.

### 30.4 저장 VIEW와 인라인 뷰

| 구분 | 저장 VIEW | 인라인 뷰 |
|---|---|---|
| 위치 | 데이터베이스 객체 | 한 SQL문의 FROM절 서브쿼리 |
| 이름과 수명 | 이름을 가지고 DROP할 때까지 존재 | 해당 SQL 실행 동안만 존재 |
| 재사용 | 여러 SQL에서 가능 | 작성된 한 문장 안에서 사용 |
| 권한 부여 | 객체 단위 가능 | 독립 객체가 아니므로 불가 |

```sql
/* 인라인 뷰 */
SELECT x.dept_id, x.avg_salary
FROM (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employee
    GROUP BY dept_id
) x
WHERE x.avg_salary >= 5000;
```

## 31. DCL 보충

관리 구문의 분류를 완성하려면 권한 제어도 함께 구분한다.

```sql
GRANT SELECT ON v_active_employee_public TO report_user;
REVOKE SELECT ON v_active_employee_public FROM report_user;
```

- `GRANT`는 객체 또는 시스템 권한을 부여한다.
- `REVOKE`는 부여한 권한을 회수한다.
- 사용자·권한 체계와 연쇄 회수 방식은 DBMS에 따라 차이가 있다.

## 32. 관리 구문 시험 판단 규칙

1. `UPDATE`와 `DELETE`에서 WHERE 생략은 문법 오류가 아니라 전체 행 대상이다.
2. `INSERT ... SELECT`는 SELECT 결과의 여러 행을 삽입할 수 있다.
3. INSERT 컬럼을 생략했다고 항상 NULL이 들어가는 것은 아니다. DEFAULT가 있으면 기본값이 적용된다.
4. MERGE의 ON 조건은 대상 한 행에 여러 소스 행이 대응하지 않도록 감사한다.
5. COMMIT 후에는 일반 ROLLBACK으로 이전 상태를 복구할 수 없다.
6. SAVEPOINT는 트랜잭션 전체가 아니라 지정 지점 이후의 일부만 되돌릴 수 있게 한다.
7. Dirty Read·Non-repeatable Read·Phantom Read를 값 변경과 행 집합 변경으로 구분한다.
8. Oracle의 DDL·TRUNCATE와 SQL Server의 트랜잭션 가능 DDL을 동일하게 취급하지 않는다.
9. DELETE는 행, TRUNCATE는 전체 행, DROP은 객체 자체를 제거한다.
10. 일반 VIEW와 인라인 뷰, materialized/indexed view를 구분한다.
