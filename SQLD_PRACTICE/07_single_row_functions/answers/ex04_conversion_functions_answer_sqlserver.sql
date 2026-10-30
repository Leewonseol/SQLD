-- =====================================================================
-- H. 정답 및 검증 | 07_single_row_functions ex04_conversion_functions | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_conversion_functions.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 입사일 ''YYYY년 MM월''';
-- Oracle 형식 모델 안의 일반 문자는 큰따옴표로 감싼다. SQL Server 는 FORMAT(hiredate, N'yyyy년 MM월') 로도 가능하지만 FORMAT 은 .NET 기반이라 느리다.
GO
CREATE OR ALTER VIEW ans07_04_g1 (ename, hire_ym) AS
SELECT ename, CONCAT(YEAR(hiredate), N'년 ', RIGHT('0' + CAST(MONTH(hiredate) AS VARCHAR(2)), 2), N'월') FROM emp WHERE deptno = 10;
GO
CREATE OR ALTER VIEW exp07_04_g1 (ename, hire_ym) AS
SELECT * FROM (VALUES (N'CLARK', N'1981년 06월'),
       (N'KING', N'1981년 11월'),
       (N'MILLER', N'1982년 01월')) v(ename, hire_ym);
GO
EXEC lab_check N'07-ex04-G1', N'ans07_04_g1', N'exp07_04_g1';
SELECT * FROM ans07_04_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] ''3,000'' 이상 급여';
-- sal >= '3,000' 처럼 그대로 비교하면 Oracle ORA-01722, SQL Server Msg 8114(숫자 변환 실패).
GO
CREATE OR ALTER VIEW ans07_04_g2 (ename) AS
SELECT ename FROM emp WHERE sal >= CAST(REPLACE('3,000', ',', '') AS INT);
GO
CREATE OR ALTER VIEW exp07_04_g2 (ename) AS
SELECT * FROM (VALUES (N'FORD'),
       (N'KING'),
       (N'SCOTT')) v(ename);
GO
EXEC lab_check N'07-ex04-G2', N'ans07_04_g2', N'exp07_04_g2';
SELECT * FROM ans07_04_g2 ORDER BY 1;
GO
