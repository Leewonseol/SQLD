-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex03_like | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_like.md
-- =====================================================================

PROMPT == [G1] A 포함 5글자 이름
-- ename LIKE '_____' 은 정확히 5글자. LENGTH(ename) = 5 (SQL Server LEN) 로도 가능하지만 문제 조건은 LIKE 만.
CREATE OR REPLACE VIEW ans05_03_g1 (ename) AS
SELECT ename FROM emp WHERE ename LIKE '%A%' AND ename LIKE '_____';
CREATE OR REPLACE VIEW exp05_03_g1 (ename) AS
-- (ename)
SELECT 'ADAMS' FROM dual
UNION ALL SELECT 'ALLEN' FROM dual
UNION ALL SELECT 'BLAKE' FROM dual
UNION ALL SELECT 'CLARK' FROM dual
UNION ALL SELECT 'JAMES' FROM dual;
EXEC lab_check('05-ex03-G1', 'ANS05_03_G1', 'EXP05_03_G1')
SELECT * FROM ans05_03_g1 ORDER BY 1;

PROMPT == [G2] 대소문자 무시 a 시작, _ 미포함
-- SQL Server 는 기본 CI 정렬이라 UPPER 없이도 같지만, 데이터 정렬이 CS 인 DB 에서도 같은 결과가 나오도록 UPPER 를 쓴다.
CREATE OR REPLACE VIEW ans05_03_g2 (id, txt) AS
SELECT id, txt FROM w_like WHERE UPPER(txt) LIKE 'A%' AND txt NOT LIKE '%\_%' ESCAPE '\';
CREATE OR REPLACE VIEW exp05_03_g2 (id, txt) AS
-- (id, txt)
SELECT 2, 'AXB' FROM dual
UNION ALL SELECT 3, 'AB' FROM dual
UNION ALL SELECT 6, 'ab' FROM dual;
EXEC lab_check('05-ex03-G2', 'ANS05_03_G2', 'EXP05_03_G2')
SELECT * FROM ans05_03_g2 ORDER BY 1, 2;
