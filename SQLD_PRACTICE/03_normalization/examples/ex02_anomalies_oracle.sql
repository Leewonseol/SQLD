-- ex02 이상 현상: 삽입·갱신·삭제 이상 (요구목록 §6)  | Oracle   대상: 정규화 전 N03_ENROLL
PROMPT == [Q1] 삽입 이상: 수강생이 없는 새 과목 C4(데이터베이스) 를 등록할 수 없다 (PK 일부인 stu_no 에 NULL 불가)
-- @expect-error: ORA-01400
INSERT INTO n03_enroll (stu_no, course_cd, course_nm) VALUES (NULL, 'C4', '데이터베이스');

PROMPT == [Q2] 갱신 이상: DB 학과장을 바꾸면서 일부 행만 바꾸면 같은 학과에 학과장이 둘이 된다
UPDATE n03_enroll SET dept_head = '한교수' WHERE dept = 'DB' AND stu_no = 'S1';
SELECT dept, COUNT(DISTINCT dept_head) AS heads, LISTAGG(DISTINCT dept_head, ',') WITHIN GROUP (ORDER BY dept_head) AS head_values
FROM n03_enroll GROUP BY dept ORDER BY dept;
ROLLBACK;

PROMPT == [Q3] 삭제 이상: S3 의 C3 수강 기록을 지우면 '통계' 과목의 존재 자체가 사라진다
DELETE FROM n03_enroll WHERE stu_no = 'S3' AND course_cd = 'C3';
SELECT COUNT(*) AS c3_rows_left FROM n03_enroll WHERE course_cd = 'C3';
ROLLBACK;

PROMPT == [Q4] 중복 저장량: 같은 사실(학과장, 과목명)이 몇 번 반복 저장되는가
SELECT 'dept_head 저장 횟수' AS what, COUNT(*) AS stored, COUNT(DISTINCT dept) AS distinct_facts FROM n03_enroll
UNION ALL SELECT 'course_nm 저장 횟수', COUNT(*), COUNT(DISTINCT course_cd) FROM n03_enroll;
