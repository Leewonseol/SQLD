-- ex08 ON·USING·NATURAL JOIN (PDF E-15, E-16, E-17)  | Oracle   데이터: [PDF] NJ_T1, NJ_T2, NJ_T3
PROMPT == [Q1] NATURAL JOIN nj_t1 - nj_t2 : 이름이 같은 모든 컬럼(NO, NAME)이 같아야 조인
SELECT * FROM nj_t1 NATURAL JOIN nj_t2;

PROMPT == [Q2] NATURAL JOIN nj_t1 - nj_t3 : 공통 컬럼은 NO 하나. SELECT * 에서 공통 컬럼이 맨 앞, 한 번만
SELECT * FROM nj_t1 NATURAL JOIN nj_t3 ORDER BY no, pos;

PROMPT == [Q3] USING (no) : NAME 은 공통 조인 컬럼이 아니므로 양쪽에 따로 남는다
SELECT no, a.name AS t1_name, b.name AS t2_name
FROM nj_t1 a JOIN nj_t2 b USING (no)
ORDER BY no;

PROMPT == [Q4] ON a.no = b.no : USING 과 같은 행, 하지만 NO 컬럼이 두 번 나온다
SELECT * FROM nj_t1 a JOIN nj_t2 b ON a.no = b.no ORDER BY a.no;

PROMPT == [Q5] USING 컬럼에 테이블 접두사 -> 오류 (PDF E-16)
-- @expect-error: ORA-25154
SELECT a.no FROM nj_t1 a JOIN nj_t2 b USING (no);

PROMPT == [Q6] NATURAL JOIN 컬럼에 접두사 -> 오류 (PDF E-17)
-- @expect-error: ORA-25155
SELECT a.no FROM nj_t1 a NATURAL JOIN nj_t2 b;

PROMPT == [Q7] NATURAL JOIN 에 ON 추가 -> 오류 (PDF E-17)
-- @expect-error: ORA-00933
SELECT * FROM nj_t1 NATURAL JOIN nj_t2 ON nj_t1.no = nj_t2.no;

PROMPT == [Q8] USING 괄호 생략 -> 오류 (PDF E-16 "괄호 필수")
-- @expect-error: ORA-00905
SELECT no FROM nj_t1 JOIN nj_t2 USING no;

PROMPT == [Q9] PDF 예: EMP NATURAL JOIN DEPT (공통 컬럼 DEPTNO). WHERE 의 일반 필터는 허용
SELECT deptno, empno, ename, dname FROM emp NATURAL JOIN dept WHERE deptno = 10 ORDER BY empno;

PROMPT == [Q10] PDF 예: NATURAL JOIN 결과에서 DEPT.DEPTNO 로 접두사 -> 오류
-- @expect-error: ORA-25155
SELECT dept.deptno, empno, ename, dname FROM emp NATURAL JOIN dept;
