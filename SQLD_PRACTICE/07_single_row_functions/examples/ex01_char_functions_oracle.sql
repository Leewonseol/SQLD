-- ex01 문자 함수 (요구목록 §7. 추출본에 문자 함수 본문 없음)  | Oracle
PROMPT == [Q1] 대소문자: LOWER / UPPER / INITCAP
SELECT LOWER('SQL Developer') lo, UPPER('SQL Developer') up, INITCAP('sql developer') ini FROM dual;

PROMPT == [Q2] 길이: LENGTH 는 뒤 공백도 센다. LENGTHB 는 바이트(AL32UTF8 한글 3바이트)
SELECT LENGTH('AB  ') len_trailing, LENGTH('홍길동') len_ko, LENGTHB('홍길동') lenb_ko, LENGTH('') len_empty FROM dual;

PROMPT == [Q3] SUBSTR(문자열, 시작, 길이). 시작이 음수면 뒤에서부터
SELECT SUBSTR('SQL Developer', 5, 3) s1, SUBSTR('SQL Developer', -3) s2, SUBSTR('SQL Developer', 5) s3 FROM dual;

PROMPT == [Q4] INSTR(문자열, 찾을값, 시작, n번째)
SELECT INSTR('CORPORATE FLOOR', 'OR') i1, INSTR('CORPORATE FLOOR', 'OR', 3, 2) i2, INSTR('CORPORATE FLOOR', 'XX') i3 FROM dual;

PROMPT == [Q5] TRIM 계열: 지정 문자 제거
SELECT LTRIM('xxABxx', 'x') l, RTRIM('xxABxx', 'x') r, TRIM('x' FROM 'xxABxx') b,
       TRIM(LEADING 'x' FROM 'xxABxx') lead, '[' || TRIM('  AB  ') || ']' sp FROM dual;

PROMPT == [Q6] LPAD / RPAD
SELECT LPAD('7', 3, '0') lp, RPAD('AB', 5, '*') rp, LPAD('ABCDE', 3) cut FROM dual;

PROMPT == [Q7] REPLACE / TRANSLATE (글자 단위 대응 치환)
SELECT REPLACE('2024-03-15', '-', '') rep, REPLACE('ABAB', 'B') rep_del, TRANSLATE('2024-03-15', '-0', '/o') tr FROM dual;

PROMPT == [Q8] 결합과 문자 코드: CONCAT(인수 2개), ||, ASCII, CHR
SELECT CONCAT(CONCAT('A', 'B'), 'C') c3, 'A' || 'B' || 'C' pipes, ASCII('A') asc_a, CHR(66) chr_66 FROM dual;
