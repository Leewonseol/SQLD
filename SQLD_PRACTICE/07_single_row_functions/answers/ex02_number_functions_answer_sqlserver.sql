-- =====================================================================
-- H. 정답 및 검증 | 07_single_row_functions ex02_number_functions | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_number_functions.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 10번 부서 보너스 100 단위 버림';
-- ROUND 를 쓰면 CLARK 245 → 200, MILLER 130 → 100 으로 우연히 같지만 KING 500 도 같다. 250 이상이면 달라진다(예: 2550 → 반올림 300, 버림 200).
GO
CREATE OR ALTER VIEW ans07_02_g1 (ename, bonus) AS
SELECT ename, ROUND(sal * 0.1, -2, 1) FROM emp WHERE deptno = 10;
GO
CREATE OR ALTER VIEW exp07_02_g1 (ename, bonus) AS
SELECT * FROM (VALUES (N'CLARK', 200),
       (N'KING', 500),
       (N'MILLER', 100)) v(ename, bonus);
GO
EXEC lab_check N'07-ex02-G1', N'ans07_02_g1', N'exp07_02_g1';
SELECT * FROM ans07_02_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 사번 / 7 의 몫과 나머지';
-- SQL Server 는 정수 / 정수가 정수 몫이다. Oracle 에서 empno / 7 만 쓰면 1111.714… 가 되어 CHECK_FAIL.
GO
CREATE OR ALTER VIEW ans07_02_g2 (empno, q, r) AS
SELECT empno, empno / 7, empno % 7 FROM emp WHERE deptno = 10;
GO
CREATE OR ALTER VIEW exp07_02_g2 (empno, q, r) AS
SELECT * FROM (VALUES (7782, 1111, 5),
       (7839, 1119, 6),
       (7934, 1133, 3)) v(empno, q, r);
GO
EXEC lab_check N'07-ex02-G2', N'ans07_02_g2', N'exp07_02_g2';
SELECT * FROM ans07_02_g2 ORDER BY 1, 2, 3;
GO
