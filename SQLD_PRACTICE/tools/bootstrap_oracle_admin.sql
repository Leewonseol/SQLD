-- =====================================================================
-- bootstrap_oracle_admin.sql  (관리자 SYSTEM 계정으로 1회 실행)
-- 목적: 실습 전용 스키마(SQLD_LAB)와 권한 실습용 보조 계정(SQLD_LAB_U2)만 만든다.
--       기존 사용자 객체는 건드리지 않는다. 이미 있으면 생성 단계를 건너뛴다.
-- 실행: sqlplus system/<pw>@//localhost/XEPDB1 @tools/bootstrap_oracle_admin.sql
-- 검증 환경: Oracle Database 21c XE (21.3.0.0.0) 컨테이너. 19c 미실행.
-- =====================================================================
WHENEVER SQLERROR CONTINUE
DECLARE
  PROCEDURE ensure_user(p_user VARCHAR2, p_pw VARCHAR2) IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM dba_users WHERE username = UPPER(p_user);
    IF v_cnt = 0 THEN
      EXECUTE IMMEDIATE 'CREATE USER ' || p_user || ' IDENTIFIED BY "' || p_pw || '" QUOTA UNLIMITED ON USERS';
    END IF;
  END;
BEGIN
  ensure_user('SQLD_LAB',    'SqldLab2026');
  ensure_user('SQLD_LAB_U2', 'SqldLab2026');
END;
/
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE,
      CREATE PROCEDURE, CREATE TRIGGER, CREATE SYNONYM TO SQLD_LAB;
GRANT CREATE ROLE TO SQLD_LAB;
GRANT CREATE SESSION TO SQLD_LAB_U2;
ALTER USER SQLD_LAB    QUOTA UNLIMITED ON USERS;
ALTER USER SQLD_LAB_U2 QUOTA UNLIMITED ON USERS;
PROMPT bootstrap done
