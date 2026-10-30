-- ex05 제약조건  | SQL Server (UNIQUE 의 NULL 은 한 개만, ON UPDATE CASCADE 지원)
DROP TABLE IF EXISTS d13_emp, d13_dept;
CREATE TABLE d13_dept (deptno INT CONSTRAINT pk_d13_dept PRIMARY KEY, dname VARCHAR(10) CONSTRAINT uq_d13_dept_dname UNIQUE);
CREATE TABLE d13_emp (
  empno  INT         CONSTRAINT pk_d13_emp PRIMARY KEY,
  ename  VARCHAR(10) CONSTRAINT nn_d13_emp_ename NOT NULL,
  email  VARCHAR(20) CONSTRAINT uq_d13_emp_email UNIQUE,
  sal    INT         CONSTRAINT ck_d13_emp_sal CHECK (sal > 0),
  deptno INT         CONSTRAINT fk_d13_emp_dept REFERENCES d13_dept(deptno) ON DELETE SET NULL ON UPDATE CASCADE,
  mentor INT         CONSTRAINT fk_d13_emp_mentor REFERENCES d13_emp(empno)
);
INSERT INTO d13_dept VALUES (10, 'A'), (20, 'B');
INSERT INTO d13_emp VALUES (1, 'kim', 'k@x', 100, 10, NULL), (2, 'lee', NULL, 200, 20, 1);
GO
PRINT N'== [Q1] UNIQUE 컬럼의 두 번째 NULL -> SQL Server 는 오류 (NULL 도 하나의 값처럼 취급)';
GO
-- @expect-error: MSG-2627
INSERT INTO d13_emp VALUES (3, 'park', NULL, 300, 10, 1);
GO
SELECT COUNT(*) AS null_email_rows FROM d13_emp WHERE email IS NULL;
PRINT N'== [Q1b] 여러 NULL 을 허용하려면 필터링된 UNIQUE 인덱스';
ALTER TABLE d13_emp DROP CONSTRAINT uq_d13_emp_email;
SET QUOTED_IDENTIFIER ON;  -- 필터링된 인덱스는 QUOTED_IDENTIFIER ON 이 필요하다(sqlcmd 를 -I 없이 쓰면 OFF, SSMS 기본값은 ON. 실행기는 -I 로 ON)
CREATE UNIQUE INDEX ux_d13_emp_email ON d13_emp(email) WHERE email IS NOT NULL;
INSERT INTO d13_emp VALUES (3, 'park', NULL, 300, 10, 1);
SELECT COUNT(*) AS null_email_rows FROM d13_emp WHERE email IS NULL;
PRINT N'== [Q2] CHECK 는 NULL 이면 통과';
INSERT INTO d13_emp VALUES (4, 'choi', 'c@x', NULL, 10, NULL);
SELECT empno, sal FROM d13_emp WHERE empno = 4;
GO
PRINT N'== [Q3] 위반 사례 (SQL Server 는 FK 위반도 CHECK 와 같은 Msg 547)';
GO
-- @expect-error: MSG-547, MSG-2601, MSG-2627, MSG-515
INSERT INTO d13_emp VALUES (5, 'x', 'x@x', -1, 10, NULL);
GO
INSERT INTO d13_emp VALUES (6, 'y', 'k@x', 10, 10, NULL);
GO
INSERT INTO d13_emp VALUES (1, 'z', 'z@x', 10, 10, NULL);
GO
INSERT INTO d13_emp VALUES (7, NULL, 'n@x', 10, 10, NULL);
GO
INSERT INTO d13_emp VALUES (8, 'w', 'w@x', 10, 99, NULL);
GO
INSERT INTO d13_emp VALUES (9, 'v', 'v@x', 10, 10, 77);
GO
PRINT N'== [Q4] ON DELETE SET NULL';
BEGIN TRAN;
DELETE FROM d13_dept WHERE deptno = 10;
SELECT empno, deptno FROM d13_emp ORDER BY empno;
ROLLBACK;
PRINT N'== [Q4b] ON UPDATE CASCADE: 부모 키 20 -> 21 이면 자식도 21';
BEGIN TRAN;
UPDATE d13_dept SET deptno = 21 WHERE deptno = 20;
SELECT empno, deptno FROM d13_emp WHERE empno = 2;
ROLLBACK;
GO
PRINT N'== [Q5] 참조 중인 자기참조 행 삭제 -> 오류';
GO
-- @expect-error: MSG-547
DELETE FROM d13_emp WHERE empno = 1;
GO
PRINT N'== [Q7] 제약조건 목록';
SELECT name, type_desc FROM sys.objects WHERE parent_object_id = OBJECT_ID('d13_emp') AND type IN ('PK', 'UQ', 'F', 'C') ORDER BY name;
DROP TABLE IF EXISTS d13_emp, d13_dept;
GO
