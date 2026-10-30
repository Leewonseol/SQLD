-- ex07 정규 표현식 함수 (요구목록 "PDF에 추가로 등장하는 모든 항목" 후보. 추출본에서 확인되지 않음)  | Oracle (10g+)
PROMPT == [Q1] REGEXP_LIKE: 숫자로만 된 code
SELECT id, code FROM w_code WHERE REGEXP_LIKE(code, '^[0-9]+$') ORDER BY id;

PROMPT == [Q2] REGEXP_SUBSTR / REGEXP_INSTR / REGEXP_COUNT / REGEXP_REPLACE
SELECT REGEXP_SUBSTR('a1b22c333', '[0-9]+', 1, 2) sub2, REGEXP_INSTR('a1b22c333', '[0-9]+', 1, 3) ins3,
       REGEXP_COUNT('a1b22c333', '[0-9]') cnt, REGEXP_REPLACE('010-1234-5678', '[0-9]{4}$', '****') masked FROM dual;
