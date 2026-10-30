-- ex06 BCNF 와 손실 분해(가짜 행) (요구목록 §6 "BCNF 등", "무손실 분해와 JOIN 복원")  | Oracle
-- 업무 규칙(학습용 가상): 교수는 한 과목만 담당(교수 -> 과목), 학생은 과목마다 교수 한 명((학생, 과목) -> 교수)
-- 후보키: (학생, 과목), (학생, 교수). 모든 속성이 주식별자의 일부라 3NF 는 만족하지만, 결정자 '교수'가 후보키가 아니므로 BCNF 위반
EXEC lab_drop('N03_LECTURE')
CREATE TABLE n03_lecture (student VARCHAR2(5), course VARCHAR2(5), prof VARCHAR2(5), CONSTRAINT pk_n03_lecture PRIMARY KEY (student, course));
INSERT INTO n03_lecture VALUES ('s1', 'SQL', 'P1');
INSERT INTO n03_lecture VALUES ('s2', 'SQL', 'P2');
INSERT INTO n03_lecture VALUES ('s1', 'DB',  'P3');
COMMIT;
PROMPT == [Q1] 함수 종속 확인: prof -> course 는 성립(위반 0), course -> prof 는 불성립(SQL 에 교수 둘)
SELECT (SELECT COUNT(*) FROM (SELECT prof FROM n03_lecture GROUP BY prof HAVING COUNT(DISTINCT course) > 1)) prof_to_course_viol,
       (SELECT COUNT(*) FROM (SELECT course FROM n03_lecture GROUP BY course HAVING COUNT(DISTINCT prof) > 1)) course_to_prof_viol FROM dual;

PROMPT == [Q2] 잘못된 분해 (학생, 과목) + (과목, 교수) 를 과목으로 다시 조인 -> 원래 3행보다 많은 가짜 행 (손실 분해)
SELECT a.student, a.course, b.prof FROM (SELECT DISTINCT student, course FROM n03_lecture) a
JOIN (SELECT DISTINCT course, prof FROM n03_lecture) b ON a.course = b.course ORDER BY 1, 2, 3;

PROMPT == [Q3] BCNF 분해 (교수, 과목) + (학생, 교수) 를 교수로 조인 -> 원래 3행 그대로 (무손실)
SELECT a.student, b.course, a.prof FROM (SELECT DISTINCT student, prof FROM n03_lecture) a
JOIN (SELECT DISTINCT prof, course FROM n03_lecture) b ON a.prof = b.prof ORDER BY 1, 2, 3;

PROMPT == [Q4] 대가: BCNF 분해 후에는 '(학생, 과목) -> 교수'(학생은 과목당 교수 1명)를 한 테이블의 PK/UNIQUE 로 강제할 수 없다
PROMPT     (과목이 다른 테이블에 있어서) -> 종속성 보존 손실. 트리거 등이 필요하다 (설계 설명, 실행 대상 아님)
EXEC lab_drop('N03_LECTURE')
