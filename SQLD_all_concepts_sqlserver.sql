/*
  SQLD 전개념 종합 실행 스크립트 - SQL Server 2019+
  목적: SSMS / Azure Data Studio에서 위에서 아래로 실행
  주의: GO는 클라이언트 배치 구분자다.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

/* 0. 재실행 정리: 자식 -> 부모 */
IF OBJECT_ID('dbo.v_active_employee_summary','V') IS NOT NULL DROP VIEW dbo.v_active_employee_summary;
IF OBJECT_ID('dbo.employee_project','U') IS NOT NULL DROP TABLE dbo.employee_project;
IF OBJECT_ID('dbo.employee_status_history','U') IS NOT NULL DROP TABLE dbo.employee_status_history;
IF OBJECT_ID('dbo.sales','U') IS NOT NULL DROP TABLE dbo.sales;
IF OBJECT_ID('dbo.bonus','U') IS NOT NULL DROP TABLE dbo.bonus;
IF OBJECT_ID('dbo.regular_employee','U') IS NOT NULL DROP TABLE dbo.regular_employee;
IF OBJECT_ID('dbo.contract_employee','U') IS NOT NULL DROP TABLE dbo.contract_employee;
IF OBJECT_ID('dbo.project','U') IS NOT NULL DROP TABLE dbo.project;
IF OBJECT_ID('dbo.product','U') IS NOT NULL DROP TABLE dbo.product;
IF OBJECT_ID('dbo.salary_grade','U') IS NOT NULL DROP TABLE dbo.salary_grade;
IF OBJECT_ID('dbo.employee','U') IS NOT NULL DROP TABLE dbo.employee;
IF OBJECT_ID('dbo.department','U') IS NOT NULL DROP TABLE dbo.department;
IF OBJECT_ID('dbo.stg_employee_raw','U') IS NOT NULL DROP TABLE dbo.stg_employee_raw;
GO

/* 1. DDL */
CREATE TABLE dbo.department (
    dept_id int CONSTRAINT pk_department PRIMARY KEY,
    parent_dept_id int NULL,
    dept_name nvarchar(40) CONSTRAINT nn_department_name NOT NULL,
    dept_type varchar(10) NOT NULL CONSTRAINT df_department_type DEFAULT 'TEAM',
    CONSTRAINT uq_department_name UNIQUE (dept_name),
    CONSTRAINT ck_department_type CHECK (dept_type IN ('ROOT','DIVISION','TEAM')),
    CONSTRAINT fk_department_parent FOREIGN KEY (parent_dept_id) REFERENCES dbo.department(dept_id)
);

CREATE TABLE dbo.employee (
    emp_id int CONSTRAINT pk_employee PRIMARY KEY,
    dept_id int NULL,
    manager_id int NULL,
    emp_name nvarchar(30) NOT NULL,
    email varchar(80) NULL,
    salary decimal(10,2) NULL,
    status varchar(10) NOT NULL CONSTRAINT df_employee_status DEFAULT 'ACTIVE',
    hire_date date NOT NULL CONSTRAINT df_employee_hire_date DEFAULT CAST(GETDATE() AS date),
    CONSTRAINT uq_employee_email UNIQUE (email),
    CONSTRAINT ck_employee_salary CHECK (salary >= 0),
    CONSTRAINT ck_employee_status CHECK (status IN ('ACTIVE','INACTIVE','LEAVE')),
    CONSTRAINT fk_employee_department FOREIGN KEY (dept_id) REFERENCES dbo.department(dept_id),
    CONSTRAINT fk_employee_manager FOREIGN KEY (manager_id) REFERENCES dbo.employee(emp_id)
);

CREATE TABLE dbo.regular_employee (
    emp_id int CONSTRAINT pk_regular_employee PRIMARY KEY,
    pension_grade varchar(10) NOT NULL,
    CONSTRAINT fk_regular_employee FOREIGN KEY (emp_id) REFERENCES dbo.employee(emp_id)
);

CREATE TABLE dbo.contract_employee (
    emp_id int CONSTRAINT pk_contract_employee PRIMARY KEY,
    contract_end date NOT NULL,
    CONSTRAINT fk_contract_employee FOREIGN KEY (emp_id) REFERENCES dbo.employee(emp_id)
);

CREATE TABLE dbo.bonus (
    bonus_id int CONSTRAINT pk_bonus PRIMARY KEY,
    emp_id int NOT NULL,
    bonus_date date NOT NULL,
    amount decimal(10,2) NULL,
    CONSTRAINT fk_bonus_employee FOREIGN KEY (emp_id) REFERENCES dbo.employee(emp_id)
);

CREATE TABLE dbo.product (
    product_id int CONSTRAINT pk_product PRIMARY KEY,
    category nvarchar(20) NOT NULL,
    product_name nvarchar(40) NOT NULL,
    list_price decimal(10,2) NULL CHECK (list_price >= 0),
    CONSTRAINT uq_product_name UNIQUE (product_name)
);

CREATE TABLE dbo.sales (
    sale_id int CONSTRAINT pk_sales PRIMARY KEY,
    emp_id int NOT NULL,
    product_id int NOT NULL,
    sale_date date NOT NULL,
    channel varchar(10) NOT NULL,
    amount decimal(12,2) NULL,
    CONSTRAINT ck_sales_channel CHECK (channel IN ('ONLINE','OFFLINE')),
    CONSTRAINT fk_sales_employee FOREIGN KEY (emp_id) REFERENCES dbo.employee(emp_id),
    CONSTRAINT fk_sales_product FOREIGN KEY (product_id) REFERENCES dbo.product(product_id)
);

CREATE TABLE dbo.salary_grade (
    grade_name varchar(10) CONSTRAINT pk_salary_grade PRIMARY KEY,
    min_salary decimal(10,2) NOT NULL,
    max_salary decimal(10,2) NOT NULL,
    CONSTRAINT ck_salary_grade_range CHECK (max_salary >= min_salary)
);

CREATE TABLE dbo.project (
    project_id int CONSTRAINT pk_project PRIMARY KEY,
    project_name nvarchar(50) NOT NULL
);

CREATE TABLE dbo.employee_project (
    emp_id int NOT NULL, project_id int NOT NULL, role_name nvarchar(30) NULL,
    CONSTRAINT pk_employee_project PRIMARY KEY (emp_id,project_id),
    CONSTRAINT fk_ep_employee FOREIGN KEY (emp_id) REFERENCES dbo.employee(emp_id),
    CONSTRAINT fk_ep_project FOREIGN KEY (project_id) REFERENCES dbo.project(project_id)
);

CREATE TABLE dbo.employee_status_history (
    emp_id int NOT NULL, start_date date NOT NULL, end_date date NULL, status varchar(10) NOT NULL,
    CONSTRAINT pk_employee_status_history PRIMARY KEY (emp_id,start_date),
    CONSTRAINT ck_history_period CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT fk_history_employee FOREIGN KEY (emp_id) REFERENCES dbo.employee(emp_id)
);

CREATE TABLE dbo.stg_employee_raw (
    emp_id int NULL, dept_id int NULL, emp_name nvarchar(30) NULL,
    salary decimal(10,2) NULL, status varchar(10) NULL
);
GO

/* 2. INSERT: 부모와 관리자를 먼저 삽입 */
INSERT dbo.department VALUES (1,NULL,N'전사','ROOT');
INSERT dbo.department VALUES
(10,1,N'기술본부','DIVISION'),(20,1,N'영업본부','DIVISION'),
(11,10,N'개발팀','TEAM'),(12,10,N'분석팀','TEAM'),
(21,20,N'온라인팀','TEAM'),(22,20,N'오프라인팀','TEAM'),
(30,1,N'품질팀','TEAM'),(40,1,N'무인부서','TEAM');

INSERT dbo.employee VALUES (100,1,NULL,N'대표','ceo@example.com',10000,'ACTIVE','2020-01-01');
INSERT dbo.employee VALUES
(110,10,100,N'기술본부장','cto@example.com',8000,'ACTIVE','2021-01-01'),
(120,20,100,N'영업본부장','cso@example.com',7800,'ACTIVE','2021-02-01');
INSERT dbo.employee VALUES
(101,11,110,N'김개발','dev1@example.com',5000,'ACTIVE','2023-01-10'),
(102,11,110,N'이개발','dev2@example.com',4000,'ACTIVE','2023-02-10'),
(103,11,110,N'박휴직','dev3@example.com',3000,'INACTIVE','2023-03-10'),
(201,12,110,N'최분석','ana1@example.com',6000,'ACTIVE','2022-01-10'),
(202,12,110,N'정분석','ana2@example.com',6000,'ACTIVE','2022-02-10'),
(301,21,120,N'온영업','on1@example.com',4500,'ACTIVE','2024-01-10'),
(302,21,120,N'온신입','on2@example.com',3500,'ACTIVE','2025-01-10'),
(401,22,120,N'한운영','off1@example.com',4500,'INACTIVE','2024-02-10');

INSERT dbo.regular_employee VALUES
(100,'P1'),(110,'P2'),(120,'P2'),(101,'P3'),(102,'P3'),(201,'P3'),(202,'P3'),(301,'P3');
INSERT dbo.contract_employee VALUES (302,'2026-12-31');
INSERT dbo.bonus VALUES
(1,101,'2026-01-31',100),(2,101,'2026-02-28',200),(3,102,'2026-01-31',50),
(4,202,'2026-01-31',NULL),(5,301,'2026-01-31',150);
INSERT dbo.product VALUES (1,N'DB',N'SQLD교재',30000),(2,N'AI',N'AI교재',40000),(3,N'QA',N'데이터품질교재',35000);
INSERT dbo.salary_grade VALUES ('LOW',0,3999.99),('MID',4000,5999.99),('HIGH',6000,99999999);
INSERT dbo.sales VALUES
(1,101,1,'2026-01-05','ONLINE',1000),(2,101,2,'2026-04-05','ONLINE',1200),
(3,101,3,'2026-07-05','OFFLINE',900),(4,102,1,'2026-01-06','ONLINE',700),
(5,102,3,'2026-10-06','OFFLINE',NULL),(6,201,2,'2026-02-05','ONLINE',1500),
(7,201,3,'2026-05-05','OFFLINE',1300),(8,202,1,'2026-08-05','ONLINE',1100),
(9,301,1,'2026-01-07','ONLINE',2000),(10,301,2,'2026-04-07','ONLINE',1800),
(11,302,1,'2026-01-08','OFFLINE',600);
INSERT dbo.project VALUES (1,N'데이터감사'),(2,N'SQL교육');
INSERT dbo.employee_project VALUES (101,1,N'개발'),(201,1,N'분석'),(101,2,N'강사'),(102,2,N'검수');
INSERT dbo.employee_status_history VALUES
(101,'2023-01-10',NULL,'ACTIVE'),(103,'2023-03-10','2025-12-31','ACTIVE'),
(103,'2026-01-01',NULL,'INACTIVE');
INSERT dbo.stg_employee_raw VALUES
(901,99,N'고아키',7000,'ACTIVE'),(902,NULL,N'미배정',3500,'ACTIVE'),(903,11,N'정상원천',4200,'ACTIVE');
GO

/* 3. SELECT, 함수, WHERE, ORDER BY, NULL */
SELECT e.emp_id,UPPER(e.email) AS upper_email,LOWER(e.email) AS lower_email,
       LEFT(e.emp_name,1) AS family_name,LEN(e.emp_name) AS name_length,
       REPLACE(e.email,'example.com','sql.kr') AS changed_email,
       ABS(e.salary-5000) AS distance_5000,SIGN(e.salary-5000) AS salary_sign,
       e.emp_id % 2 AS odd_even,CEILING(e.salary/3) AS ceil_value,FLOOR(e.salary/3) AS floor_value,
       ROUND(e.salary/3,2) AS rounded_value,POWER(e.salary/1000,2) AS squared_scale,
       GETDATE() AS current_datetime,YEAR(e.hire_date) AS hire_year,
       DATEADD(month,6,e.hire_date) AS after_six_months,EOMONTH(e.hire_date) AS month_end,
       ISNULL(e.salary,0) AS salary_isnull,COALESCE(e.email,'NO_EMAIL') AS email_value,
       CASE WHEN e.salary>=6000 THEN 'HIGH' WHEN e.salary>=4000 THEN 'MID' ELSE 'LOW' END AS salary_band
FROM dbo.employee e
WHERE e.status='ACTIVE' AND e.salary BETWEEN 3500 AND 8000
ORDER BY e.salary DESC,e.emp_id;

SELECT NULL + 10 AS null_arithmetic,ISNULL(NULL,0)+10 AS isnull_arithmetic,
       COALESCE(NULL,NULL,30) AS first_nonnull,NULLIF(10,10) AS nullif_result;

SELECT COUNT(*) AS all_rows,COUNT(amount) AS nonnull_amounts,SUM(amount) AS sum_amount,AVG(amount) AS avg_amount
FROM dbo.sales;

/* 4. JOIN과 입도 감사 */
SELECT e.emp_id,e.emp_name,d.dept_name
FROM dbo.employee e JOIN dbo.department d ON d.dept_id=e.dept_id ORDER BY e.emp_id;

SELECT d.dept_id,d.dept_name,e.emp_id,e.emp_name
FROM dbo.department d LEFT JOIN dbo.employee e ON e.dept_id=d.dept_id AND e.status='ACTIVE'
ORDER BY d.dept_id,e.emp_id;

SELECT d.dept_id,d.dept_name,e.emp_id,e.emp_name
FROM dbo.department d FULL OUTER JOIN dbo.employee e ON e.dept_id=d.dept_id
ORDER BY d.dept_id,e.emp_id;

SELECT d.dept_id,p.product_id
FROM dbo.department d CROSS JOIN dbo.product p
WHERE d.dept_id IN (11,12) AND p.product_id IN (1,2)
ORDER BY d.dept_id,p.product_id;

/* SQL Server에는 NATURAL JOIN이 없으므로 공통 열을 ON으로 명시한다. */

SELECT e.emp_id,e.emp_name,g.grade_name
FROM dbo.employee e JOIN dbo.salary_grade g ON e.salary BETWEEN g.min_salary AND g.max_salary
ORDER BY e.emp_id;

SELECT e.emp_id,e.emp_name,m.emp_name AS manager_name
FROM dbo.employee e LEFT JOIN dbo.employee m ON m.emp_id=e.manager_id ORDER BY e.emp_id;

SELECT e.emp_id,COUNT(*) AS joined_rows,COUNT(DISTINCT s.sale_id) AS distinct_sales
FROM dbo.employee e LEFT JOIN dbo.bonus b ON b.emp_id=e.emp_id LEFT JOIN dbo.sales s ON s.emp_id=e.emp_id
GROUP BY e.emp_id
HAVING COUNT(*) > CASE WHEN COUNT(DISTINCT b.bonus_id)>COUNT(DISTINCT s.sale_id)
                       THEN COUNT(DISTINCT b.bonus_id) ELSE COUNT(DISTINCT s.sale_id) END
ORDER BY e.emp_id;

/* 5. 서브쿼리와 집합 연산 */
SELECT e.emp_id,e.emp_name,(SELECT d.dept_name FROM dbo.department d WHERE d.dept_id=e.dept_id) AS dept_name
FROM dbo.employee e ORDER BY e.emp_id;

SELECT e.emp_id,e.emp_name,e.salary
FROM dbo.employee e
WHERE e.salary >= (SELECT AVG(e2.salary*1.0) FROM dbo.employee e2
                    WHERE e2.dept_id=e.dept_id AND e2.status='ACTIVE')
ORDER BY e.dept_id,e.emp_id;

SELECT emp_id,emp_name FROM dbo.employee
WHERE dept_id IN (SELECT dept_id FROM dbo.department WHERE parent_dept_id=10) ORDER BY emp_id;

SELECT emp_id,emp_name,salary FROM dbo.employee
WHERE salary > ANY (SELECT salary FROM dbo.employee WHERE dept_id=11) ORDER BY emp_id;
SELECT emp_id,emp_name,salary FROM dbo.employee
WHERE salary > ALL (SELECT salary FROM dbo.employee WHERE dept_id=11) ORDER BY emp_id;

SELECT CASE WHEN 10 > ANY (SELECT salary FROM dbo.employee WHERE 1=0) THEN 'TRUE' ELSE 'FALSE' END AS any_empty,
       CASE WHEN 10 > ALL (SELECT salary FROM dbo.employee WHERE 1=0) THEN 'TRUE' ELSE 'FALSE' END AS all_empty;

SELECT e.emp_id,e.emp_name FROM dbo.employee e
WHERE EXISTS (SELECT 1 FROM dbo.bonus b WHERE b.emp_id=e.emp_id) ORDER BY e.emp_id;
SELECT e.emp_id,e.emp_name FROM dbo.employee e
WHERE NOT EXISTS (SELECT 1 FROM dbo.bonus b WHERE b.emp_id=e.emp_id) ORDER BY e.emp_id;

SELECT emp_id FROM dbo.regular_employee UNION SELECT emp_id FROM dbo.contract_employee ORDER BY emp_id;
SELECT emp_id,'BONUS' AS source_name FROM dbo.bonus
UNION ALL SELECT emp_id,'SALES' FROM dbo.sales ORDER BY emp_id,source_name;
SELECT emp_id FROM dbo.bonus INTERSECT SELECT emp_id FROM dbo.sales ORDER BY emp_id;
SELECT emp_id FROM dbo.sales EXCEPT SELECT emp_id FROM dbo.bonus ORDER BY emp_id;

/* 6. GROUP BY, HAVING, ROLLUP, CUBE, GROUPING SETS */
SELECT e.dept_id,COUNT(*) AS employee_count,COUNT(e.salary) AS salary_count,
       SUM(e.salary) AS salary_sum,AVG(e.salary) AS salary_avg,
       MIN(e.salary) AS salary_min,MAX(e.salary) AS salary_max,
       VARP(e.salary) AS population_variance,VAR(e.salary) AS sample_variance,
       STDEVP(e.salary) AS population_stddev,STDEV(e.salary) AS sample_stddev
FROM dbo.employee e WHERE e.status='ACTIVE'
GROUP BY e.dept_id HAVING COUNT(*)>=2 AND AVG(e.salary)>=4000 ORDER BY e.dept_id;

SELECT d.dept_type,d.dept_name,SUM(ISNULL(s.amount,0)) AS sales_amount,
       GROUPING(d.dept_type) AS g_type,GROUPING(d.dept_name) AS g_name,
       GROUPING_ID(d.dept_type,d.dept_name) AS grouping_id
FROM dbo.department d LEFT JOIN dbo.employee e ON e.dept_id=d.dept_id
LEFT JOIN dbo.sales s ON s.emp_id=e.emp_id
GROUP BY ROLLUP(d.dept_type,d.dept_name) ORDER BY d.dept_type,d.dept_name;

SELECT d.dept_type,s.channel,SUM(s.amount) AS sales_amount
FROM dbo.department d JOIN dbo.employee e ON e.dept_id=d.dept_id JOIN dbo.sales s ON s.emp_id=e.emp_id
GROUP BY CUBE(d.dept_type,s.channel) ORDER BY d.dept_type,s.channel;

SELECT d.dept_type,d.dept_name,SUM(s.amount) AS sales_amount
FROM dbo.department d LEFT JOIN dbo.employee e ON e.dept_id=d.dept_id LEFT JOIN dbo.sales s ON s.emp_id=e.emp_id
GROUP BY GROUPING SETS ((d.dept_type),(d.dept_name),()) ORDER BY d.dept_type,d.dept_name;

/* 7. 윈도우 함수와 Top-N */
SELECT e.dept_id,e.emp_id,e.emp_name,e.salary,
       ROW_NUMBER() OVER(PARTITION BY e.dept_id ORDER BY e.salary DESC,e.emp_id) AS row_no,
       RANK() OVER(PARTITION BY e.dept_id ORDER BY e.salary DESC) AS rank_no,
       DENSE_RANK() OVER(PARTITION BY e.dept_id ORDER BY e.salary DESC) AS dense_rank_no,
       AVG(e.salary) OVER(PARTITION BY e.dept_id) AS dept_avg,
       SUM(e.salary) OVER(PARTITION BY e.dept_id ORDER BY e.hire_date,e.emp_id
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_salary,
       LAG(e.salary) OVER(PARTITION BY e.dept_id ORDER BY e.hire_date,e.emp_id) AS previous_salary,
       LEAD(e.salary) OVER(PARTITION BY e.dept_id ORDER BY e.hire_date,e.emp_id) AS next_salary,
       NTILE(4) OVER(ORDER BY e.salary DESC,e.emp_id) AS salary_quartile,
       CUME_DIST() OVER(ORDER BY e.salary) AS cume_dist_value,
       PERCENT_RANK() OVER(ORDER BY e.salary) AS percent_rank_value,
       e.salary*1.0/NULLIF(SUM(e.salary) OVER(PARTITION BY e.dept_id),0) AS dept_salary_ratio
FROM dbo.employee e WHERE e.status='ACTIVE' ORDER BY e.dept_id,row_no;

WITH ranked AS (
    SELECT e.*,ROW_NUMBER() OVER(PARTITION BY dept_id ORDER BY salary DESC,emp_id) AS rn
    FROM dbo.employee e WHERE status='ACTIVE'
)
SELECT * FROM ranked WHERE rn<=2 ORDER BY dept_id,rn;

SELECT TOP (3) emp_id,emp_name,salary FROM dbo.employee
WHERE status='ACTIVE' ORDER BY salary DESC,emp_id;

SELECT emp_id,emp_name,salary FROM dbo.employee WHERE status='ACTIVE'
ORDER BY salary DESC,emp_id OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

/* 8. 재귀 CTE 계층과 셀프 조인 */
;WITH org_tree AS (
    SELECT d.dept_id,d.parent_dept_id,d.dept_name,1 AS hierarchy_level,
           CAST(d.dept_name AS nvarchar(4000)) AS dept_path
    FROM dbo.department d WHERE d.parent_dept_id IS NULL
    UNION ALL
    SELECT c.dept_id,c.parent_dept_id,c.dept_name,p.hierarchy_level+1,
           CAST(p.dept_path+N' > '+c.dept_name AS nvarchar(4000))
    FROM dbo.department c JOIN org_tree p ON p.dept_id=c.parent_dept_id
)
SELECT * FROM org_tree ORDER BY dept_id OPTION (MAXRECURSION 100);

SELECT c.dept_id,c.dept_name,p.dept_name AS parent_name
FROM dbo.department c LEFT JOIN dbo.department p ON p.dept_id=c.parent_dept_id ORDER BY c.dept_id;

/* 9. PIVOT과 NULL을 보존하는 UNPIVOT 대안 */
SELECT dept_id,[1] AS q1,[2] AS q2,[3] AS q3,[4] AS q4
FROM (
    SELECT e.dept_id,DATEPART(quarter,s.sale_date) AS quarter_no,s.amount
    FROM dbo.employee e JOIN dbo.sales s ON s.emp_id=e.emp_id
) src
PIVOT (SUM(amount) FOR quarter_no IN ([1],[2],[3],[4])) p
ORDER BY dept_id;

WITH quarterly_sales AS (
    SELECT e.dept_id,
           SUM(CASE WHEN DATEPART(quarter,s.sale_date)=1 THEN s.amount END) AS q1,
           SUM(CASE WHEN DATEPART(quarter,s.sale_date)=2 THEN s.amount END) AS q2,
           SUM(CASE WHEN DATEPART(quarter,s.sale_date)=3 THEN s.amount END) AS q3,
           SUM(CASE WHEN DATEPART(quarter,s.sale_date)=4 THEN s.amount END) AS q4
    FROM dbo.employee e JOIN dbo.sales s ON s.emp_id=e.emp_id GROUP BY e.dept_id
)
SELECT q.dept_id,v.quarter_name,v.amount
FROM quarterly_sales q
CROSS APPLY (VALUES ('Q1',q.q1),('Q2',q.q2),('Q3',q.q3),('Q4',q.q4)) v(quarter_name,amount)
ORDER BY q.dept_id,v.quarter_name;

/* 10. 최종 정답 */
;WITH bonus_sum AS (
    SELECT emp_id,ISNULL(SUM(amount),0) AS total_bonus FROM dbo.bonus GROUP BY emp_id
), sales_sum AS (
    SELECT emp_id,ISNULL(SUM(amount),0) AS total_sales FROM dbo.sales GROUP BY emp_id
), valid_active AS (
    SELECT e.* FROM dbo.employee e JOIN dbo.department d ON d.dept_id=e.dept_id WHERE e.status='ACTIVE'
), eligible AS (
    SELECT e.emp_id,e.dept_id,e.emp_name,e.salary,
           ISNULL(b.total_bonus,0) AS total_bonus,ISNULL(s.total_sales,0) AS total_sales
    FROM valid_active e LEFT JOIN bonus_sum b ON b.emp_id=e.emp_id LEFT JOIN sales_sum s ON s.emp_id=e.emp_id
    WHERE e.salary >= (SELECT AVG(e2.salary*1.0)*0.8 FROM valid_active e2 WHERE e2.dept_id=e.dept_id)
), ranked AS (
    SELECT x.*,ROW_NUMBER() OVER(PARTITION BY dept_id ORDER BY salary DESC,emp_id) AS rn FROM eligible x
), dept_tree AS (
    SELECT d.dept_id,d.parent_dept_id,d.dept_name,CAST(d.dept_name AS nvarchar(4000)) AS dept_path
    FROM dbo.department d WHERE d.parent_dept_id IS NULL
    UNION ALL
    SELECT c.dept_id,c.parent_dept_id,c.dept_name,CAST(p.dept_path+N' > '+c.dept_name AS nvarchar(4000))
    FROM dbo.department c JOIN dept_tree p ON p.dept_id=c.parent_dept_id
)
SELECT t.dept_path,t.dept_id,t.dept_name,r.emp_id,r.emp_name,r.salary,r.total_bonus,r.total_sales,r.rn
FROM dept_tree t LEFT JOIN ranked r ON r.dept_id=t.dept_id AND r.rn<=2
ORDER BY t.dept_id,r.rn OPTION (MAXRECURSION 100);

/* 11. 역질의 */
SELECT s.* FROM dbo.stg_employee_raw s LEFT JOIN dbo.department d ON d.dept_id=s.dept_id
WHERE s.dept_id IS NOT NULL AND d.dept_id IS NULL;
SELECT * FROM dbo.stg_employee_raw WHERE dept_id IS NULL;

/* 12. DML·TCL: 전체 데모를 복구 */
BEGIN TRANSACTION;
SAVE TRANSACTION before_dml_demo;
INSERT dbo.stg_employee_raw VALUES (904,12,N'삽입실험',4100,'ACTIVE');
UPDATE dbo.stg_employee_raw SET salary=salary+100 WHERE emp_id=903;
DELETE FROM dbo.stg_employee_raw WHERE emp_id=902;

MERGE dbo.stg_employee_raw AS t
USING (VALUES (903,11,N'정상원천수정',4300,'ACTIVE')) AS s(emp_id,dept_id,emp_name,salary,status)
ON t.emp_id=s.emp_id
WHEN MATCHED THEN UPDATE SET emp_name=s.emp_name,salary=s.salary
WHEN NOT MATCHED THEN INSERT (emp_id,dept_id,emp_name,salary,status)
VALUES (s.emp_id,s.dept_id,s.emp_name,s.salary,s.status);

ROLLBACK TRANSACTION before_dml_demo;
COMMIT TRANSACTION;
GO

/* 13. VIEW: CREATE VIEW는 배치의 첫 문장이어야 하므로 GO로 분리 */
CREATE VIEW dbo.v_active_employee_summary AS
SELECT e.emp_id,e.emp_name,e.dept_id,d.dept_name,e.salary
FROM dbo.employee e JOIN dbo.department d ON d.dept_id=e.dept_id
WHERE e.status='ACTIVE'
WITH CHECK OPTION;
GO

SELECT * FROM dbo.v_active_employee_summary ORDER BY dept_id,emp_id;

/* 안전한 DDL 데모 */
SELECT TOP (0) emp_id,emp_name INTO dbo.ddl_demo FROM dbo.employee;
ALTER TABLE dbo.ddl_demo ADD note nvarchar(100) NULL CONSTRAINT df_ddl_demo_note DEFAULT N'연습';
EXEC sys.sp_rename 'dbo.ddl_demo.note','memo','COLUMN';
EXEC sys.sp_rename 'dbo.ddl_demo','ddl_demo_renamed';
TRUNCATE TABLE dbo.ddl_demo_renamed;
DROP TABLE dbo.ddl_demo_renamed;

/* DCL은 권한이 있는 계정에서만 실행한다.
GRANT SELECT ON dbo.v_active_employee_summary TO [학습계정];
REVOKE SELECT ON dbo.v_active_employee_summary FROM [학습계정];
*/

SELECT 'SQL SERVER SCRIPT COMPLETED' AS execution_status;
