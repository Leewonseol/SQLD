-- =====================================================================
-- bootstrap_sqlserver_admin.sql  (sysadmin 계정으로 1회 실행)
-- 목적: 실습 전용 DB(SQLD_LAB), 실습 로그인(sqld_lab), 권한 실습용 로그인(sqld_lab_u2)만 만든다.
--       기존 DB·로그인은 삭제하지 않는다. 이미 있으면 생성 단계를 건너뛴다.
-- 실행: sqlcmd -S localhost -U sa -P <pw> -C -f 65001 -i tools/bootstrap_sqlserver_admin.sql
-- 검증 환경: Microsoft SQL Server 2022 (RTM-CU27-GDR) 16.0.4305.5 Developer, Linux 컨테이너.
-- =====================================================================
IF DB_ID(N'SQLD_LAB') IS NULL CREATE DATABASE SQLD_LAB;
GO
IF SUSER_ID(N'sqld_lab') IS NULL
  CREATE LOGIN sqld_lab WITH PASSWORD = N'Sqld_Lab_2026!', CHECK_POLICY = OFF, DEFAULT_DATABASE = SQLD_LAB;
IF SUSER_ID(N'sqld_lab_u2') IS NULL
  CREATE LOGIN sqld_lab_u2 WITH PASSWORD = N'Sqld_Lab_2026!', CHECK_POLICY = OFF, DEFAULT_DATABASE = SQLD_LAB;
GO
USE SQLD_LAB;
GO
IF USER_ID(N'sqld_lab') IS NULL CREATE USER sqld_lab FOR LOGIN sqld_lab;
IF USER_ID(N'sqld_lab_u2') IS NULL CREATE USER sqld_lab_u2 FOR LOGIN sqld_lab_u2;
-- 실습 계정은 SQLD_LAB DB 안에서만 소유자 권한을 가진다(서버 수준 권한 없음).
ALTER ROLE db_owner ADD MEMBER sqld_lab;
GO
PRINT 'bootstrap done';
GO
