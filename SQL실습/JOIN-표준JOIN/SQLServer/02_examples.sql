-- JOIN·표준 JOIN 예제 실행 (SQL Server)
-- 대상: 깨우침/JOIN·표준 JOIN 문제 풀이표.md 의 21개 개념 순서를 그대로 따른다.
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- Oracle/02_examples.sql과 example_id·기대값은 모두 동일하다. 차이는 딱 세 곳
-- (J15 USING, J16 NATURAL JOIN, J18 Oracle (+))뿐이며, 이 세 곳은 SQL Server가
-- 지원하지 않는 문법이므로 "지원하지 않는다"고 주석으로 명시하고 ON 기반의
-- 동등 구문으로 같은 결과를 낸다.

DELETE FROM sql_example_result WHERE example_id LIKE 'J%';

-- =====================================================================
-- J01. 테이블 수
-- 예상 결과: 1행(집계행), EMP 전체 8건
-- =====================================================================
SELECT * FROM emp;

INSERT INTO sql_example_result
SELECT 'J01', 1, COUNT(*), NULL, GETDATE() FROM emp;

-- =====================================================================
-- J02. 연결 조건 존재 여부 - 카티션 곱
-- 예상 결과: EMP(8) x DEPT(4) = 32행
-- =====================================================================
SELECT COUNT(*) AS cnt FROM emp CROSS JOIN dept;

INSERT INTO sql_example_result
SELECT 'J02', 1, COUNT(*), NULL, GETDATE() FROM emp CROSS JOIN dept;

-- =====================================================================
-- J03. 연결 조건 존재 여부 - 조건부 JOIN
-- 예상 결과: 8행
-- =====================================================================
SELECT e.ename, d.dname
FROM emp e JOIN dept d ON e.deptno = d.deptno;

INSERT INTO sql_example_result
SELECT 'J03', 1, COUNT(*), NULL, GETDATE()
FROM emp e JOIN dept d ON e.deptno = d.deptno;

-- =====================================================================
-- J04. 카티션 곱 계산 (행수=곱, 열수=합)
-- 예상 결과: DEPT(4행,2열) x GRADE_BAND(3행,2열) = 12행, 4열
-- =====================================================================
SELECT COUNT(*) AS row_cnt, 2 + 2 AS col_cnt
FROM dept CROSS JOIN grade_band;

INSERT INTO sql_example_result
SELECT 'J04', 1, COUNT(*), NULL, GETDATE() FROM dept CROSS JOIN grade_band;

-- =====================================================================
-- J05. CROSS JOIN - 첨부 표준 JOIN 문제 9번 유형(A 2행, B 3행)
-- 예상 결과: 2 x 3 = 6행
-- =====================================================================
SELECT COUNT(*) AS cnt FROM small_a CROSS JOIN small_b;

INSERT INTO sql_example_result
SELECT 'J05', 1, COUNT(*), NULL, GETDATE() FROM small_a CROSS JOIN small_b;

-- =====================================================================
-- J06. 등가 조인
-- 예상 결과: 8행
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'J06', 1, COUNT(*), NULL, GETDATE()
FROM emp e JOIN dept d ON e.deptno = d.deptno;

-- =====================================================================
-- J07. 비등가 조인 (SALARY BETWEEN LOSAL AND HISAL)
-- 예상 결과: 8행
-- =====================================================================
SELECT e.ename, e.salary, s.grade
FROM emp e JOIN salgrade s ON e.salary BETWEEN s.losal AND s.hisal;

INSERT INTO sql_example_result
SELECT 'J07', 1, COUNT(*), NULL, GETDATE()
FROM emp e JOIN salgrade s ON e.salary BETWEEN s.losal AND s.hisal;

-- =====================================================================
-- J08. 조인 조건과 일반 필터 조건 구분
-- 예상 결과: 4행 (JONES 2975, BLAKE 2850, CLARK 2450, SCOTT 3000)
-- =====================================================================
SELECT e.ename, e.salary
FROM emp e JOIN dept d ON e.deptno = d.deptno
WHERE e.salary > 2000;

INSERT INTO sql_example_result
SELECT 'J08', 1, COUNT(*), NULL, GETDATE()
FROM emp e JOIN dept d ON e.deptno = d.deptno
WHERE e.salary > 2000;

-- =====================================================================
-- J09. 중복값에 따른 결과 행 수 증가
-- 예상 결과: 3행 (COL1=1: 0개, COL1=2: 1x2=2개, COL1=3: 1x1=1개, 합계 3)
-- =====================================================================
SELECT t1.col1
FROM dup_t1 t1 JOIN dup_t2 t2 ON t1.col1 = t2.col1;

INSERT INTO sql_example_result
SELECT 'J09', 1, COUNT(*), NULL, GETDATE()
FROM dup_t1 t1 JOIN dup_t2 t2 ON t1.col1 = t2.col1;

-- =====================================================================
-- J10. INNER JOIN
-- 예상 결과: 2행 (공통 학번 202301, 202302만 유지)
-- =====================================================================
SELECT s.stuno, s.stuname, sc.subject, sc.scoreval
FROM student s JOIN score sc ON s.stuno = sc.stuno;

INSERT INTO sql_example_result
SELECT 'J10', 1, COUNT(*), NULL, GETDATE()
FROM student s JOIN score sc ON s.stuno = sc.stuno;

-- =====================================================================
-- J11. LEFT OUTER JOIN
-- 예상 결과: 3행 (학생 3명 전원 보존, 202303은 성적 열이 NULL)
-- =====================================================================
SELECT s.stuno, s.stuname, sc.scoreval
FROM student s LEFT OUTER JOIN score sc ON s.stuno = sc.stuno;

INSERT INTO sql_example_result
SELECT 'J11', 1, COUNT(*), NULL, GETDATE()
FROM student s LEFT OUTER JOIN score sc ON s.stuno = sc.stuno;

-- =====================================================================
-- J12. RIGHT OUTER JOIN
-- 예상 결과: 3행 (성적 3건 보존, 202304는 학생쪽 열이 NULL)
-- =====================================================================
SELECT s.stuno, sc.stuno AS score_stuno, sc.scoreval
FROM student s RIGHT OUTER JOIN score sc ON s.stuno = sc.stuno;

INSERT INTO sql_example_result
SELECT 'J12', 1, COUNT(*), NULL, GETDATE()
FROM student s RIGHT OUTER JOIN score sc ON s.stuno = sc.stuno;

-- =====================================================================
-- J13. FULL OUTER JOIN - 첨부 표준 JOIN 문제 8번 그대로(A:1,2 / B:2,3)
-- 예상 결과: 3행
-- =====================================================================
SELECT a.id AS a_id, b.id AS b_id
FROM full_a a FULL OUTER JOIN full_b b ON a.id = b.id;

INSERT INTO sql_example_result
SELECT 'J13', 1, COUNT(*), NULL, GETDATE()
FROM full_a a FULL OUTER JOIN full_b b ON a.id = b.id;

-- =====================================================================
-- J13B. FULL OUTER JOIN 추가 연습(STUDENT/SCORE)
-- 예상 결과: 4행
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'J13B', 1, COUNT(*), NULL, GETDATE()
FROM student s FULL OUTER JOIN score sc ON s.stuno = sc.stuno;

-- =====================================================================
-- J14. ON - 열 이름이 서로 달라도 가능 (EMP.DEPTNO = DEPT2.DEPT_ID)
-- 예상 결과: 8행
-- =====================================================================
SELECT e.ename, d2.dept_name
FROM emp e JOIN dept2 d2 ON e.deptno = d2.dept_id;

INSERT INTO sql_example_result
SELECT 'J14', 1, COUNT(*), NULL, GETDATE()
FROM emp e JOIN dept2 d2 ON e.deptno = d2.dept_id;

-- =====================================================================
-- J15. USING - SQL Server는 USING을 지원하지 않는다.
--   *** 개념적 대응: Oracle의 USING (STUNO)는 SQL Server에서
--   ON STUDENT.STUNO = SCORE.STUNO 로만 표현할 수 있다(공통 열 이름을
--   한 번만 쓰는 축약 문법 자체가 없다). ***
-- 예상 결과: 2행 (Oracle의 USING 결과와 동일해야 함)
-- =====================================================================
SELECT s.stuno, s.stuname, sc.subject, sc.scoreval
FROM student s JOIN score sc ON s.stuno = sc.stuno;

INSERT INTO sql_example_result
SELECT 'J15', 1, COUNT(*), NULL, GETDATE()
FROM student s JOIN score sc ON s.stuno = sc.stuno;

-- =====================================================================
-- J16. NATURAL JOIN - SQL Server는 NATURAL JOIN을 지원하지 않는다.
--   *** 개념적 대응: 공통 열(STUNO) 하나를 자동으로 찾아 등가 조인하는
--   NATURAL JOIN은 SQL Server에 없으며, 반드시 ON으로 직접 명시해야 한다. ***
-- 예상 결과: 2행 (Oracle의 NATURAL JOIN 결과와 동일해야 함)
-- =====================================================================
SELECT s.stuno, s.stuname, sc.subject, sc.scoreval
FROM student s JOIN score sc ON s.stuno = sc.stuno;

INSERT INTO sql_example_result
SELECT 'J16', 1, COUNT(*), NULL, GETDATE()
FROM student s JOIN score sc ON s.stuno = sc.stuno;

-- =====================================================================
-- J17. 구문형 JOIN (FROM A, B ... WHERE 조인조건)
-- 예상 결과: 4행
-- =====================================================================
SELECT a.ename, a.salary
FROM emp a, dept b
WHERE a.deptno = b.deptno
  AND a.salary > 2000;

INSERT INTO sql_example_result
SELECT 'J17', 1, COUNT(*), NULL, GETDATE()
FROM emp a, dept b
WHERE a.deptno = b.deptno
  AND a.salary > 2000;

-- =====================================================================
-- J18. Oracle (+) 동등 표현 - SQL Server는 (+) 구문을 지원하지 않는다.
--   *** 개념적 대응: DEPT a, EMP b WHERE a.DEPTNO = b.DEPTNO(+) 는
--   SQL Server에서 DEPT a LEFT JOIN EMP b ON a.DEPTNO = b.DEPTNO 로만
--   표현할 수 있다. ***
-- 예상 결과: 9행 (EMP 8행이 각자의 DEPT와 매칭 + DEPT 40이 EMP NULL로 보존)
-- =====================================================================
SELECT a.deptno, a.dname, b.ename
FROM dept a LEFT JOIN emp b ON a.deptno = b.deptno;

INSERT INTO sql_example_result
SELECT 'J18', 1, COUNT(*), NULL, GETDATE()
FROM dept a LEFT JOIN emp b ON a.deptno = b.deptno;

-- =====================================================================
-- J19. OUTER JOIN 이후 WHERE로 미일치 행 제거
-- 예상 결과: 1행 (M1의 휴대폰 연락처만 남음)
-- =====================================================================
SELECT m.memberid, c.contact_type, c.contact_no
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid
WHERE c.contact_type = N'휴대폰';

INSERT INTO sql_example_result
SELECT 'J19', 1, COUNT(*), NULL, GETDATE()
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid
WHERE c.contact_type = N'휴대폰';

-- =====================================================================
-- J20. LEFT JOIN + IS NULL
-- 예상 결과: 1행 (연락처가 없는 회원 M3)
-- =====================================================================
SELECT m.memberid, m.membername
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid
WHERE c.memberid IS NULL;

INSERT INTO sql_example_result
SELECT 'J20', 1, COUNT(*), NULL, GETDATE()
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid
WHERE c.memberid IS NULL;

-- =====================================================================
-- J21 / J21B. COUNT(*)와 COUNT(오른쪽 열)의 차이
-- 예상 결과: COUNT(*)=4(J21), COUNT(CONTACT.MEMBERID)=3(J21B)
-- =====================================================================
SELECT COUNT(*) AS cnt_star, COUNT(c.memberid) AS cnt_col
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid;

INSERT INTO sql_example_result
SELECT 'J21', COUNT(*), NULL, NULL, GETDATE()
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid;

INSERT INTO sql_example_result
SELECT 'J21B', 1, COUNT(c.memberid), NULL, GETDATE()
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid;

-- =====================================================================
-- J22. 테이블 별칭
--   잘못된 예(실행하지 않음, 오류 발생):
--   SELECT emp.ename FROM emp a, dept b WHERE a.deptno = b.deptno;
-- 예상 결과: 8행 (올바른 별칭 사용)
-- =====================================================================
SELECT a.ename, b.dname
FROM emp a, dept b
WHERE a.deptno = b.deptno;

INSERT INTO sql_example_result
SELECT 'J22', 1, COUNT(*), NULL, GETDATE()
FROM emp a, dept b
WHERE a.deptno = b.deptno;

-- =====================================================================
-- J23. 첨부 문제 형태와 유사한 행 수 계산 연습
-- 예상 결과: 3행
--   ID=1: BRANCH_SALES에 없음 -> 0행
--   ID=2: BRANCH 1행 x BRANCH_SALES 2행 -> 2행 생성
--   ID=3: BRANCH 1행 x BRANCH_SALES 1행 -> 1행 생성
--   총 3행
-- =====================================================================
SELECT br.id
FROM branch br JOIN branch_sales bs ON br.id = bs.id;

INSERT INTO sql_example_result
SELECT 'J23', 1, COUNT(*), NULL, GETDATE()
FROM branch br JOIN branch_sales bs ON br.id = bs.id;
