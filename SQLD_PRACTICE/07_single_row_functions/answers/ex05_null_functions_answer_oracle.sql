-- =====================================================================
-- H. 정답 및 검증 | 07_single_row_functions ex05_null_functions | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex05_null_functions.md
-- =====================================================================

PROMPT == [G1] 관리자 사번 문자, 없으면 TOP
-- SQL Server 에서 CAST(mgr AS VARCHAR(2)) 처럼 짧게 잡으면 변환 오류(Msg 8115 계열)가 난다. ISNULL 결과 길이는 첫 인수 길이를 따른다.
CREATE OR REPLACE VIEW ans07_05_g1 (ename, mgr_txt) AS
SELECT ename, NVL(TO_CHAR(mgr), 'TOP') FROM emp WHERE deptno = 10;
CREATE OR REPLACE VIEW exp07_05_g1 (ename, mgr_txt) AS
-- (ename, mgr_txt)
SELECT 'CLARK', '7839' FROM dual
UNION ALL SELECT 'KING', 'TOP' FROM dual
UNION ALL SELECT 'MILLER', '7782' FROM dual;
EXEC lab_check('07-ex05-G1', 'ANS07_05_G1', 'EXP07_05_G1')
SELECT * FROM ans07_05_g1 ORDER BY 1, 2;

PROMPT == [G2] COALESCE(comm, mgr, 0)
-- KING 은 comm·mgr 모두 NULL → 0. SMITH 는 comm NULL → mgr 7902. 의미가 다른 값(커미션과 사번)을 섞은 '나쁜 예'이기도 하다.
CREATE OR REPLACE VIEW ans07_05_g2 (ename, v) AS
SELECT ename, COALESCE(comm, mgr, 0) FROM emp WHERE ename IN ('KING', 'SMITH', 'ALLEN');
CREATE OR REPLACE VIEW exp07_05_g2 (ename, v) AS
-- (ename, v)
SELECT 'ALLEN', 300 FROM dual
UNION ALL SELECT 'KING', 0 FROM dual
UNION ALL SELECT 'SMITH', 7902 FROM dual;
EXEC lab_check('07-ex05-G2', 'ANS07_05_G2', 'EXP07_05_G2')
SELECT * FROM ans07_05_g2 ORDER BY 1, 2;
