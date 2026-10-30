-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex10_outer_join | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex10_outer_join.md
-- =====================================================================

PROMPT == [G1] 부서별 사원 수(0 포함)
-- COUNT(*) 로 쓰면 40번이 1 이 되어 CHECK_FAIL. Oracle (+) 표기: WHERE d.deptno = e.deptno(+).
CREATE OR REPLACE VIEW ans04_10_g1 (deptno, dname, emp_cnt) AS
SELECT d.deptno, d.dname, COUNT(e.empno) FROM dept d LEFT JOIN emp e ON e.deptno = d.deptno GROUP BY d.deptno, d.dname;
CREATE OR REPLACE VIEW exp04_10_g1 (deptno, dname, emp_cnt) AS
-- (deptno, dname, emp_cnt)
SELECT 10, 'ACCOUNTING', 3 FROM dual
UNION ALL SELECT 20, 'RESEARCH', 5 FROM dual
UNION ALL SELECT 30, 'SALES', 6 FROM dual
UNION ALL SELECT 40, 'OPERATIONS', 0 FROM dual;
EXEC lab_check('04-ex10-G1', 'ANS04_10_G1', 'EXP04_10_G1')
SELECT * FROM ans04_10_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 출판사 매칭이 없는 책
-- WHERE b.publisher_id IS NULL 로 쓰면 0행(b03 의 publisher_id 는 8 로 NULL 이 아니다). 판정은 '반대쪽 PK 가 NULL 인가'로 한다.
CREATE OR REPLACE VIEW ans04_10_g2 (book_id, book_name) AS
SELECT b.book_id, b.book_name FROM book_list b LEFT JOIN publisher p ON b.publisher_id = p.publisher_id WHERE p.publisher_id IS NULL;
CREATE OR REPLACE VIEW exp04_10_g2 (book_id, book_name) AS
-- (book_id, book_name)
SELECT 'b03', '1984' FROM dual;
EXEC lab_check('04-ex10-G2', 'ANS04_10_G2', 'EXP04_10_G2')
SELECT * FROM ans04_10_g2 ORDER BY 1, 2;
