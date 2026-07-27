-- JOIN·표준 JOIN 예제 실행 (Oracle)
-- 대상: 깨우침/JOIN·표준 JOIN 문제 풀이표.md 의 21개 개념 순서를 그대로 따른다.
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
--
-- 각 예제는 두 부분으로 구성된다.
--   1) 사람이 결과를 눈으로 볼 수 있는 SELECT(그대로 실행 가능, 조회용)
--   2) sql_example_result에 example_id별로 정확히 1행을 남기는 INSERT
-- 재실행해도 중복이 쌓이지 않도록, 이 예제들이 쓰는 example_id 범위를 먼저 지운다.

DELETE FROM sql_example_result WHERE example_id LIKE 'J%';
COMMIT;

-- =====================================================================
-- J01. 테이블 수 (FROM에 테이블 1개 -> JOIN 아님)
-- 예상 결과: 1행(집계행), EMP 전체 8건
-- =====================================================================
SELECT * FROM emp;

INSERT INTO sql_example_result
SELECT 'J01', 1, COUNT(*), NULL, SYSDATE FROM emp;

-- =====================================================================
-- J02. 연결 조건 존재 여부 - 카티션 곱 (조건 없음)
-- 예상 결과: EMP(8) x DEPT(4) = 32행
-- =====================================================================
SELECT COUNT(*) AS cnt FROM emp CROSS JOIN dept;

INSERT INTO sql_example_result
SELECT 'J02', 1, COUNT(*), NULL, SYSDATE FROM emp CROSS JOIN dept;

-- =====================================================================
-- J03. 연결 조건 존재 여부 - 조건부 JOIN
-- 예상 결과: 8행. EMP 8명 전원이 DEPT(10,20,30) 안에 속하므로 카티션 곱(32행)
-- 대신 조건을 만족하는 8행만 남는다.
-- =====================================================================
SELECT e.ename, d.dname
FROM emp e JOIN dept d ON e.deptno = d.deptno;

INSERT INTO sql_example_result
SELECT 'J03', 1, COUNT(*), NULL, SYSDATE
FROM emp e JOIN dept d ON e.deptno = d.deptno;

-- =====================================================================
-- J04. 카티션 곱 계산 (행수=곱, 열수=합)
-- 예상 결과: DEPT(4행,2열) x GRADE_BAND(3행,2열) = 12행, 4열
-- =====================================================================
SELECT COUNT(*) AS row_cnt, 2 + 2 AS col_cnt
FROM dept CROSS JOIN grade_band;

INSERT INTO sql_example_result
SELECT 'J04', 1, COUNT(*), NULL, SYSDATE FROM dept CROSS JOIN grade_band;

-- =====================================================================
-- J05. CROSS JOIN - 첨부 표준 JOIN 문제 9번 유형(A 2행, B 3행)
-- 예상 결과: 2 x 3 = 6행
-- =====================================================================
SELECT COUNT(*) AS cnt FROM small_a CROSS JOIN small_b;

INSERT INTO sql_example_result
SELECT 'J05', 1, COUNT(*), NULL, SYSDATE FROM small_a CROSS JOIN small_b;

-- =====================================================================
-- J06. 등가 조인 (A.DEPTNO = B.DEPTNO)
-- 예상 결과: 8행 (J03과 동일 데이터, "=" 비교라는 점을 강조)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'J06', 1, COUNT(*), NULL, SYSDATE
FROM emp e JOIN dept d ON e.deptno = d.deptno;

-- =====================================================================
-- J07. 비등가 조인 (SALARY BETWEEN LOSAL AND HISAL)
-- 예상 결과: 8행. EMP 8명 전원의 급여가 SALGRADE 어느 한 구간에 속한다.
-- =====================================================================
SELECT e.ename, e.salary, s.grade
FROM emp e JOIN salgrade s ON e.salary BETWEEN s.losal AND s.hisal;

INSERT INTO sql_example_result
SELECT 'J07', 1, COUNT(*), NULL, SYSDATE
FROM emp e JOIN salgrade s ON e.salary BETWEEN s.losal AND s.hisal;

-- =====================================================================
-- J08. 조인 조건과 일반 필터 조건 구분
--   DEPTNO 조건 = 조인 조건, SALARY>2000 = 일반 필터 조건
-- 예상 결과: 4행 (JONES 2975, BLAKE 2850, CLARK 2450, SCOTT 3000)
-- =====================================================================
SELECT e.ename, e.salary
FROM emp e JOIN dept d ON e.deptno = d.deptno
WHERE e.salary > 2000;

INSERT INTO sql_example_result
SELECT 'J08', 1, COUNT(*), NULL, SYSDATE
FROM emp e JOIN dept d ON e.deptno = d.deptno
WHERE e.salary > 2000;

-- =====================================================================
-- J09. 중복값에 따른 결과 행 수 증가 - 첨부 JOIN 문제 5번
--   T1(1,2,3) x T2(2,2,3)
-- 예상 결과: 3행 (COL1=1: 0개, COL1=2: 1x2=2개, COL1=3: 1x1=1개, 합계 3)
-- =====================================================================
SELECT t1.col1
FROM dup_t1 t1 JOIN dup_t2 t2 ON t1.col1 = t2.col1;

INSERT INTO sql_example_result
SELECT 'J09', 1, COUNT(*), NULL, SYSDATE
FROM dup_t1 t1 JOIN dup_t2 t2 ON t1.col1 = t2.col1;

-- =====================================================================
-- J10. INNER JOIN - STUDENT(202301,202302,202303) / SCORE(202301,202302,202304)
-- 예상 결과: 2행 (공통 학번 202301, 202302만 유지)
-- =====================================================================
SELECT s.stuno, s.stuname, sc.subject, sc.scoreval
FROM student s JOIN score sc ON s.stuno = sc.stuno;

INSERT INTO sql_example_result
SELECT 'J10', 1, COUNT(*), NULL, SYSDATE
FROM student s JOIN score sc ON s.stuno = sc.stuno;

-- =====================================================================
-- J11. LEFT OUTER JOIN
-- 예상 결과: 3행 (학생 3명 전원 보존, 202303은 성적 열이 NULL)
-- =====================================================================
SELECT s.stuno, s.stuname, sc.scoreval
FROM student s LEFT OUTER JOIN score sc ON s.stuno = sc.stuno;

INSERT INTO sql_example_result
SELECT 'J11', 1, COUNT(*), NULL, SYSDATE
FROM student s LEFT OUTER JOIN score sc ON s.stuno = sc.stuno;

-- =====================================================================
-- J12. RIGHT OUTER JOIN
-- 예상 결과: 3행 (성적 3건 보존, 202304는 학생쪽 열이 NULL)
-- =====================================================================
SELECT s.stuno, sc.stuno AS score_stuno, sc.scoreval
FROM student s RIGHT OUTER JOIN score sc ON s.stuno = sc.stuno;

INSERT INTO sql_example_result
SELECT 'J12', 1, COUNT(*), NULL, SYSDATE
FROM student s RIGHT OUTER JOIN score sc ON s.stuno = sc.stuno;

-- =====================================================================
-- J13. FULL OUTER JOIN - 첨부 표준 JOIN 문제 8번 그대로(A:1,2 / B:2,3)
-- 예상 결과: 3행 (1은 A에만, 2는 양쪽에 결합 1행, 3은 B에만 -> 총 3행)
-- =====================================================================
SELECT a.id AS a_id, b.id AS b_id
FROM full_a a FULL OUTER JOIN full_b b ON a.id = b.id;

INSERT INTO sql_example_result
SELECT 'J13', 1, COUNT(*), NULL, SYSDATE
FROM full_a a FULL OUTER JOIN full_b b ON a.id = b.id;

-- =====================================================================
-- J13B. FULL OUTER JOIN 추가 연습(STUDENT/SCORE)
-- 예상 결과: 4행 (202301,202302,202303,202304 각각 1행씩)
-- =====================================================================
INSERT INTO sql_example_result
SELECT 'J13B', 1, COUNT(*), NULL, SYSDATE
FROM student s FULL OUTER JOIN score sc ON s.stuno = sc.stuno;

-- =====================================================================
-- J14. ON - 열 이름이 서로 달라도 가능 (EMP.DEPTNO = DEPT2.DEPT_ID)
-- 예상 결과: 8행 (J03과 같은 결과지만 조인 열 이름이 서로 다름 -> USING/NATURAL 불가,
-- ON만 가능함을 보여준다)
-- =====================================================================
SELECT e.ename, d2.dept_name
FROM emp e JOIN dept2 d2 ON e.deptno = d2.dept_id;

INSERT INTO sql_example_result
SELECT 'J14', 1, COUNT(*), NULL, SYSDATE
FROM emp e JOIN dept2 d2 ON e.deptno = d2.dept_id;

-- =====================================================================
-- J15. USING - 양쪽 조인 열 이름이 같을 때(STUNO)
-- 예상 결과: 2행 (INNER JOIN과 동일한 등가 조인 결과)
-- =====================================================================
SELECT stuno, stuname, subject, scoreval
FROM student JOIN score USING (stuno);

INSERT INTO sql_example_result
SELECT 'J15', 1, COUNT(*), NULL, SYSDATE
FROM student JOIN score USING (stuno);

-- =====================================================================
-- J16. NATURAL JOIN - 이름이 같은 공통 열(STUNO)을 자동으로 사용
-- 예상 결과: 2행 (STUDENT/SCORE의 공통 열은 STUNO 하나뿐이므로 USING(STUNO)과 동일)
-- =====================================================================
SELECT stuno, stuname, subject, scoreval
FROM student NATURAL JOIN score;

INSERT INTO sql_example_result
SELECT 'J16', 1, COUNT(*), NULL, SYSDATE
FROM student NATURAL JOIN score;

-- =====================================================================
-- J17. 구문형 JOIN (FROM A, B ... WHERE 조인조건)
-- 예상 결과: 4행 (J08과 같은 조건, 문법만 다름)
-- =====================================================================
SELECT a.ename, a.salary
FROM emp a, dept b
WHERE a.deptno = b.deptno
  AND a.salary > 2000;

INSERT INTO sql_example_result
SELECT 'J17', 1, COUNT(*), NULL, SYSDATE
FROM emp a, dept b
WHERE a.deptno = b.deptno
  AND a.salary > 2000;

-- =====================================================================
-- J18. Oracle (+) - DEPT을 기준으로 보존, EMP가 부족한 쪽
--   DEPT 40(OPERATIONS)에는 직원이 없다 -> (+) 없이 등가조인하면 사라질 행이
--   (+) 덕분에 EMP 쪽 열이 NULL인 채로 보존된다.
-- 예상 결과: 9행 (EMP 8행이 각자의 DEPT와 매칭 + DEPT 40이 EMP NULL로 보존)
-- =====================================================================
SELECT a.deptno, a.dname, b.ename
FROM dept a, emp b
WHERE a.deptno = b.deptno(+);

INSERT INTO sql_example_result
SELECT 'J18', 1, COUNT(*), NULL, SYSDATE
FROM dept a, emp b
WHERE a.deptno = b.deptno(+);

-- =====================================================================
-- J19. OUTER JOIN 이후 WHERE로 미일치 행 제거
--   MEMBER 3명을 LEFT JOIN으로 전부 보존한 뒤, WHERE로 '휴대폰'만 필터링하면
--   LEFT JOIN으로 보존했던 M3(연락처 없음)이 다시 사라진다.
-- 예상 결과: 1행 (M1의 휴대폰 연락처만 남음)
-- =====================================================================
SELECT m.memberid, c.contact_type, c.contact_no
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid
WHERE c.contact_type = '휴대폰';

INSERT INTO sql_example_result
SELECT 'J19', 1, COUNT(*), NULL, SYSDATE
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid
WHERE c.contact_type = '휴대폰';

-- =====================================================================
-- J20. LEFT JOIN + IS NULL - 오른쪽에 대응 행이 없는 왼쪽 행만 추출
-- 예상 결과: 1행 (연락처가 없는 회원 M3)
-- =====================================================================
SELECT m.memberid, m.membername
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid
WHERE c.memberid IS NULL;

INSERT INTO sql_example_result
SELECT 'J20', 1, COUNT(*), NULL, SYSDATE
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid
WHERE c.memberid IS NULL;

-- =====================================================================
-- J21 / J21B. COUNT(*)와 COUNT(오른쪽 열)의 차이
--   LEFT JOIN 결과: M1(2행) + M2(1행) + M3(연락처 NULL, 1행) = 4행
-- 예상 결과: COUNT(*)=4(J21), COUNT(CONTACT.MEMBERID)=3(J21B, M3의 NULL 제외)
-- =====================================================================
SELECT COUNT(*) AS cnt_star, COUNT(c.memberid) AS cnt_col
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid;

INSERT INTO sql_example_result
SELECT 'J21', COUNT(*), NULL, NULL, SYSDATE
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid;

INSERT INTO sql_example_result
SELECT 'J21B', 1, COUNT(c.memberid), NULL, SYSDATE
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid;

-- =====================================================================
-- J22. 테이블 별칭
--   FROM EMP A, DEPT B 선언 후에는 A.ENAME처럼 별칭으로만 참조해야 한다.
--   아래 EMP.ENAME은 별칭 선언 후 원래 테이블명을 쓴 오류 예시이며 실행하지
--   않는다(주석 처리, 첨부 JOIN 문제 2번 유형).
-- 예상 결과: 8행 (올바른 별칭 사용)
-- =====================================================================
-- 잘못된 예(실행하지 않음, 오류 발생):
-- SELECT EMP.ename FROM emp A, dept B WHERE A.deptno = B.deptno;

SELECT a.ename, b.dname
FROM emp a, dept b
WHERE a.deptno = b.deptno;

INSERT INTO sql_example_result
SELECT 'J22', 1, COUNT(*), NULL, SYSDATE
FROM emp a, dept b
WHERE a.deptno = b.deptno;

-- =====================================================================
-- J23. 첨부 문제 형태와 유사한 행 수 계산 연습
--   BRANCH(1,2,3) x BRANCH_SALES(2,2,3)
-- 예상 결과: 3행
--   ID=1: BRANCH_SALES에 없음 -> 0행
--   ID=2: BRANCH 1행 x BRANCH_SALES 2행 -> 2행 생성
--   ID=3: BRANCH 1행 x BRANCH_SALES 1행 -> 1행 생성
--   총 3행
-- =====================================================================
SELECT br.id
FROM branch br JOIN branch_sales bs ON br.id = bs.id;

INSERT INTO sql_example_result
SELECT 'J23', 1, COUNT(*), NULL, SYSDATE
FROM branch br JOIN branch_sales bs ON br.id = bs.id;

COMMIT;
