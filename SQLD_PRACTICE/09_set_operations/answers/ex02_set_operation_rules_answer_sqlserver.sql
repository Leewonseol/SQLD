-- =====================================================================
-- H. 정답 및 검증 | 09_set_operations ex02_set_operation_rules | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_set_operation_rules.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 사원명·부서명 한 열 + 출처';
GO
CREATE OR ALTER VIEW ans09_02_g1 (name, src) AS
SELECT ename, 'E' FROM emp WHERE deptno = 10 UNION ALL SELECT dname, 'D' FROM dept WHERE deptno = 10;
GO
CREATE OR ALTER VIEW exp09_02_g1 (name, src) AS
SELECT * FROM (VALUES (N'ACCOUNTING', N'D'),
       (N'CLARK', N'E'),
       (N'KING', N'E'),
       (N'MILLER', N'E')) v(name, src);
GO
EXEC lab_check N'09-ex02-G1', N'ans09_02_g1', N'exp09_02_g1';
SELECT * FROM ans09_02_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 숫자와 문자를 문자로 통일한 집합';
-- 변환하지 않으면 Oracle ORA-01790, SQL Server Msg 245('ACCOUNTING' 을 TINYINT 로 바꾸다 실패).
GO
CREATE OR ALTER VIEW ans09_02_g2 (v) AS
SELECT CAST(deptno AS VARCHAR(14)) FROM dept WHERE deptno = 10 UNION SELECT dname FROM dept WHERE deptno = 10;
GO
CREATE OR ALTER VIEW exp09_02_g2 (v) AS
SELECT * FROM (VALUES (N'10'),
       (N'ACCOUNTING')) v(v);
GO
EXEC lab_check N'09-ex02-G2', N'ans09_02_g2', N'exp09_02_g2';
SELECT * FROM ans09_02_g2 ORDER BY 1;
GO
