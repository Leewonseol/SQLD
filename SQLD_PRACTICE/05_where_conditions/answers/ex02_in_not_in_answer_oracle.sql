-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex02_in_not_in | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_in_not_in.md
-- =====================================================================

PROMPT == [G1] 관리자 7566·7788·NULL
-- IN (7566, 7788, NULL) 로 쓰면 KING 이 빠진다.
CREATE OR REPLACE VIEW ans05_02_g1 (ename, mgr) AS
SELECT ename, mgr FROM emp WHERE mgr IN (7566, 7788) OR mgr IS NULL;
CREATE OR REPLACE VIEW exp05_02_g1 (ename, mgr) AS
-- (ename, mgr)
SELECT 'ADAMS', 7788 FROM dual
UNION ALL SELECT 'FORD', 7566 FROM dual
UNION ALL SELECT 'KING', CAST(NULL AS NUMBER) FROM dual
UNION ALL SELECT 'SCOTT', 7566 FROM dual;
EXEC lab_check('05-ex02-G1', 'ANS05_02_G1', 'EXP05_02_G1')
SELECT * FROM ans05_02_g1 ORDER BY 1, 2;

PROMPT == [G2] 관리자가 7698 이 아닌 사원(NULL 포함)
-- Oracle 은 NVL(mgr, 0) <> 7698, SQL Server 는 ISNULL(mgr, 0) <> 7698 도 가능(0 이 실제 사번이 아니라는 가정).
CREATE OR REPLACE VIEW ans05_02_g2 (ename) AS
SELECT ename FROM emp WHERE mgr NOT IN (7698) OR mgr IS NULL;
CREATE OR REPLACE VIEW exp05_02_g2 (ename) AS
-- (ename)
SELECT 'ADAMS' FROM dual
UNION ALL SELECT 'BLAKE' FROM dual
UNION ALL SELECT 'CLARK' FROM dual
UNION ALL SELECT 'FORD' FROM dual
UNION ALL SELECT 'JONES' FROM dual
UNION ALL SELECT 'KING' FROM dual
UNION ALL SELECT 'MILLER' FROM dual
UNION ALL SELECT 'SCOTT' FROM dual
UNION ALL SELECT 'SMITH' FROM dual;
EXEC lab_check('05-ex02-G2', 'ANS05_02_G2', 'EXP05_02_G2')
SELECT * FROM ans05_02_g2 ORDER BY 1;
