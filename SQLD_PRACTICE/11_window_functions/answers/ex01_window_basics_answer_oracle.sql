-- =====================================================================
-- H. 정답 및 검증 | 11_window_functions ex01_window_basics | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_window_basics.md
-- =====================================================================

PROMPT == [G1] 책 가격 비율(%)
CREATE OR REPLACE VIEW ans11_01_g1 (book_name, pct) AS
SELECT book_name, ROUND(price * 100 / SUM(price) OVER (), 1) FROM bookshelf;
CREATE OR REPLACE VIEW exp11_01_g1 (book_name, pct) AS
-- (book_name, pct)
SELECT '1984', 12.9 FROM dual
UNION ALL SELECT '나미야 잡화점의 기적', 14.2 FROM dual
UNION ALL SELECT '데미안', 11.5 FROM dual
UNION ALL SELECT '멋진 신세계', 12.5 FROM dual
UNION ALL SELECT '어린 왕자', 8.4 FROM dual
UNION ALL SELECT '참을 수 없는 존재의 가벼움', 10.5 FROM dual
UNION ALL SELECT '창문 넘어 도망친 100세 노인', 14.6 FROM dual
UNION ALL SELECT '천개의 찬란한 태양', 15.3 FROM dual;
EXEC lab_check('11-ex01-G1', 'ANS11_01_G1', 'EXP11_01_G1')
SELECT * FROM ans11_01_g1 ORDER BY 1, 2;

PROMPT == [G2] 30번 부서 입사일 순 누적 급여
CREATE OR REPLACE VIEW ans11_01_g2 (ename, cum_sal) AS
SELECT ename, SUM(sal) OVER (ORDER BY hiredate) FROM emp WHERE deptno = 30;
CREATE OR REPLACE VIEW exp11_01_g2 (ename, cum_sal) AS
-- (ename, cum_sal)
SELECT 'ALLEN', 1600 FROM dual
UNION ALL SELECT 'BLAKE', 5700 FROM dual
UNION ALL SELECT 'JAMES', 9400 FROM dual
UNION ALL SELECT 'MARTIN', 8450 FROM dual
UNION ALL SELECT 'TURNER', 7200 FROM dual
UNION ALL SELECT 'WARD', 2850 FROM dual;
EXEC lab_check('11-ex01-G2', 'ANS11_01_G2', 'EXP11_01_G2')
SELECT * FROM ans11_01_g2 ORDER BY 1, 2;
