-- =====================================================================
-- H. 정답 및 검증 | 12_hierarchical_queries ex01_connect_by | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_connect_by.md
-- =====================================================================

PROMPT == [G1] LEVEL 3 사원
-- LEVEL 조건을 CONNECT BY 쪽(… AND LEVEL <= 3)에 두면 전개 자체를 3단계에서 멈춰 더 효율적이다. 결과 필터는 WHERE.
CREATE OR REPLACE VIEW ans12_01_g1 (ename, mgr, lvl) AS
SELECT ename, mgr, LEVEL FROM emp WHERE LEVEL = 3 START WITH mgr IS NULL CONNECT BY PRIOR empno = mgr;
CREATE OR REPLACE VIEW exp12_01_g1 (ename, mgr, lvl) AS
-- (ename, mgr, lvl)
SELECT 'ALLEN', 7698, 3 FROM dual
UNION ALL SELECT 'FORD', 7566, 3 FROM dual
UNION ALL SELECT 'JAMES', 7698, 3 FROM dual
UNION ALL SELECT 'MARTIN', 7698, 3 FROM dual
UNION ALL SELECT 'MILLER', 7782, 3 FROM dual
UNION ALL SELECT 'SCOTT', 7566, 3 FROM dual
UNION ALL SELECT 'TURNER', 7698, 3 FROM dual
UNION ALL SELECT 'WARD', 7698, 3 FROM dual;
EXEC lab_check('12-ex01-G1', 'ANS12_01_G1', 'EXP12_01_G1')
SELECT * FROM ans12_01_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] JONES 의 모든 부하
-- START WITH mgr = (SELECT empno … 'JONES') 로 시작하면 JONES 자신이 빠진 상태로 바로 부하부터 전개할 수도 있다.
CREATE OR REPLACE VIEW ans12_01_g2 (ename) AS
SELECT ename FROM emp WHERE ename <> 'JONES' START WITH ename = 'JONES' CONNECT BY PRIOR empno = mgr;
CREATE OR REPLACE VIEW exp12_01_g2 (ename) AS
-- (ename)
SELECT 'ADAMS' FROM dual
UNION ALL SELECT 'FORD' FROM dual
UNION ALL SELECT 'SCOTT' FROM dual
UNION ALL SELECT 'SMITH' FROM dual;
EXEC lab_check('12-ex01-G2', 'ANS12_01_G2', 'EXP12_01_G2')
SELECT * FROM ans12_01_g2 ORDER BY 1;
