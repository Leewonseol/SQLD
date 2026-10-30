-- ex04 변환 함수와 암시적 형변환 (요구목록 §7)  | Oracle
PROMPT == [Q1] TO_CHAR(날짜, 형식) / TO_CHAR(숫자, 형식)
SELECT TO_CHAR(TO_DATE('2024-03-05 14:07:09', 'YYYY-MM-DD HH24:MI:SS'), 'YYYY/MM/DD HH24:MI:SS') d1,
       TO_CHAR(TO_DATE('2024-03-05', 'YYYY-MM-DD'), 'YYYYMMDD') d2,
       TO_CHAR(1234567.891, 'FM999,999,999.00') n1, TO_CHAR(7, 'FM000') n2 FROM dual;

PROMPT == [Q2] TO_NUMBER / TO_DATE
SELECT TO_NUMBER('1,234.5', '9,999.9') + 1 n, TO_DATE('20240315', 'YYYYMMDD') d FROM dual;

PROMPT == [Q3] CAST
SELECT CAST('123' AS NUMBER) + 1 c1, CAST(DATE '2024-03-15' AS TIMESTAMP) c2, CAST(12.7 AS NUMBER(3)) c3 FROM dual;

PROMPT == [Q4] 암시적 변환: Oracle 의 + 는 산술 전용 -> 문자 '10' + '1' = 11
SELECT '10' + 1 a, '10' + '1' b, 10 || 1 c FROM dual;

PROMPT == [Q5] 변환 실패 -> 오류
-- @expect-error: ORA-01722
SELECT TO_NUMBER('12A') FROM dual;

PROMPT == [Q6] 형식과 맞지 않는 날짜 문자열 -> 오류
-- @expect-error: ORA-01843
SELECT TO_DATE('2024-13-01', 'YYYY-MM-DD') FROM dual;
