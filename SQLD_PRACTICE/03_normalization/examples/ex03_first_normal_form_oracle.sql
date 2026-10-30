-- ex03 제1정규형(1NF): 모든 속성 값은 원자값 (요구목록 §6)  | Oracle
EXEC lab_drop('N03_HOBBY_RAW')
EXEC lab_drop('N03_HOBBY')
PROMPT == [Q1] 1NF 위반: 한 칸에 여러 값('SQL,독서')
CREATE TABLE n03_hobby_raw (stu_no VARCHAR2(5) PRIMARY KEY, hobbies VARCHAR2(50 CHAR));
INSERT INTO n03_hobby_raw VALUES ('S1', 'SQL,독서');
INSERT INTO n03_hobby_raw VALUES ('S2', 'NoSQL');
INSERT INTO n03_hobby_raw VALUES ('S3', '독서,등산,SQL');

PROMPT == [Q2] 다중값 컬럼 검색의 함정: 'SQL' 을 LIKE 로 찾으면 'NoSQL' 도 걸린다
SELECT stu_no FROM n03_hobby_raw WHERE hobbies LIKE '%SQL%' ORDER BY stu_no;

PROMPT == [Q3] 1NF 로 분해: (학번, 취미) 한 행에 하나씩. 정규식으로 쉼표 목록을 행으로 펼친다
CREATE TABLE n03_hobby (stu_no VARCHAR2(5), hobby VARCHAR2(20 CHAR), CONSTRAINT pk_n03_hobby PRIMARY KEY (stu_no, hobby));
INSERT INTO n03_hobby
SELECT stu_no, REGEXP_SUBSTR(hobbies, '[^,]+', 1, n) FROM n03_hobby_raw,
       (SELECT LEVEL n FROM dual CONNECT BY LEVEL <= 5) WHERE REGEXP_SUBSTR(hobbies, '[^,]+', 1, n) IS NOT NULL;
SELECT stu_no, hobby FROM n03_hobby ORDER BY stu_no, hobby;

PROMPT == [Q4] 정확한 검색: = 비교
SELECT stu_no FROM n03_hobby WHERE hobby = 'SQL' ORDER BY stu_no;
ROLLBACK;
EXEC lab_drop('N03_HOBBY_RAW')
EXEC lab_drop('N03_HOBBY')
