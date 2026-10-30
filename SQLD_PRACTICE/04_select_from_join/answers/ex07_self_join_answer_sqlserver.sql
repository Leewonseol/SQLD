-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex07_self_join | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex07_self_join.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 관리자보다 급여가 많은 사원';
GO
CREATE OR ALTER VIEW ans04_07_g1 (ename, sal, mgr_name, mgr_sal) AS
SELECT e.ename, e.sal, m.ename, m.sal FROM emp e JOIN emp m ON e.mgr = m.empno WHERE e.sal > m.sal;
GO
CREATE OR ALTER VIEW exp04_07_g1 (ename, sal, mgr_name, mgr_sal) AS
SELECT * FROM (VALUES (N'FORD', 3000, N'JONES', 2975),
       (N'SCOTT', 3000, N'JONES', 2975)) v(ename, sal, mgr_name, mgr_sal);
GO
EXEC lab_check N'04-ex07-G1', N'ans04_07_g1', N'exp04_07_g1';
SELECT * FROM ans04_07_g1 ORDER BY 1, 2, 3, 4;
GO

PRINT N'== [G2] 부하가 없는 직원';
-- 조인 방향: a 를 '상사 후보'로 두고 a 의 부하 b 를 붙인다. 짝이 없는 a 가 리프다.
-- NOT IN (SELECT boss_id FROM staff) 로 쓰면 boss_id 에 NULL(나사장)이 있어 결과가 0행이 된다 → 08단원 ex05.
GO
CREATE OR ALTER VIEW ans04_07_g2 (name) AS
SELECT a.name FROM staff a LEFT JOIN staff b ON b.boss_id = a.staff_id WHERE b.staff_id IS NULL;
GO
CREATE OR ALTER VIEW exp04_07_g2 (name) AS
SELECT * FROM (VALUES (N'박현석'),
       (N'황수지')) v(name);
GO
EXEC lab_check N'04-ex07-G2', N'ans04_07_g2', N'exp04_07_g2';
SELECT * FROM ans04_07_g2 ORDER BY 1;
GO
