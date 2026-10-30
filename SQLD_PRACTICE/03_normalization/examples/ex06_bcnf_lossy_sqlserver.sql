-- ex06 BCNF 와 손실 분해  | SQL Server
DROP TABLE IF EXISTS n03_lecture;
CREATE TABLE n03_lecture (student VARCHAR(5), course VARCHAR(5), prof VARCHAR(5), CONSTRAINT pk_n03_lecture PRIMARY KEY (student, course));
INSERT INTO n03_lecture VALUES ('s1', 'SQL', 'P1'), ('s2', 'SQL', 'P2'), ('s1', 'DB', 'P3');
PRINT N'== [Q1] 함수 종속 확인';
SELECT (SELECT COUNT(*) FROM (SELECT prof FROM n03_lecture GROUP BY prof HAVING COUNT(DISTINCT course) > 1) t) prof_to_course_viol,
       (SELECT COUNT(*) FROM (SELECT course FROM n03_lecture GROUP BY course HAVING COUNT(DISTINCT prof) > 1) t) course_to_prof_viol;
PRINT N'== [Q2] 잘못된 분해 -> 가짜 행';
SELECT a.student, a.course, b.prof FROM (SELECT DISTINCT student, course FROM n03_lecture) a
JOIN (SELECT DISTINCT course, prof FROM n03_lecture) b ON a.course = b.course ORDER BY 1, 2, 3;
PRINT N'== [Q3] BCNF 분해 -> 무손실';
SELECT a.student, b.course, a.prof FROM (SELECT DISTINCT student, prof FROM n03_lecture) a
JOIN (SELECT DISTINCT prof, course FROM n03_lecture) b ON a.prof = b.prof ORDER BY 1, 2, 3;
DROP TABLE IF EXISTS n03_lecture;
GO
