-- =====================================================================
-- H. 정답 및 검증 | 07_single_row_functions ex02_number_functions | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_number_functions.md
-- =====================================================================

PROMPT == [G1] 10번 부서 보너스 100 단위 버림
-- ROUND 를 쓰면 CLARK 245 → 200, MILLER 130 → 100 으로 우연히 같지만 KING 500 도 같다. 250 이상이면 달라진다(예: 2550 → 반올림 300, 버림 200).
CREATE OR REPLACE VIEW ans07_02_g1 (ename, bonus) AS
SELECT ename, TRUNC(sal * 0.1, -2) FROM emp WHERE deptno = 10;
CREATE OR REPLACE VIEW exp07_02_g1 (ename, bonus) AS
-- (ename, bonus)
SELECT 'CLARK', 200 FROM dual
UNION ALL SELECT 'KING', 500 FROM dual
UNION ALL SELECT 'MILLER', 100 FROM dual;
EXEC lab_check('07-ex02-G1', 'ANS07_02_G1', 'EXP07_02_G1')
SELECT * FROM ans07_02_g1 ORDER BY 1, 2;

PROMPT == [G2] 사번 / 7 의 몫과 나머지
-- SQL Server 는 정수 / 정수가 정수 몫이다. Oracle 에서 empno / 7 만 쓰면 1111.714… 가 되어 CHECK_FAIL.
CREATE OR REPLACE VIEW ans07_02_g2 (empno, q, r) AS
SELECT empno, TRUNC(empno / 7), MOD(empno, 7) FROM emp WHERE deptno = 10;
CREATE OR REPLACE VIEW exp07_02_g2 (empno, q, r) AS
-- (empno, q, r)
SELECT 7782, 1111, 5 FROM dual
UNION ALL SELECT 7839, 1119, 6 FROM dual
UNION ALL SELECT 7934, 1133, 3 FROM dual;
EXEC lab_check('07-ex02-G2', 'ANS07_02_G2', 'EXP07_02_G2')
SELECT * FROM ans07_02_g2 ORDER BY 1, 2, 3;
