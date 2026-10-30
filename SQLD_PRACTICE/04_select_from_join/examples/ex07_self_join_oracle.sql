-- ex07 SELF JOIN (PDF E-02, E-12)  | Oracle   데이터: [PDF] EMPLOYEES, STAFF
PROMPT == [Q1] PDF E-12 쿼리 원문 그대로: WHERE E1.EMP_ID = E2.EMP_ID (자기 자신과 조인됨)
SELECT e1.emp_id, e1.name, e1.mgr_id, e2.emp_id AS e2_emp_id, e2.name AS e2_name
FROM employees e1, employees e2
WHERE e1.emp_id = e2.emp_id
ORDER BY e1.emp_id;

PROMPT == [Q2] PDF 결과표를 만드는 조건: 사원(E1)의 MGR_ID = 관리자(E2)의 EMP_ID
SELECT e1.emp_id, e1.name, e1.mgr_id, e2.emp_id AS mgr_emp_id, e2.name AS mgr_name
FROM employees e1, employees e2
WHERE e1.mgr_id = e2.emp_id
ORDER BY e1.emp_id;

PROMPT == [Q3] 관리자가 없는 KING 도 출력: OUTER JOIN
SELECT e1.emp_id, e1.name, e2.name AS mgr_name
FROM employees e1 LEFT OUTER JOIN employees e2 ON e1.mgr_id = e2.emp_id
ORDER BY e1.emp_id;

PROMPT == [Q4] PDF E-02 쿼리 원문 그대로: a.직원ID = b.상사ID, a.이름 AS 직원이름, b.이름 AS 상사
SELECT a.name AS 직원이름, b.name AS 상사
FROM staff a, staff b
WHERE a.staff_id = b.boss_id
ORDER BY a.staff_id, b.staff_id;

PROMPT == [Q5] PDF E-02 결과표(나사장-NULL 포함 5행)를 만드는 쿼리
SELECT a.name AS 직원이름, b.name AS 상사
FROM staff a LEFT JOIN staff b ON a.boss_id = b.staff_id
ORDER BY a.staff_id;

PROMPT == [Q6] 같은 테이블을 두 번 쓰면서 별칭을 생략 -> 오류
-- @expect-error: ORA-00918
SELECT name FROM staff, staff;
