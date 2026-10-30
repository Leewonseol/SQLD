-- =====================================================================
-- H. 정답 및 검증 | 09_set_operations ex02_set_operation_rules | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_set_operation_rules.md
-- =====================================================================

PROMPT == [G1] 사원명·부서명 한 열 + 출처
CREATE OR REPLACE VIEW ans09_02_g1 (name, src) AS
SELECT ename, 'E' FROM emp WHERE deptno = 10 UNION ALL SELECT dname, 'D' FROM dept WHERE deptno = 10;
CREATE OR REPLACE VIEW exp09_02_g1 (name, src) AS
-- (name, src)
SELECT 'ACCOUNTING', 'D' FROM dual
UNION ALL SELECT 'CLARK', 'E' FROM dual
UNION ALL SELECT 'KING', 'E' FROM dual
UNION ALL SELECT 'MILLER', 'E' FROM dual;
EXEC lab_check('09-ex02-G1', 'ANS09_02_G1', 'EXP09_02_G1')
SELECT * FROM ans09_02_g1 ORDER BY 1, 2;

PROMPT == [G2] 숫자와 문자를 문자로 통일한 집합
-- 변환하지 않으면 Oracle ORA-01790, SQL Server Msg 245('ACCOUNTING' 을 TINYINT 로 바꾸다 실패).
CREATE OR REPLACE VIEW ans09_02_g2 (v) AS
SELECT TO_CHAR(deptno) FROM dept WHERE deptno = 10 UNION SELECT dname FROM dept WHERE deptno = 10;
CREATE OR REPLACE VIEW exp09_02_g2 (v) AS
-- (v)
SELECT '10' FROM dual
UNION ALL SELECT 'ACCOUNTING' FROM dual;
EXEC lab_check('09-ex02-G2', 'ANS09_02_G2', 'EXP09_02_G2')
SELECT * FROM ans09_02_g2 ORDER BY 1;
