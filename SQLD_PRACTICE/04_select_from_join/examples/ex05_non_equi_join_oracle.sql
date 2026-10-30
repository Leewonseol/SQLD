-- ex05 NON EQUI JOIN (PDF E-10)  | Oracle   데이터: [PDF] PDF_EMP_SG, PDF_SALGRADE
PROMPT == [Q1] PDF 쿼리 그대로: BETWEEN 으로 급여 등급 찾기
SELECT e.ename 사원명, e.sal 급여, s.grade 급여등급
FROM pdf_emp_sg e, pdf_salgrade s
WHERE e.sal BETWEEN s.losal AND s.hisal
ORDER BY e.sal;

PROMPT == [Q2] 같은 의미를 >= / <= 로 (ANSI JOIN ... ON 에 비등가 조건)
SELECT e.ename, e.sal, s.grade
FROM pdf_emp_sg e JOIN pdf_salgrade s ON e.sal >= s.losal AND e.sal <= s.hisal
ORDER BY e.sal;

PROMPT == [Q3] 경계값: 1200 은 1등급, 1200.5 는 어느 구간에도 없다(등급 사이 틈) -> INNER 결과에서 빠짐
SELECT v.sal, s.grade
FROM (SELECT 1200 AS sal FROM dual UNION ALL SELECT 1200.5 FROM dual UNION ALL SELECT 1201 FROM dual) v
LEFT JOIN pdf_salgrade s ON v.sal BETWEEN s.losal AND s.hisal
ORDER BY v.sal;
