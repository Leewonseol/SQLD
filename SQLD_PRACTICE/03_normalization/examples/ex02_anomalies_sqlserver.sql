-- ex02 이상 현상  | SQL Server
PRINT N'== [Q1] 삽입 이상';
GO
-- @expect-error: MSG-515
INSERT INTO n03_enroll (stu_no, course_cd, course_nm) VALUES (NULL, 'C4', N'데이터베이스');
GO
PRINT N'== [Q2] 갱신 이상';
BEGIN TRAN;
UPDATE n03_enroll SET dept_head = N'한교수' WHERE dept = 'DB' AND stu_no = 'S1';
SELECT dept, COUNT(DISTINCT dept_head) AS heads, STRING_AGG(dept_head, ',') WITHIN GROUP (ORDER BY dept_head) AS head_values
FROM (SELECT DISTINCT dept, dept_head FROM n03_enroll) t GROUP BY dept ORDER BY dept;
ROLLBACK;
PRINT N'== [Q3] 삭제 이상';
BEGIN TRAN;
DELETE FROM n03_enroll WHERE stu_no = 'S3' AND course_cd = 'C3';
SELECT COUNT(*) AS c3_rows_left FROM n03_enroll WHERE course_cd = 'C3';
ROLLBACK;
PRINT N'== [Q4] 중복 저장량';
SELECT N'dept_head 저장 횟수' AS what, COUNT(*) AS stored, COUNT(DISTINCT dept) AS distinct_facts FROM n03_enroll
UNION ALL SELECT N'course_nm 저장 횟수', COUNT(*), COUNT(DISTINCT course_cd) FROM n03_enroll;
GO
