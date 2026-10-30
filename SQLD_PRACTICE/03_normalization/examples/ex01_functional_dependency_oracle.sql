-- ex01 함수 종속과 결정자 (요구목록 §6)  | Oracle
-- X -> Y : X 값이 같으면 Y 값도 반드시 같다. 데이터로는 '위반'만 찾을 수 있다(위반 0 = 현재 데이터에서 성립, 규칙인지는 업무가 정한다).
PROMPT == [Q1] 함수 종속 검사: 각 X 그룹에서 Y 가 2개 이상이면 위반
SELECT 'stu_no -> stu_name' AS fd, COUNT(*) AS violations FROM (SELECT stu_no FROM n03_enroll GROUP BY stu_no HAVING COUNT(DISTINCT stu_name) > 1)
UNION ALL SELECT 'stu_no -> dept', COUNT(*) FROM (SELECT stu_no FROM n03_enroll GROUP BY stu_no HAVING COUNT(DISTINCT dept) > 1)
UNION ALL SELECT 'dept -> dept_head', COUNT(*) FROM (SELECT dept FROM n03_enroll GROUP BY dept HAVING COUNT(DISTINCT dept_head) > 1)
UNION ALL SELECT 'course_cd -> course_nm', COUNT(*) FROM (SELECT course_cd FROM n03_enroll GROUP BY course_cd HAVING COUNT(DISTINCT course_nm) > 1)
UNION ALL SELECT '(stu_no,course_cd) -> grade', COUNT(*) FROM (SELECT stu_no, course_cd FROM n03_enroll GROUP BY stu_no, course_cd HAVING COUNT(DISTINCT grade) > 1)
UNION ALL SELECT 'dept -> stu_name (종속 아님)', COUNT(*) FROM (SELECT dept FROM n03_enroll GROUP BY dept HAVING COUNT(DISTINCT stu_name) > 1)
UNION ALL SELECT 'course_cd -> grade (종속 아님)', COUNT(*) FROM (SELECT course_cd FROM n03_enroll GROUP BY course_cd HAVING COUNT(DISTINCT grade) > 1);

PROMPT == [Q2] 종속의 종류 판별 (기본키 = stu_no + course_cd)
PROMPT   완전 함수 종속 : (stu_no, course_cd) -> grade          (키 전체에 종속)
PROMPT   부분 함수 종속 : stu_no -> stu_name, dept / course_cd -> course_nm   (키의 일부에 종속 -> 2NF 위반)
PROMPT   이행 함수 종속 : stu_no -> dept -> dept_head            (키가 아닌 속성을 거쳐 종속 -> 3NF 위반)
SELECT COUNT(*) AS rows_total, COUNT(DISTINCT stu_no) students, COUNT(DISTINCT course_cd) courses, COUNT(DISTINCT dept) depts FROM n03_enroll;
