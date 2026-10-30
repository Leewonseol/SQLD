-- =====================================================================
-- H. 정답 및 검증 | 07_single_row_functions ex04_conversion_functions | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_conversion_functions.md
-- =====================================================================

PROMPT == [G1] 입사일 'YYYY년 MM월'
-- Oracle 형식 모델 안의 일반 문자는 큰따옴표로 감싼다. SQL Server 는 FORMAT(hiredate, N'yyyy년 MM월') 로도 가능하지만 FORMAT 은 .NET 기반이라 느리다.
CREATE OR REPLACE VIEW ans07_04_g1 (ename, hire_ym) AS
SELECT ename, TO_CHAR(hiredate, 'YYYY"년" MM"월"') FROM emp WHERE deptno = 10;
CREATE OR REPLACE VIEW exp07_04_g1 (ename, hire_ym) AS
-- (ename, hire_ym)
SELECT 'CLARK', '1981년 06월' FROM dual
UNION ALL SELECT 'KING', '1981년 11월' FROM dual
UNION ALL SELECT 'MILLER', '1982년 01월' FROM dual;
EXEC lab_check('07-ex04-G1', 'ANS07_04_G1', 'EXP07_04_G1')
SELECT * FROM ans07_04_g1 ORDER BY 1, 2;

PROMPT == [G2] '3,000' 이상 급여
-- sal >= '3,000' 처럼 그대로 비교하면 Oracle ORA-01722, SQL Server Msg 8114(숫자 변환 실패).
CREATE OR REPLACE VIEW ans07_04_g2 (ename) AS
SELECT ename FROM emp WHERE sal >= TO_NUMBER('3,000', '9,999');
CREATE OR REPLACE VIEW exp07_04_g2 (ename) AS
-- (ename)
SELECT 'FORD' FROM dual
UNION ALL SELECT 'KING' FROM dual
UNION ALL SELECT 'SCOTT' FROM dual;
EXEC lab_check('07-ex04-G2', 'ANS07_04_G2', 'EXP07_04_G2')
SELECT * FROM ans07_04_g2 ORDER BY 1;
