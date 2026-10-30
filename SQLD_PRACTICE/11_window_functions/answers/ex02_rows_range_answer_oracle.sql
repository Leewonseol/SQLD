-- =====================================================================
-- H. 정답 및 검증 | 11_window_functions ex02_rows_range | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_rows_range.md
-- =====================================================================

PROMPT == [G1] 20번 부서 3행 이동 합(ROWS)
-- ROWS 2 PRECEDING 은 '앞 2행 + 현재 행'. RANGE 로 쓰면 날짜 값 기준(2일 이내)이 되어 의미가 다르다(SQL Server 는 RANGE 오프셋 불가).
CREATE OR REPLACE VIEW ans11_02_g1 (ename, mov_sum) AS
SELECT ename, SUM(sal) OVER (ORDER BY hiredate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) FROM emp WHERE deptno = 20;
CREATE OR REPLACE VIEW exp11_02_g1 (ename, mov_sum) AS
-- (ename, mov_sum)
SELECT 'ADAMS', 7100 FROM dual
UNION ALL SELECT 'FORD', 6775 FROM dual
UNION ALL SELECT 'JONES', 3775 FROM dual
UNION ALL SELECT 'SCOTT', 8975 FROM dual
UNION ALL SELECT 'SMITH', 800 FROM dual;
EXEC lab_check('11-ex02-G1', 'ANS11_02_G1', 'EXP11_02_G1')
SELECT * FROM ans11_02_g1 ORDER BY 1, 2;

PROMPT == [G2] 30번 부서 급여순 RANGE 누적
-- MARTIN·WARD 동점(1250)은 RANGE 기본 프레임에서 함께 더해져 둘 다 3450.
CREATE OR REPLACE VIEW ans11_02_g2 (ename, cum_sal) AS
SELECT ename, SUM(sal) OVER (ORDER BY sal) FROM emp WHERE deptno = 30;
CREATE OR REPLACE VIEW exp11_02_g2 (ename, cum_sal) AS
-- (ename, cum_sal)
SELECT 'ALLEN', 6550 FROM dual
UNION ALL SELECT 'BLAKE', 9400 FROM dual
UNION ALL SELECT 'JAMES', 950 FROM dual
UNION ALL SELECT 'MARTIN', 3450 FROM dual
UNION ALL SELECT 'TURNER', 4950 FROM dual
UNION ALL SELECT 'WARD', 3450 FROM dual;
EXEC lab_check('11-ex02-G2', 'ANS11_02_G2', 'EXP11_02_G2')
SELECT * FROM ans11_02_g2 ORDER BY 1, 2;
