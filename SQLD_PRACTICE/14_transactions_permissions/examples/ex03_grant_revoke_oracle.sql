-- ex03 GRANT · REVOKE · ROLE · WITH GRANT OPTION (PDF E-04 DCL "데이터베이스에 접근하고 객체들을 사용하도록 권한을 주고 회수")  | Oracle
-- 실습 계정 SQLD_LAB(소유자), SQLD_LAB_U2, SQLD_LAB_U3 (tools/bootstrap_oracle_admin.sql). sqlplus CONNECT 로 사용자를 바꿔 가며 실행한다.
EXEC lab_drop('D14_SECRET')
EXEC lab_drop('D14_READER', 'ROLE')
CREATE TABLE d14_secret (id NUMBER, v VARCHAR2(10));
INSERT INTO d14_secret VALUES (1, 'top');
COMMIT;

PROMPT == [Q1] 권한이 없으면 다른 사용자는 테이블의 존재조차 알 수 없다 -> "없는 테이블" 오류
CONNECT sqld_lab_u2/SqldLab2026@localhost/XEPDB1
-- @expect-error: ORA-00942, ORA-01031
SELECT * FROM sqld_lab.d14_secret;

PROMPT == [Q2] GRANT SELECT 후 조회 가능, INSERT 는 권한 부족
CONNECT sqld_lab/SqldLab2026@localhost/XEPDB1
GRANT SELECT ON d14_secret TO sqld_lab_u2;
CONNECT sqld_lab_u2/SqldLab2026@localhost/XEPDB1
SELECT * FROM sqld_lab.d14_secret;
INSERT INTO sqld_lab.d14_secret VALUES (2, 'x');

PROMPT == [Q3] WITH GRANT OPTION: U2 가 받은 권한을 U3 에게 다시 줄 수 있다
CONNECT sqld_lab/SqldLab2026@localhost/XEPDB1
GRANT SELECT ON d14_secret TO sqld_lab_u2 WITH GRANT OPTION;
CONNECT sqld_lab_u2/SqldLab2026@localhost/XEPDB1
GRANT SELECT ON sqld_lab.d14_secret TO sqld_lab_u3;
CONNECT sqld_lab_u3/SqldLab2026@localhost/XEPDB1
SELECT COUNT(*) AS u3_can_read FROM sqld_lab.d14_secret;

PROMPT == [Q4] U2 의 권한을 REVOKE 하면 U2 가 U3 에게 준 객체 권한도 연쇄 회수된다 (Oracle 객체 권한의 기본 동작)
CONNECT sqld_lab/SqldLab2026@localhost/XEPDB1
REVOKE SELECT ON d14_secret FROM sqld_lab_u2;
CONNECT sqld_lab_u3/SqldLab2026@localhost/XEPDB1
SELECT COUNT(*) FROM sqld_lab.d14_secret;

PROMPT == [Q5] ROLE: 권한을 묶어 역할에 주고, 역할을 사용자에게 부여 (새 세션부터 기본 역할로 활성화)
CONNECT sqld_lab/SqldLab2026@localhost/XEPDB1
CREATE ROLE d14_reader;
GRANT SELECT ON d14_secret TO d14_reader;
GRANT d14_reader TO sqld_lab_u2;
CONNECT sqld_lab_u2/SqldLab2026@localhost/XEPDB1
SELECT COUNT(*) AS via_role FROM sqld_lab.d14_secret;
SELECT granted_role FROM user_role_privs WHERE granted_role = 'D14_READER';

PROMPT == [Q6] 정리: 역할·테이블 삭제 (DCL·DDL 은 자동 커밋)
CONNECT sqld_lab/SqldLab2026@localhost/XEPDB1
REVOKE d14_reader FROM sqld_lab_u2;
DROP ROLE d14_reader;
EXEC lab_drop('D14_SECRET')
SELECT user AS current_user FROM dual;
