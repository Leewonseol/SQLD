/*
  SQLD 전개념 종합 실행 스크립트 - Oracle
  목적: SQL Developer / SQLcl에서 위에서 아래로 실행
  주의: 학습용 객체를 DROP 후 다시 생성한다.
*/

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

/* ============================================================
   0. 재실행을 위한 정리: 자식 -> 부모 순서
   ============================================================ */
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_active_employee_summary'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE employee_project PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE employee_status_history PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE sales PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE bonus PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE regular_employee PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE contract_employee PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE project PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE product PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE salary_grade PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE employee PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE department PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE stg_employee_raw PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/

/* ============================================================
   1. DDL: 정규화, PK/FK, 자기참조, M:N 해소, 이력
   ============================================================ */
CREATE TABLE department (
    dept_id         NUMBER(4) CONSTRAINT pk_department PRIMARY KEY,
    parent_dept_id  NUMBER(4),
    dept_name       VARCHAR2(40) CONSTRAINT nn_department_name NOT NULL,
    dept_type       VARCHAR2(10) DEFAULT 'TEAM' NOT NULL,
    CONSTRAINT uq_department_name UNIQUE (dept_name),
    CONSTRAINT ck_department_type CHECK (dept_type IN ('ROOT','DIVISION','TEAM')),
    CONSTRAINT fk_department_parent FOREIGN KEY (parent_dept_id)
        REFERENCES department(dept_id)
);

CREATE TABLE employee (
    emp_id      NUMBER(6) CONSTRAINT pk_employee PRIMARY KEY,
    dept_id     NUMBER(4),
    manager_id  NUMBER(6),
    emp_name    VARCHAR2(30) CONSTRAINT nn_employee_name NOT NULL,
    email       VARCHAR2(80),
    salary      NUMBER(10,2),
    status      VARCHAR2(10) DEFAULT 'ACTIVE' NOT NULL,
    hire_date   DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT uq_employee_email UNIQUE (email),
    CONSTRAINT ck_employee_salary CHECK (salary >= 0),
    CONSTRAINT ck_employee_status CHECK (status IN ('ACTIVE','INACTIVE','LEAVE')),
    CONSTRAINT fk_employee_department FOREIGN KEY (dept_id) REFERENCES department(dept_id),
    CONSTRAINT fk_employee_manager FOREIGN KEY (manager_id) REFERENCES employee(emp_id)
);

CREATE TABLE regular_employee (
    emp_id NUMBER(6) CONSTRAINT pk_regular_employee PRIMARY KEY,
    pension_grade VARCHAR2(10) NOT NULL,
    CONSTRAINT fk_regular_employee FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE contract_employee (
    emp_id NUMBER(6) CONSTRAINT pk_contract_employee PRIMARY KEY,
    contract_end DATE NOT NULL,
    CONSTRAINT fk_contract_employee FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE bonus (
    bonus_id NUMBER(8) CONSTRAINT pk_bonus PRIMARY KEY,
    emp_id NUMBER(6) NOT NULL,
    bonus_date DATE NOT NULL,
    amount NUMBER(10,2),
    CONSTRAINT fk_bonus_employee FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE product (
    product_id NUMBER(6) CONSTRAINT pk_product PRIMARY KEY,
    category VARCHAR2(20) NOT NULL,
    product_name VARCHAR2(40) NOT NULL,
    list_price NUMBER(10,2) CHECK (list_price >= 0),
    CONSTRAINT uq_product_name UNIQUE (product_name)
);

CREATE TABLE sales (
    sale_id NUMBER(8) CONSTRAINT pk_sales PRIMARY KEY,
    emp_id NUMBER(6) NOT NULL,
    product_id NUMBER(6) NOT NULL,
    sale_date DATE NOT NULL,
    channel VARCHAR2(10) NOT NULL,
    amount NUMBER(12,2),
    CONSTRAINT ck_sales_channel CHECK (channel IN ('ONLINE','OFFLINE')),
    CONSTRAINT fk_sales_employee FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    CONSTRAINT fk_sales_product FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE salary_grade (
    grade_name VARCHAR2(10) CONSTRAINT pk_salary_grade PRIMARY KEY,
    min_salary NUMBER(10,2) NOT NULL,
    max_salary NUMBER(10,2) NOT NULL,
    CONSTRAINT ck_salary_grade_range CHECK (max_salary >= min_salary)
);

CREATE TABLE project (
    project_id NUMBER(6) CONSTRAINT pk_project PRIMARY KEY,
    project_name VARCHAR2(50) NOT NULL
);

CREATE TABLE employee_project (
    emp_id NUMBER(6),
    project_id NUMBER(6),
    role_name VARCHAR2(30),
    CONSTRAINT pk_employee_project PRIMARY KEY (emp_id, project_id),
    CONSTRAINT fk_ep_employee FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    CONSTRAINT fk_ep_project FOREIGN KEY (project_id) REFERENCES project(project_id)
);

CREATE TABLE employee_status_history (
    emp_id NUMBER(6),
    start_date DATE,
    end_date DATE,
    status VARCHAR2(10) NOT NULL,
    CONSTRAINT pk_employee_status_history PRIMARY KEY (emp_id, start_date),
    CONSTRAINT ck_history_period CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT fk_history_employee FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

/* 원천 오류를 보존하는 스테이징에는 의도적으로 FK를 두지 않는다. */
CREATE TABLE stg_employee_raw (
    emp_id NUMBER(6), dept_id NUMBER(4), emp_name VARCHAR2(30),
    salary NUMBER(10,2), status VARCHAR2(10)
);

/* ============================================================
   2. DML: 부모를 먼저 넣어 FK 순서를 명확히 한다.
   ============================================================ */
INSERT INTO department VALUES (1,  NULL, '전사',      'ROOT');
INSERT INTO department VALUES (10, 1,    '기술본부',  'DIVISION');
INSERT INTO department VALUES (20, 1,    '영업본부',  'DIVISION');
INSERT INTO department VALUES (11, 10,   '개발팀',    'TEAM');
INSERT INTO department VALUES (12, 10,   '분석팀',    'TEAM');
INSERT INTO department VALUES (21, 20,   '온라인팀',  'TEAM');
INSERT INTO department VALUES (22, 20,   '오프라인팀','TEAM');
INSERT INTO department VALUES (30, 1,    '품질팀',    'TEAM');
INSERT INTO department VALUES (40, 1,    '무인부서',  'TEAM');

INSERT INTO employee VALUES (100,1,NULL,'대표','ceo@example.com',10000,'ACTIVE',DATE '2020-01-01');
INSERT INTO employee VALUES (110,10,100,'기술본부장','cto@example.com',8000,'ACTIVE',DATE '2021-01-01');
INSERT INTO employee VALUES (120,20,100,'영업본부장','cso@example.com',7800,'ACTIVE',DATE '2021-02-01');
INSERT INTO employee VALUES (101,11,110,'김개발','dev1@example.com',5000,'ACTIVE',DATE '2023-01-10');
INSERT INTO employee VALUES (102,11,110,'이개발','dev2@example.com',4000,'ACTIVE',DATE '2023-02-10');
INSERT INTO employee VALUES (103,11,110,'박휴직','dev3@example.com',3000,'INACTIVE',DATE '2023-03-10');
INSERT INTO employee VALUES (201,12,110,'최분석','ana1@example.com',6000,'ACTIVE',DATE '2022-01-10');
INSERT INTO employee VALUES (202,12,110,'정분석','ana2@example.com',6000,'ACTIVE',DATE '2022-02-10');
INSERT INTO employee VALUES (301,21,120,'온영업','on1@example.com',4500,'ACTIVE',DATE '2024-01-10');
INSERT INTO employee VALUES (302,21,120,'온신입','on2@example.com',3500,'ACTIVE',DATE '2025-01-10');
INSERT INTO employee VALUES (401,22,120,'한운영','off1@example.com',4500,'INACTIVE',DATE '2024-02-10');

INSERT ALL
  INTO regular_employee VALUES (100,'P1') INTO regular_employee VALUES (110,'P2')
  INTO regular_employee VALUES (120,'P2') INTO regular_employee VALUES (101,'P3')
  INTO regular_employee VALUES (102,'P3') INTO regular_employee VALUES (201,'P3')
  INTO regular_employee VALUES (202,'P3') INTO regular_employee VALUES (301,'P3')
  INTO contract_employee VALUES (302,DATE '2026-12-31')
SELECT 1 FROM dual;

INSERT ALL
  INTO bonus VALUES (1,101,DATE '2026-01-31',100)
  INTO bonus VALUES (2,101,DATE '2026-02-28',200)
  INTO bonus VALUES (3,102,DATE '2026-01-31',50)
  INTO bonus VALUES (4,202,DATE '2026-01-31',NULL)
  INTO bonus VALUES (5,301,DATE '2026-01-31',150)
SELECT 1 FROM dual;

INSERT ALL
  INTO product VALUES (1,'DB','SQLD교재',30000)
  INTO product VALUES (2,'AI','AI교재',40000)
  INTO product VALUES (3,'QA','데이터품질교재',35000)
SELECT 1 FROM dual;

INSERT ALL
  INTO salary_grade VALUES ('LOW',0,3999.99)
  INTO salary_grade VALUES ('MID',4000,5999.99)
  INTO salary_grade VALUES ('HIGH',6000,99999999)
SELECT 1 FROM dual;

INSERT ALL
  INTO sales VALUES (1,101,1,DATE '2026-01-05','ONLINE',1000)
  INTO sales VALUES (2,101,2,DATE '2026-04-05','ONLINE',1200)
  INTO sales VALUES (3,101,3,DATE '2026-07-05','OFFLINE',900)
  INTO sales VALUES (4,102,1,DATE '2026-01-06','ONLINE',700)
  INTO sales VALUES (5,102,3,DATE '2026-10-06','OFFLINE',NULL)
  INTO sales VALUES (6,201,2,DATE '2026-02-05','ONLINE',1500)
  INTO sales VALUES (7,201,3,DATE '2026-05-05','OFFLINE',1300)
  INTO sales VALUES (8,202,1,DATE '2026-08-05','ONLINE',1100)
  INTO sales VALUES (9,301,1,DATE '2026-01-07','ONLINE',2000)
  INTO sales VALUES (10,301,2,DATE '2026-04-07','ONLINE',1800)
  INTO sales VALUES (11,302,1,DATE '2026-01-08','OFFLINE',600)
SELECT 1 FROM dual;

/* 서로 다른 부모·자식 테이블은 별도 문장으로 넣는다. */
INSERT ALL INTO project VALUES (1,'데이터감사') INTO project VALUES (2,'SQL교육') SELECT 1 FROM dual;
INSERT ALL
  INTO employee_project VALUES (101,1,'개발') INTO employee_project VALUES (201,1,'분석')
  INTO employee_project VALUES (101,2,'강사') INTO employee_project VALUES (102,2,'검수')
SELECT 1 FROM dual;

INSERT ALL
  INTO employee_status_history VALUES (101,DATE '2023-01-10',NULL,'ACTIVE')
  INTO employee_status_history VALUES (103,DATE '2023-03-10',DATE '2025-12-31','ACTIVE')
  INTO employee_status_history VALUES (103,DATE '2026-01-01',NULL,'INACTIVE')
SELECT 1 FROM dual;

INSERT ALL
  INTO stg_employee_raw VALUES (901,99,'고아키',7000,'ACTIVE')
  INTO stg_employee_raw VALUES (902,NULL,'미배정',3500,'ACTIVE')
  INTO stg_employee_raw VALUES (903,11,'정상원천',4200,'ACTIVE')
SELECT 1 FROM dual;
COMMIT;

/* ============================================================
   3. SELECT, 함수, WHERE, ORDER BY, NULL
   ============================================================ */
SELECT e.emp_id,
       UPPER(e.email) AS upper_email,
       SUBSTR(e.emp_name,1,1) AS family_name,
       LENGTH(e.emp_name) AS name_length,
       REPLACE(e.email,'example.com','sql.kr') AS changed_email,
       ABS(e.salary-5000) AS distance_5000,
       MOD(e.emp_id,2) AS odd_even,
       ROUND(e.salary/3,2) AS rounded_salary,
       TRUNC(e.salary/3,2) AS truncated_salary,
       EXTRACT(YEAR FROM e.hire_date) AS hire_year,
       ADD_MONTHS(e.hire_date,6) AS after_six_months,
       NVL(e.salary,0) AS salary_nvl,
       COALESCE(e.email,'NO_EMAIL') AS email_value,
       CASE WHEN e.salary >= 6000 THEN 'HIGH'
            WHEN e.salary >= 4000 THEN 'MID' ELSE 'LOW' END AS salary_band,
       DECODE(e.status,'ACTIVE','재직','INACTIVE','비재직','기타') AS status_name
FROM employee e
WHERE e.status = 'ACTIVE' AND e.salary BETWEEN 3500 AND 8000
ORDER BY e.salary DESC, e.emp_id;

SELECT NULL + 10 AS null_arithmetic,
       NVL(NULL,0) + 10 AS nvl_arithmetic,
       COALESCE(NULL,NULL,30) AS first_nonnull,
       NULLIF(10,10) AS nullif_result,
       CASE WHEN NULL = NULL THEN 'TRUE' ELSE 'NOT TRUE' END AS null_compare
FROM dual;

SELECT COUNT(*) AS all_rows, COUNT(amount) AS nonnull_amounts,
       SUM(amount) AS sum_ignoring_null, AVG(amount) AS avg_ignoring_null
FROM sales;

/* ============================================================
   4. JOIN: 등가·외부·교차·비등가·셀프 조인과 증폭 감사
   ============================================================ */
SELECT e.emp_id,e.emp_name,d.dept_name
FROM employee e JOIN department d ON d.dept_id=e.dept_id
ORDER BY e.emp_id;

SELECT d.dept_id,d.dept_name,e.emp_id,e.emp_name
FROM department d
LEFT JOIN employee e ON e.dept_id=d.dept_id AND e.status='ACTIVE'
ORDER BY d.dept_id,e.emp_id;

SELECT d.dept_id,d.dept_name,e.emp_id,e.emp_name
FROM department d FULL OUTER JOIN employee e ON e.dept_id=d.dept_id
ORDER BY d.dept_id,e.emp_id;

SELECT d.dept_id,p.product_id
FROM department d CROSS JOIN product p
WHERE d.dept_id IN (11,12) AND p.product_id IN (1,2)
ORDER BY d.dept_id,p.product_id;

SELECT dept_id,dept_name,employee_count
FROM (SELECT dept_id,dept_name FROM department)
NATURAL JOIN (
    SELECT dept_id,COUNT(*) AS employee_count FROM employee GROUP BY dept_id
)
ORDER BY dept_id;

SELECT e.emp_id,e.emp_name,g.grade_name
FROM employee e JOIN salary_grade g ON e.salary BETWEEN g.min_salary AND g.max_salary
ORDER BY e.emp_id;

SELECT e.emp_id,e.emp_name,m.emp_name AS manager_name
FROM employee e LEFT JOIN employee m ON m.emp_id=e.manager_id
ORDER BY e.emp_id;

SELECT e.emp_id,COUNT(*) AS joined_rows,COUNT(DISTINCT s.sale_id) AS distinct_sales
FROM employee e LEFT JOIN bonus b ON b.emp_id=e.emp_id
                LEFT JOIN sales s ON s.emp_id=e.emp_id
GROUP BY e.emp_id
HAVING COUNT(*) > GREATEST(COUNT(DISTINCT b.bonus_id),COUNT(DISTINCT s.sale_id))
ORDER BY e.emp_id;

/* ============================================================
   5. 서브쿼리: 스칼라·인라인·상관·IN·ANY·ALL·EXISTS
   ============================================================ */
SELECT e.emp_id,e.emp_name,(SELECT d.dept_name FROM department d WHERE d.dept_id=e.dept_id) AS dept_name
FROM employee e ORDER BY e.emp_id;

SELECT * FROM (
    SELECT e.emp_id,e.emp_name,e.salary FROM employee e
    WHERE e.status='ACTIVE' ORDER BY e.salary DESC,e.emp_id
) WHERE ROWNUM <= 3;

SELECT e.emp_id,e.emp_name,e.salary
FROM employee e
WHERE e.salary >= (SELECT AVG(e2.salary) FROM employee e2
                    WHERE e2.dept_id=e.dept_id AND e2.status='ACTIVE')
ORDER BY e.dept_id,e.emp_id;

SELECT emp_id,emp_name FROM employee
WHERE dept_id IN (SELECT dept_id FROM department WHERE parent_dept_id=10)
ORDER BY emp_id;

SELECT emp_id,emp_name,salary FROM employee
WHERE salary > ANY (SELECT salary FROM employee WHERE dept_id=11)
ORDER BY emp_id;

SELECT emp_id,emp_name,salary FROM employee
WHERE salary > ALL (SELECT salary FROM employee WHERE dept_id=11)
ORDER BY emp_id;

/* 공집합: ANY는 FALSE, ALL은 TRUE */
SELECT CASE WHEN 10 > ANY (SELECT salary FROM employee WHERE 1=0) THEN 'TRUE' ELSE 'FALSE' END AS any_empty,
       CASE WHEN 10 > ALL (SELECT salary FROM employee WHERE 1=0) THEN 'TRUE' ELSE 'FALSE' END AS all_empty
FROM dual;

SELECT e.emp_id,e.emp_name FROM employee e
WHERE EXISTS (SELECT 1 FROM bonus b WHERE b.emp_id=e.emp_id)
ORDER BY e.emp_id;

SELECT e.emp_id,e.emp_name FROM employee e
WHERE NOT EXISTS (SELECT 1 FROM bonus b WHERE b.emp_id=e.emp_id)
ORDER BY e.emp_id;

/* ============================================================
   6. 집합 연산자
   ============================================================ */
SELECT emp_id FROM regular_employee
UNION
SELECT emp_id FROM contract_employee
ORDER BY emp_id;

SELECT emp_id,'BONUS' AS source_name FROM bonus
UNION ALL
SELECT emp_id,'SALES' FROM sales
ORDER BY emp_id,source_name;

SELECT emp_id FROM bonus INTERSECT SELECT emp_id FROM sales ORDER BY emp_id;
SELECT emp_id FROM sales MINUS SELECT emp_id FROM bonus ORDER BY emp_id;

/* ============================================================
   7. GROUP BY, HAVING, 그룹 함수
   ============================================================ */
SELECT e.dept_id,COUNT(*) AS employee_count,COUNT(e.salary) AS salary_count,
       SUM(e.salary) AS salary_sum,AVG(e.salary) AS salary_avg,
       MIN(e.salary) AS salary_min,MAX(e.salary) AS salary_max,
       VAR_POP(e.salary) AS population_variance,
       VARIANCE(e.salary) AS sample_variance,
       STDDEV_POP(e.salary) AS population_stddev,
       STDDEV(e.salary) AS sample_stddev
FROM employee e
WHERE e.status='ACTIVE'
GROUP BY e.dept_id
HAVING COUNT(*) >= 2 AND AVG(e.salary) >= 4000
ORDER BY e.dept_id;

SELECT d.dept_type,d.dept_name,SUM(NVL(s.amount,0)) AS sales_amount,
       GROUPING(d.dept_type) AS g_type,GROUPING(d.dept_name) AS g_name,
       GROUPING_ID(d.dept_type,d.dept_name) AS grouping_id
FROM department d LEFT JOIN employee e ON e.dept_id=d.dept_id
                  LEFT JOIN sales s ON s.emp_id=e.emp_id
GROUP BY ROLLUP(d.dept_type,d.dept_name)
ORDER BY d.dept_type,d.dept_name;

SELECT d.dept_type,s.channel,SUM(s.amount) AS sales_amount
FROM department d JOIN employee e ON e.dept_id=d.dept_id JOIN sales s ON s.emp_id=e.emp_id
GROUP BY CUBE(d.dept_type,s.channel)
ORDER BY d.dept_type,s.channel;

SELECT d.dept_type,d.dept_name,SUM(s.amount) AS sales_amount
FROM department d LEFT JOIN employee e ON e.dept_id=d.dept_id LEFT JOIN sales s ON s.emp_id=e.emp_id
GROUP BY GROUPING SETS ((d.dept_type),(d.dept_name),())
ORDER BY d.dept_type,d.dept_name;

/* ============================================================
   8. 윈도우 함수와 Top-N
   ============================================================ */
SELECT e.dept_id,e.emp_id,e.emp_name,e.salary,
       ROW_NUMBER() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC,e.emp_id) AS row_no,
       RANK() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS rank_no,
       DENSE_RANK() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS dense_rank_no,
       AVG(e.salary) OVER (PARTITION BY e.dept_id) AS dept_avg,
       SUM(e.salary) OVER (PARTITION BY e.dept_id ORDER BY e.hire_date,e.emp_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_salary,
       LAG(e.salary) OVER (PARTITION BY e.dept_id ORDER BY e.hire_date,e.emp_id) AS previous_salary,
       LEAD(e.salary) OVER (PARTITION BY e.dept_id ORDER BY e.hire_date,e.emp_id) AS next_salary,
       FIRST_VALUE(e.emp_name) OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC,e.emp_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS highest_paid_name,
       LAST_VALUE(e.emp_name) OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC,e.emp_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lowest_paid_name,
       NTILE(4) OVER (ORDER BY e.salary DESC,e.emp_id) AS salary_quartile,
       CUME_DIST() OVER (ORDER BY e.salary) AS cume_dist_value,
       PERCENT_RANK() OVER (ORDER BY e.salary) AS percent_rank_value,
       RATIO_TO_REPORT(e.salary) OVER (PARTITION BY e.dept_id) AS dept_salary_ratio
FROM employee e WHERE e.status='ACTIVE'
ORDER BY e.dept_id,row_no;

SELECT * FROM (
    SELECT e.*,ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC,emp_id) AS rn
    FROM employee e WHERE status='ACTIVE'
) WHERE rn <= 2 ORDER BY dept_id,rn;

SELECT emp_id,emp_name,salary FROM employee
WHERE status='ACTIVE' ORDER BY salary DESC,emp_id FETCH FIRST 3 ROWS ONLY;

/* ============================================================
   9. 계층형 질의와 셀프 조인
   ============================================================ */
SELECT LEVEL AS hierarchy_level,dept_id,parent_dept_id,
       LPAD(' ',(LEVEL-1)*2)||dept_name AS indented_name,
       SYS_CONNECT_BY_PATH(dept_name,' > ') AS dept_path,
       CONNECT_BY_ROOT dept_name AS root_name,
       CONNECT_BY_ISLEAF AS is_leaf
FROM department
START WITH parent_dept_id IS NULL
CONNECT BY NOCYCLE PRIOR dept_id=parent_dept_id
ORDER SIBLINGS BY dept_id;

SELECT c.dept_id,c.dept_name,p.dept_name AS parent_name
FROM department c LEFT JOIN department p ON p.dept_id=c.parent_dept_id
ORDER BY c.dept_id;

/* ============================================================
   10. PIVOT, 조건부 집계, UNPIVOT
   ============================================================ */
SELECT * FROM (
    SELECT e.dept_id,TO_CHAR(s.sale_date,'Q') AS quarter_no,s.amount
    FROM employee e JOIN sales s ON s.emp_id=e.emp_id
)
PIVOT (SUM(amount) FOR quarter_no IN ('1' AS q1,'2' AS q2,'3' AS q3,'4' AS q4))
ORDER BY dept_id;

SELECT e.dept_id,
       SUM(CASE WHEN TO_CHAR(s.sale_date,'Q')='1' THEN s.amount END) AS q1,
       SUM(CASE WHEN TO_CHAR(s.sale_date,'Q')='2' THEN s.amount END) AS q2,
       SUM(CASE WHEN TO_CHAR(s.sale_date,'Q')='3' THEN s.amount END) AS q3,
       SUM(CASE WHEN TO_CHAR(s.sale_date,'Q')='4' THEN s.amount END) AS q4
FROM employee e JOIN sales s ON s.emp_id=e.emp_id
GROUP BY e.dept_id ORDER BY e.dept_id;

WITH quarterly_sales AS (
    SELECT e.dept_id,
           SUM(CASE WHEN TO_CHAR(s.sale_date,'Q')='1' THEN s.amount END) AS q1,
           SUM(CASE WHEN TO_CHAR(s.sale_date,'Q')='2' THEN s.amount END) AS q2,
           SUM(CASE WHEN TO_CHAR(s.sale_date,'Q')='3' THEN s.amount END) AS q3,
           SUM(CASE WHEN TO_CHAR(s.sale_date,'Q')='4' THEN s.amount END) AS q4
    FROM employee e JOIN sales s ON s.emp_id=e.emp_id GROUP BY e.dept_id
)
SELECT dept_id,quarter_name,amount
FROM quarterly_sales
UNPIVOT INCLUDE NULLS (amount FOR quarter_name IN (q1 AS 'Q1',q2 AS 'Q2',q3 AS 'Q3',q4 AS 'Q4'))
ORDER BY dept_id,quarter_name;

/* ============================================================
   11. 최종 정답: 사전 집계 -> 상관 필터 -> 순위 -> LEFT JOIN
   ============================================================ */
WITH bonus_sum AS (
    SELECT emp_id,NVL(SUM(amount),0) AS total_bonus FROM bonus GROUP BY emp_id
), sales_sum AS (
    SELECT emp_id,NVL(SUM(amount),0) AS total_sales FROM sales GROUP BY emp_id
), valid_active AS (
    SELECT e.* FROM employee e JOIN department d ON d.dept_id=e.dept_id
    WHERE e.status='ACTIVE'
), eligible AS (
    SELECT e.emp_id,e.dept_id,e.emp_name,e.salary,
           NVL(b.total_bonus,0) AS total_bonus,NVL(s.total_sales,0) AS total_sales
    FROM valid_active e LEFT JOIN bonus_sum b ON b.emp_id=e.emp_id
                        LEFT JOIN sales_sum s ON s.emp_id=e.emp_id
    WHERE e.salary >= (SELECT AVG(e2.salary)*0.8 FROM valid_active e2 WHERE e2.dept_id=e.dept_id)
), ranked AS (
    SELECT x.*,ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC,emp_id) AS rn
    FROM eligible x
), dept_tree AS (
    SELECT dept_id,parent_dept_id,dept_name,SYS_CONNECT_BY_PATH(dept_name,' > ') AS dept_path
    FROM department START WITH parent_dept_id IS NULL
    CONNECT BY NOCYCLE PRIOR dept_id=parent_dept_id
)
SELECT t.dept_path,t.dept_id,t.dept_name,r.emp_id,r.emp_name,r.salary,
       r.total_bonus,r.total_sales,r.rn
FROM dept_tree t LEFT JOIN ranked r ON r.dept_id=t.dept_id AND r.rn<=2
ORDER BY t.dept_id,r.rn;

/* 역질의: 고아키, NULL 키, 조인 증폭 */
SELECT s.* FROM stg_employee_raw s LEFT JOIN department d ON d.dept_id=s.dept_id
WHERE s.dept_id IS NOT NULL AND d.dept_id IS NULL;

SELECT * FROM stg_employee_raw WHERE dept_id IS NULL;

SELECT e.emp_id,COUNT(*) AS rows_after_join
FROM employee e LEFT JOIN bonus b ON b.emp_id=e.emp_id LEFT JOIN sales s ON s.emp_id=e.emp_id
GROUP BY e.emp_id HAVING COUNT(*)>1 ORDER BY e.emp_id;

/* ============================================================
   12. TCL/DML: SAVEPOINT 안에서 INSERT·UPDATE·DELETE·MERGE 후 복구
   ============================================================ */
SAVEPOINT before_dml_demo;

INSERT INTO stg_employee_raw VALUES (904,12,'삽입실험',4100,'ACTIVE');
UPDATE stg_employee_raw SET salary=salary+100 WHERE emp_id=903;
DELETE FROM stg_employee_raw WHERE emp_id=902;

MERGE INTO stg_employee_raw t
USING (SELECT 903 AS emp_id,11 AS dept_id,'정상원천수정' AS emp_name,4300 AS salary,'ACTIVE' AS status FROM dual) s
ON (t.emp_id=s.emp_id)
WHEN MATCHED THEN UPDATE SET t.emp_name=s.emp_name,t.salary=s.salary
WHEN NOT MATCHED THEN INSERT (emp_id,dept_id,emp_name,salary,status)
VALUES (s.emp_id,s.dept_id,s.emp_name,s.salary,s.status);

ROLLBACK TO before_dml_demo;
COMMIT;

/* ============================================================
   13. VIEW와 안전한 DDL 데모
   ============================================================ */
CREATE OR REPLACE VIEW v_active_employee_summary AS
SELECT e.emp_id,e.emp_name,e.dept_id,d.dept_name,e.salary
FROM employee e JOIN department d ON d.dept_id=e.dept_id
WHERE e.status='ACTIVE'
WITH CHECK OPTION;

SELECT * FROM v_active_employee_summary ORDER BY dept_id,emp_id;

CREATE TABLE ddl_demo AS SELECT emp_id,emp_name FROM employee WHERE 1=0;
ALTER TABLE ddl_demo ADD note VARCHAR2(100) DEFAULT '연습';
ALTER TABLE ddl_demo RENAME COLUMN note TO memo;
RENAME ddl_demo TO ddl_demo_renamed;
TRUNCATE TABLE ddl_demo_renamed;
DROP TABLE ddl_demo_renamed PURGE;

/* DCL은 권한이 있는 계정에서만 실행한다.
GRANT SELECT ON v_active_employee_summary TO 학습계정;
REVOKE SELECT ON v_active_employee_summary FROM 학습계정;
*/

/* 정상 종료 확인 */
SELECT 'ORACLE SCRIPT COMPLETED' AS execution_status FROM dual;
