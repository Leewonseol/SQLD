-- ex02 자료형 매핑과 DBMS 차이 (요구목록 §8 "자료형 […] 을 확인하라")  | Oracle
EXEC lab_drop('L02_TYPES')
PROMPT == [Q1] VARCHAR2(n) 의 기본 길이 단위는 바이트(NLS_LENGTH_SEMANTICS=BYTE): 한글 4자(12바이트)는 VARCHAR2(10) 에 들어가지 않는다
CREATE TABLE l02_types (b VARCHAR2(10), c VARCHAR2(10 CHAR), fixed CHAR(5), num NUMBER(5,2), dt DATE);
-- @expect-error: ORA-12899
INSERT INTO l02_types (b) VALUES ('가나다라');
INSERT INTO l02_types (c) VALUES ('가나다라');
SELECT c, LENGTH(c) chars, LENGTHB(c) bytes FROM l02_types;

PROMPT == [Q2] CHAR 는 뒤를 공백으로 채운다. CHAR 끼리 비교할 때는 뒤 공백을 무시한다
INSERT INTO l02_types (fixed) VALUES ('AB');
SELECT '[' || fixed || ']' AS padded, LENGTH(fixed) len FROM l02_types WHERE fixed IS NOT NULL;
SELECT COUNT(*) AS eq_char FROM l02_types WHERE fixed = 'AB';

PROMPT == [Q3] NUMBER(5,2): 정수 3자리 + 소수 2자리. 소수는 반올림, 정수부가 넘치면 오류
INSERT INTO l02_types (num) VALUES (123.456);
SELECT num FROM l02_types WHERE num IS NOT NULL;
-- @expect-error: ORA-01438
INSERT INTO l02_types (num) VALUES (1234.5);

PROMPT == [Q4] DATE 는 초 단위 시각을 포함한다
INSERT INTO l02_types (dt) VALUES (TO_DATE('2024-03-15 13:45:10', 'YYYY-MM-DD HH24:MI:SS'));
SELECT TO_CHAR(dt, 'YYYY-MM-DD HH24:MI:SS') dt FROM l02_types WHERE dt IS NOT NULL;

PROMPT == [Q5] 빈 문자열은 NULL 로 저장된다
INSERT INTO l02_types (c) VALUES ('');
SELECT COUNT(*) AS all_rows, COUNT(c) AS non_null_c FROM l02_types;
ROLLBACK;
EXEC lab_drop('L02_TYPES')
