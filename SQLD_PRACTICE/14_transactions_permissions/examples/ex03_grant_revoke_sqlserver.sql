-- ex03 GRANT · REVOKE · DENY · ROLE · WITH GRANT OPTION  | SQL Server (EXECUTE AS USER 로 다른 사용자처럼 실행한 뒤 REVERT)
DROP TABLE IF EXISTS d14_secret;
IF DATABASE_PRINCIPAL_ID('d14_reader') IS NOT NULL DROP ROLE d14_reader;
CREATE TABLE d14_secret (id INT, v VARCHAR(10));
INSERT INTO d14_secret VALUES (1, 'top');
GO
PRINT N'== [Q1] 권한 없음 -> 권한 거부 오류 (Oracle 과 달리 객체의 존재는 드러난다)';
EXECUTE AS USER = 'sqld_lab_u2';
GO
-- @expect-error: MSG-229
SELECT * FROM d14_secret;
GO
REVERT;
GO
PRINT N'== [Q2] GRANT SELECT 후 조회 가능, INSERT 는 거부';
GRANT SELECT ON d14_secret TO sqld_lab_u2;
EXECUTE AS USER = 'sqld_lab_u2';
SELECT * FROM d14_secret;
GO
INSERT INTO d14_secret VALUES (2, 'x');
GO
REVERT;
GO
PRINT N'== [Q3] WITH GRANT OPTION -> U2 가 U3 에게 부여';
GRANT SELECT ON d14_secret TO sqld_lab_u2 WITH GRANT OPTION;
EXECUTE AS USER = 'sqld_lab_u2';
GRANT SELECT ON d14_secret TO sqld_lab_u3;
REVERT;
EXECUTE AS USER = 'sqld_lab_u3';
SELECT COUNT(*) AS u3_can_read FROM d14_secret;
REVERT;
GO
PRINT N'== [Q4] 재부여한 권한이 있으면 CASCADE 없이 REVOKE 불가 -> 오류';
GO
-- @expect-error: MSG-4611
REVOKE SELECT ON d14_secret FROM sqld_lab_u2;
GO
PRINT N'== [Q4b] REVOKE ... CASCADE: U3 의 권한까지 회수';
REVOKE SELECT ON d14_secret FROM sqld_lab_u2 CASCADE;
EXECUTE AS USER = 'sqld_lab_u3';
GO
SELECT COUNT(*) FROM d14_secret;
GO
REVERT;
GO
PRINT N'== [Q5] ROLE: CREATE ROLE + ALTER ROLE ADD MEMBER';
CREATE ROLE d14_reader;
GRANT SELECT ON d14_secret TO d14_reader;
ALTER ROLE d14_reader ADD MEMBER sqld_lab_u2;
EXECUTE AS USER = 'sqld_lab_u2';
SELECT COUNT(*) AS via_role FROM d14_secret;
REVERT;
GO
PRINT N'== [Q6] DENY (SQL Server 전용): 역할로 받은 권한보다 DENY 가 우선';
DENY SELECT ON d14_secret TO sqld_lab_u2;
EXECUTE AS USER = 'sqld_lab_u2';
GO
SELECT COUNT(*) FROM d14_secret;
GO
REVERT;
GO
PRINT N'== [Q7] 정리';
REVOKE SELECT ON d14_secret FROM sqld_lab_u2;
ALTER ROLE d14_reader DROP MEMBER sqld_lab_u2;
DROP ROLE d14_reader;
DROP TABLE d14_secret;
SELECT USER_NAME() AS current_user_name;
GO
