-- ex05 제3정규형(3NF): 이행 함수 종속 제거 (PDF E-01 사원·부서 예, 요구목록 §6)  | Oracle
EXEC lab_drop('N03_EMP3')
EXEC lab_drop('N03_DEPT3')
PROMPT == [Q1] PDF E-01: 사원(사번 PK, 이름, 부서번호, 부서명, 부서위치) 에서 사번 -> 부서번호 -> 부서명·부서위치 (이행 종속)
SELECT emp_no, name, dept_no, dept_name, dept_loc FROM n03_emp_orig ORDER BY emp_no;

PROMPT == [Q2] PDF 정규화 전 쿼리(사번 2401 의 사번·이름·부서명). PDF 원문 'WHERE 사='2401'' 은 컬럼명 오기 -> 사번
SELECT emp_no, name, dept_name FROM n03_emp_orig WHERE emp_no = '2401';

PROMPT == [Q3] 3NF 분해: 사원(사번, 이름, 부서번호 FK) + 부서(부서번호 PK, 부서명, 부서위치)
CREATE TABLE n03_dept3 AS SELECT DISTINCT dept_no, dept_name, dept_loc FROM n03_emp_orig;
CREATE TABLE n03_emp3 AS SELECT emp_no, name, dept_no FROM n03_emp_orig;
ALTER TABLE n03_dept3 ADD CONSTRAINT pk_n03_dept3 PRIMARY KEY (dept_no);
ALTER TABLE n03_emp3 ADD CONSTRAINT pk_n03_emp3 PRIMARY KEY (emp_no);
ALTER TABLE n03_emp3 ADD CONSTRAINT fk_n03_emp3_dept FOREIGN KEY (dept_no) REFERENCES n03_dept3(dept_no);

PROMPT == [Q4] PDF 정규화 후 쿼리: 함께 보려면 조인이 필요하다 (조인 키 = 외래키 부서번호)
SELECT a.emp_no, a.name, b.dept_name FROM n03_emp3 a, n03_dept3 b WHERE a.dept_no = b.dept_no AND a.emp_no = '2401';

PROMPT == [Q5] 무손실 검증: 분해 후 JOIN 결과 = 원래 테이블
SELECT COUNT(*) AS diff_rows FROM (
  (SELECT emp_no, name, dept_no, dept_name, dept_loc FROM n03_emp_orig
   MINUS SELECT e.emp_no, e.name, e.dept_no, d.dept_name, d.dept_loc FROM n03_emp3 e JOIN n03_dept3 d ON e.dept_no = d.dept_no)
  UNION ALL
  (SELECT e.emp_no, e.name, e.dept_no, d.dept_name, d.dept_loc FROM n03_emp3 e JOIN n03_dept3 d ON e.dept_no = d.dept_no
   MINUS SELECT emp_no, name, dept_no, dept_name, dept_loc FROM n03_emp_orig));

PROMPT == [Q6] 갱신 이상 해소: 부서 위치 변경은 부서 테이블 한 행만
UPDATE n03_dept3 SET dept_loc = '대전' WHERE dept_no = '100';
SELECT e.emp_no, d.dept_loc FROM n03_emp3 e JOIN n03_dept3 d ON e.dept_no = d.dept_no WHERE d.dept_no = '100';
ROLLBACK;
