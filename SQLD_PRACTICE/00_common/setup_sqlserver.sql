-- =====================================================================
-- 00_common/setup_sqlserver.sql
-- 공통 데이터셋(EMP·DEPT·SALGRADE). 데이터 출처: Oracle 전통 샘플 SCOTT 스키마 값.
-- 재실행 가능: SQLD_LAB DB 안의 같은 이름 테이블만 지우고 다시 만든다.
-- 안전장치: 현재 DB가 SQLD_LAB 이 아니면 THROW 로 배치를 중단해 DROP 이 실행되지 않는다.
-- =====================================================================
USE SQLD_LAB;
GO
-- 자동 검증 도우미: 답 뷰(@actual)와 기대 결과 뷰(@expected)를 EXCEPT 양방향 + 행 수로 비교한다.
CREATE OR ALTER PROCEDURE lab_check @label NVARCHAR(100), @actual SYSNAME, @expected SYSNAME AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @sql NVARCHAR(MAX), @ae INT, @ea INT, @ca INT, @ce INT;
  BEGIN TRY
    SET @sql = N'SELECT @ae = COUNT(*) FROM (SELECT * FROM ' + QUOTENAME(@actual) + N' EXCEPT SELECT * FROM ' + QUOTENAME(@expected) + N') x;'
             + N'SELECT @ea = COUNT(*) FROM (SELECT * FROM ' + QUOTENAME(@expected) + N' EXCEPT SELECT * FROM ' + QUOTENAME(@actual) + N') x;'
             + N'SELECT @ca = COUNT(*) FROM ' + QUOTENAME(@actual) + N'; SELECT @ce = COUNT(*) FROM ' + QUOTENAME(@expected) + N';';
    EXEC sp_executesql @sql, N'@ae INT OUTPUT, @ea INT OUTPUT, @ca INT OUTPUT, @ce INT OUTPUT',
         @ae = @ae OUTPUT, @ea = @ea OUTPUT, @ca = @ca OUTPUT, @ce = @ce OUTPUT;
    IF @ae = 0 AND @ea = 0 AND @ca = @ce
      PRINT @label + N': CHECK_PASS (' + CAST(@ca AS NVARCHAR(10)) + N'행)';
    ELSE
      PRINT @label + N': CHECK_FAIL (답에만 있는 행 ' + CAST(@ae AS NVARCHAR(10)) + N', 기대에만 있는 행 ' + CAST(@ea AS NVARCHAR(10))
            + N', 행 수 ' + CAST(@ca AS NVARCHAR(10)) + N'/' + CAST(@ce AS NVARCHAR(10)) + N')';
  END TRY
  BEGIN CATCH
    PRINT @label + N': CHECK_FAIL (' + ERROR_MESSAGE() + N')';
  END CATCH
END;
GO
IF DB_NAME() <> N'SQLD_LAB' THROW 50000, N'SQLD_LAB DB에서만 실행한다.', 1;
DROP TABLE IF EXISTS emp;
DROP TABLE IF EXISTS dept;
DROP TABLE IF EXISTS salgrade;
GO
CREATE TABLE dept (
  deptno TINYINT     CONSTRAINT pk_dept PRIMARY KEY,
  dname  VARCHAR(14) NOT NULL,
  loc    VARCHAR(13)
);
CREATE TABLE emp (
  empno    SMALLINT     CONSTRAINT pk_emp PRIMARY KEY,
  ename    VARCHAR(10)  NOT NULL,
  job      VARCHAR(9),
  mgr      SMALLINT,
  hiredate DATE,
  sal      DECIMAL(7,2),
  comm     DECIMAL(7,2),
  deptno   TINYINT      CONSTRAINT fk_emp_dept REFERENCES dept(deptno)
);
CREATE TABLE salgrade (
  grade INT CONSTRAINT pk_salgrade PRIMARY KEY,
  losal INT,
  hisal INT
);
INSERT INTO dept VALUES (10, 'ACCOUNTING', 'NEW YORK'), (20, 'RESEARCH', 'DALLAS'),
                        (30, 'SALES', 'CHICAGO'),       (40, 'OPERATIONS', 'BOSTON');
INSERT INTO emp VALUES
 (7369, 'SMITH',  'CLERK',     7902, '1980-12-17',  800, NULL, 20),
 (7499, 'ALLEN',  'SALESMAN',  7698, '1981-02-20', 1600,  300, 30),
 (7521, 'WARD',   'SALESMAN',  7698, '1981-02-22', 1250,  500, 30),
 (7566, 'JONES',  'MANAGER',   7839, '1981-04-02', 2975, NULL, 20),
 (7654, 'MARTIN', 'SALESMAN',  7698, '1981-09-28', 1250, 1400, 30),
 (7698, 'BLAKE',  'MANAGER',   7839, '1981-05-01', 2850, NULL, 30),
 (7782, 'CLARK',  'MANAGER',   7839, '1981-06-09', 2450, NULL, 10),
 (7788, 'SCOTT',  'ANALYST',   7566, '1987-04-19', 3000, NULL, 20),
 (7839, 'KING',   'PRESIDENT', NULL, '1981-11-17', 5000, NULL, 10),
 (7844, 'TURNER', 'SALESMAN',  7698, '1981-09-08', 1500,    0, 30),
 (7876, 'ADAMS',  'CLERK',     7788, '1987-05-23', 1100, NULL, 20),
 (7900, 'JAMES',  'CLERK',     7698, '1981-12-03',  950, NULL, 30),
 (7902, 'FORD',   'ANALYST',   7566, '1981-12-03', 3000, NULL, 20),
 (7934, 'MILLER', 'CLERK',     7782, '1982-01-23', 1300, NULL, 10);
ALTER TABLE emp ADD CONSTRAINT fk_emp_mgr FOREIGN KEY (mgr) REFERENCES emp(empno);
INSERT INTO salgrade VALUES (1, 700, 1200), (2, 1201, 1400), (3, 1401, 2000), (4, 2001, 3000), (5, 3001, 9999);
GO
PRINT N'== 적재 확인';
SELECT (SELECT COUNT(*) FROM emp) emp_cnt, (SELECT SUM(sal) FROM emp) sum_sal,
       (SELECT COUNT(*) FROM dept) dept_cnt, (SELECT COUNT(*) FROM salgrade) grade_cnt;
SELECT CASE WHEN (SELECT COUNT(*) FROM emp) = 14 AND (SELECT SUM(sal) FROM emp) = 29025
            THEN 'CHECK_PASS' ELSE 'CHECK_FAIL' END AS common_data_check;
GO
