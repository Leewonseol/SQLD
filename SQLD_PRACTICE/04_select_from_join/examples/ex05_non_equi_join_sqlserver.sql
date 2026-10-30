-- ex05 NON EQUI JOIN (PDF E-10)  | SQL Server
PRINT N'== [Q1] PDF 쿼리 그대로';
SELECT e.ename 사원명, e.sal 급여, s.grade 급여등급
FROM pdf_emp_sg e, pdf_salgrade s
WHERE e.sal BETWEEN s.losal AND s.hisal
ORDER BY e.sal;
PRINT N'== [Q2] JOIN ... ON 비등가 조건';
SELECT e.ename, e.sal, s.grade
FROM pdf_emp_sg e JOIN pdf_salgrade s ON e.sal >= s.losal AND e.sal <= s.hisal
ORDER BY e.sal;
PRINT N'== [Q3] 경계값과 등급 사이 틈';
SELECT v.sal, s.grade
FROM (VALUES (CAST(1200 AS DECIMAL(6,1))), (1200.5), (1201)) v(sal)
LEFT JOIN pdf_salgrade s ON v.sal BETWEEN s.losal AND s.hisal
ORDER BY v.sal;
