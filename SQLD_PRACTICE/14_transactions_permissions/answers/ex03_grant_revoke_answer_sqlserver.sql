-- H. 정답 및 검증 | 14 ex03 | SQL Server
DROP TABLE IF EXISTS d14_g_tab;
CREATE TABLE d14_g_tab (id INT);
-- [학습자 작성 구간 시작]
GRANT SELECT, UPDATE ON d14_g_tab TO sqld_lab_u2;
REVOKE UPDATE ON d14_g_tab FROM sqld_lab_u2;
-- [학습자 작성 구간 끝]
GO
CREATE OR ALTER VIEW ans14_03_g1 AS
-- 시스템 카탈로그 문자열은 데이터 정렬이 DB 기본값과 달라 COLLATE 로 맞춘다(없으면 EXCEPT 에서 데이터 정렬 충돌)
SELECT UPPER(USER_NAME(p.grantee_principal_id)) COLLATE DATABASE_DEFAULT AS grantee, p.permission_name COLLATE DATABASE_DEFAULT AS privilege
FROM sys.database_permissions p WHERE p.major_id = OBJECT_ID('d14_g_tab') AND p.state = 'G';
GO
CREATE OR ALTER VIEW exp14_03_g1 (grantee, privilege) AS SELECT 'SQLD_LAB_U2', 'SELECT';
GO
EXEC lab_check N'14-ex03-G1', N'ans14_03_g1', N'exp14_03_g1';
SELECT * FROM ans14_03_g1;
DROP VIEW ans14_03_g1;
DROP TABLE IF EXISTS d14_g_tab;
GO
