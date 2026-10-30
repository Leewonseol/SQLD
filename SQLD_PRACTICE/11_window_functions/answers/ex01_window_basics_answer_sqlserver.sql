-- =====================================================================
-- H. 정답 및 검증 | 11_window_functions ex01_window_basics | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_window_basics.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 책 가격 비율(%)';
GO
CREATE OR ALTER VIEW ans11_01_g1 (book_name, pct) AS
SELECT book_name, ROUND(price * 100 / SUM(price) OVER (), 1) FROM bookshelf;
GO
CREATE OR ALTER VIEW exp11_01_g1 (book_name, pct) AS
SELECT * FROM (VALUES (N'1984', 12.9),
       (N'나미야 잡화점의 기적', 14.2),
       (N'데미안', 11.5),
       (N'멋진 신세계', 12.5),
       (N'어린 왕자', 8.4),
       (N'참을 수 없는 존재의 가벼움', 10.5),
       (N'창문 넘어 도망친 100세 노인', 14.6),
       (N'천개의 찬란한 태양', 15.3)) v(book_name, pct);
GO
EXEC lab_check N'11-ex01-G1', N'ans11_01_g1', N'exp11_01_g1';
SELECT * FROM ans11_01_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 30번 부서 입사일 순 누적 급여';
GO
CREATE OR ALTER VIEW ans11_01_g2 (ename, cum_sal) AS
SELECT ename, SUM(sal) OVER (ORDER BY hiredate) FROM emp WHERE deptno = 30;
GO
CREATE OR ALTER VIEW exp11_01_g2 (ename, cum_sal) AS
SELECT * FROM (VALUES (N'ALLEN', 1600),
       (N'BLAKE', 5700),
       (N'JAMES', 9400),
       (N'MARTIN', 8450),
       (N'TURNER', 7200),
       (N'WARD', 2850)) v(ename, cum_sal);
GO
EXEC lab_check N'11-ex01-G2', N'ans11_01_g2', N'exp11_01_g2';
SELECT * FROM ans11_01_g2 ORDER BY 1, 2;
GO
