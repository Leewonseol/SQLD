-- ex07 SELF JOIN (PDF E-02, E-12)  | SQL Server
PRINT N'== [Q1] PDF E-12 쿼리 원문 그대로';
SELECT e1.emp_id, e1.name, e1.mgr_id, e2.emp_id AS e2_emp_id, e2.name AS e2_name
FROM employees e1, employees e2
WHERE e1.emp_id = e2.emp_id
ORDER BY e1.emp_id;
PRINT N'== [Q2] e1.mgr_id = e2.emp_id';
SELECT e1.emp_id, e1.name, e1.mgr_id, e2.emp_id AS mgr_emp_id, e2.name AS mgr_name
FROM employees e1, employees e2
WHERE e1.mgr_id = e2.emp_id
ORDER BY e1.emp_id;
PRINT N'== [Q3] OUTER JOIN';
SELECT e1.emp_id, e1.name, e2.name AS mgr_name
FROM employees e1 LEFT OUTER JOIN employees e2 ON e1.mgr_id = e2.emp_id
ORDER BY e1.emp_id;
PRINT N'== [Q4] PDF E-02 쿼리 원문 그대로';
SELECT a.name AS 직원이름, b.name AS 상사
FROM staff a, staff b
WHERE a.staff_id = b.boss_id
ORDER BY a.staff_id, b.staff_id;
PRINT N'== [Q5] PDF E-02 결과표를 만드는 쿼리';
SELECT a.name AS 직원이름, b.name AS 상사
FROM staff a LEFT JOIN staff b ON a.boss_id = b.staff_id
ORDER BY a.staff_id;
GO
PRINT N'== [Q6] 별칭 없이 같은 테이블 두 번 -> 오류';
GO
-- @expect-error: MSG-1013
SELECT name FROM staff, staff;
GO
