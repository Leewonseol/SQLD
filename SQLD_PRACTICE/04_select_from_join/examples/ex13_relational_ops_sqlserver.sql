-- ex13 순수 관계 연산자 SELECT·PROJECT·JOIN·DIVIDE, 일반 집합 연산자 PRODUCT (PDF E-13)  | SQL Server
PRINT N'== [Q1] SELECT(선택, 행 고르기) 연산 = WHERE 절';
SELECT * FROM enroll WHERE course = 'DB' ORDER BY student;

PRINT N'== [Q2] PROJECT(추출, 열 고르기) 연산 = SELECT 절. 관계(집합)는 중복이 없으므로 DISTINCT 까지 붙여야 같은 의미';
SELECT DISTINCT student FROM enroll ORDER BY student;

PRINT N'== [Q3] DIVIDE(나누기): 필수 과목(DB, SQL)을 모두 수강한 학생 = 이중 NOT EXISTS';
SELECT DISTINCT e.student
FROM enroll e
WHERE NOT EXISTS (SELECT 1 FROM req_course r
                  WHERE NOT EXISTS (SELECT 1 FROM enroll e2
                                    WHERE e2.student = e.student AND e2.course = r.course))
ORDER BY e.student;

PRINT N'== [Q4] DIVIDE 의 다른 구현: 필수 과목과 조인한 뒤 개수 비교';
SELECT e.student
FROM enroll e JOIN req_course r ON e.course = r.course
GROUP BY e.student
HAVING COUNT(DISTINCT e.course) = (SELECT COUNT(*) FROM req_course)
ORDER BY e.student;
