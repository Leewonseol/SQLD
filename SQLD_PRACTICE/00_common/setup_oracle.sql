-- =====================================================================
-- 00_common/setup_oracle.sql
-- 공통 도우미(LAB_DROP)와 공통 데이터셋(EMP·DEPT·SALGRADE)을 만든다.
-- 데이터 출처: Oracle 전통 샘플 SCOTT 스키마 값.
--   PDF 텍스트 추출본의 ROLLUP/CUBE/GROUPING SETS 결과표(14명, 총급여 29025,
--   CLERK 4명 4150 등)와 일치하는지는 10_grouping_extensions 에서 실행으로 확인한다.
-- 재실행 가능: SQLD_LAB 스키마의 같은 이름 객체만 지우고 다시 만든다.
-- =====================================================================
CREATE OR REPLACE PROCEDURE lab_drop(p_name IN VARCHAR2, p_type IN VARCHAR2 DEFAULT 'TABLE')
AUTHID CURRENT_USER IS
BEGIN
  IF USER <> 'SQLD_LAB' THEN
    RAISE_APPLICATION_ERROR(-20001, 'lab_drop 은 SQLD_LAB 스키마에서만 실행한다. 현재: ' || USER);
  END IF;
  IF UPPER(p_type) = 'TABLE' THEN
    EXECUTE IMMEDIATE 'DROP TABLE ' || p_name || ' CASCADE CONSTRAINTS PURGE';
  ELSE
    EXECUTE IMMEDIATE 'DROP ' || p_type || ' ' || p_name;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- 객체가 없을 때 나는 오류만 무시한다(-942 테이블/뷰, -4043 객체, -2289 시퀀스, -1919·-1924 롤, -1434 동의어, -4080 트리거)
    IF SQLCODE NOT IN (-942, -4043, -2289, -1919, -1924, -1434, -4080) THEN RAISE; END IF;
END;
/

-- 자동 검증 도우미: 학습자 답 뷰(p_actual)와 기대 결과 뷰(p_expected)를 집합 양방향 + 행 수로 비교한다.
-- 한계: 중복 행의 개수 차이는 행 수 비교로만 잡는다. 정렬 순서는 비교하지 않는다(순서가 중요한 문제는 순번 컬럼을 답에 포함).
CREATE OR REPLACE PROCEDURE lab_check(p_label IN VARCHAR2, p_actual IN VARCHAR2, p_expected IN VARCHAR2)
AUTHID CURRENT_USER IS
  v_a_minus_e NUMBER; v_e_minus_a NUMBER; v_ca NUMBER; v_ce NUMBER;
BEGIN
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM (SELECT * FROM ' || p_actual || ' MINUS SELECT * FROM ' || p_expected || ')' INTO v_a_minus_e;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM (SELECT * FROM ' || p_expected || ' MINUS SELECT * FROM ' || p_actual || ')' INTO v_e_minus_a;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || p_actual INTO v_ca;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || p_expected INTO v_ce;
  IF v_a_minus_e = 0 AND v_e_minus_a = 0 AND v_ca = v_ce THEN
    DBMS_OUTPUT.PUT_LINE(p_label || ': CHECK_PASS (' || v_ca || '행)');
  ELSE
    DBMS_OUTPUT.PUT_LINE(p_label || ': CHECK_FAIL (답에만 있는 행 ' || v_a_minus_e || ', 기대에만 있는 행 ' || v_e_minus_a
                         || ', 행 수 ' || v_ca || '/' || v_ce || ')');
  END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(p_label || ': CHECK_FAIL (' || SQLERRM || ')');
END;
/

EXEC lab_drop('EMP')
EXEC lab_drop('DEPT')
EXEC lab_drop('SALGRADE')

CREATE TABLE dept (
  deptno NUMBER(2)    CONSTRAINT pk_dept PRIMARY KEY,
  dname  VARCHAR2(14) NOT NULL,
  loc    VARCHAR2(13)
);

CREATE TABLE emp (
  empno    NUMBER(4)    CONSTRAINT pk_emp PRIMARY KEY,
  ename    VARCHAR2(10) NOT NULL,
  job      VARCHAR2(9),
  mgr      NUMBER(4),
  hiredate DATE,
  sal      NUMBER(7,2),
  comm     NUMBER(7,2),
  deptno   NUMBER(2)    CONSTRAINT fk_emp_dept REFERENCES dept(deptno)
);

CREATE TABLE salgrade (
  grade NUMBER CONSTRAINT pk_salgrade PRIMARY KEY,
  losal NUMBER,
  hisal NUMBER
);

INSERT INTO dept VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO dept VALUES (20, 'RESEARCH',   'DALLAS');
INSERT INTO dept VALUES (30, 'SALES',      'CHICAGO');
INSERT INTO dept VALUES (40, 'OPERATIONS', 'BOSTON');

INSERT INTO emp VALUES (7369, 'SMITH',  'CLERK',     7902, DATE '1980-12-17',  800, NULL, 20);
INSERT INTO emp VALUES (7499, 'ALLEN',  'SALESMAN',  7698, DATE '1981-02-20', 1600,  300, 30);
INSERT INTO emp VALUES (7521, 'WARD',   'SALESMAN',  7698, DATE '1981-02-22', 1250,  500, 30);
INSERT INTO emp VALUES (7566, 'JONES',  'MANAGER',   7839, DATE '1981-04-02', 2975, NULL, 20);
INSERT INTO emp VALUES (7654, 'MARTIN', 'SALESMAN',  7698, DATE '1981-09-28', 1250, 1400, 30);
INSERT INTO emp VALUES (7698, 'BLAKE',  'MANAGER',   7839, DATE '1981-05-01', 2850, NULL, 30);
INSERT INTO emp VALUES (7782, 'CLARK',  'MANAGER',   7839, DATE '1981-06-09', 2450, NULL, 10);
INSERT INTO emp VALUES (7788, 'SCOTT',  'ANALYST',   7566, DATE '1987-04-19', 3000, NULL, 20);
INSERT INTO emp VALUES (7839, 'KING',   'PRESIDENT', NULL, DATE '1981-11-17', 5000, NULL, 10);
INSERT INTO emp VALUES (7844, 'TURNER', 'SALESMAN',  7698, DATE '1981-09-08', 1500,    0, 30);
INSERT INTO emp VALUES (7876, 'ADAMS',  'CLERK',     7788, DATE '1987-05-23', 1100, NULL, 20);
INSERT INTO emp VALUES (7900, 'JAMES',  'CLERK',     7698, DATE '1981-12-03',  950, NULL, 30);
INSERT INTO emp VALUES (7902, 'FORD',   'ANALYST',   7566, DATE '1981-12-03', 3000, NULL, 20);
INSERT INTO emp VALUES (7934, 'MILLER', 'CLERK',     7782, DATE '1982-01-23', 1300, NULL, 10);

-- 자기참조 FK는 데이터 적재 후 추가(적재 순서 문제 회피)
ALTER TABLE emp ADD CONSTRAINT fk_emp_mgr FOREIGN KEY (mgr) REFERENCES emp(empno);

INSERT INTO salgrade VALUES (1,  700, 1200);
INSERT INTO salgrade VALUES (2, 1201, 1400);
INSERT INTO salgrade VALUES (3, 1401, 2000);
INSERT INTO salgrade VALUES (4, 2001, 3000);
INSERT INTO salgrade VALUES (5, 3001, 9999);
COMMIT;

PROMPT == 적재 확인
SELECT (SELECT COUNT(*) FROM emp) emp_cnt, (SELECT SUM(sal) FROM emp) sum_sal,
       (SELECT COUNT(*) FROM dept) dept_cnt, (SELECT COUNT(*) FROM salgrade) grade_cnt
FROM dual;
SELECT CASE WHEN (SELECT COUNT(*) FROM emp) = 14 AND (SELECT SUM(sal) FROM emp) = 29025
            THEN 'CHECK_PASS' ELSE 'CHECK_FAIL' END AS common_data_check
FROM dual;
