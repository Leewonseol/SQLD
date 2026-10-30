-- ex02 숫자 함수 (요구목록 §7)  | Oracle
PROMPT == [Q1] ROUND / TRUNC: 두 번째 인수가 음수면 정수 자리
SELECT ROUND(15.193, 1) r1, ROUND(15.193, -1) r2, ROUND(15.5) r3, ROUND(-15.5) r4,
       TRUNC(15.79, 1) t1, TRUNC(15.79) t2, TRUNC(-15.79) t3 FROM dual;

PROMPT == [Q2] CEIL / FLOOR (음수 주의)
SELECT CEIL(15.1) c1, CEIL(-15.1) c2, FLOOR(15.9) f1, FLOOR(-15.1) f2 FROM dual;

PROMPT == [Q3] MOD 와 나눗셈: Oracle 의 / 는 항상 실수 나눗셈
SELECT MOD(11, 4) m1, MOD(-11, 4) m2, MOD(11, -4) m3, 7 / 2 div, TRUNC(7 / 2) int_div FROM dual;

PROMPT == [Q4] ABS / SIGN / POWER / SQRT
SELECT ABS(-3.5) a, SIGN(-3.5) s1, SIGN(0) s2, POWER(2, 10) p, SQRT(16) q FROM dual;

PROMPT == [Q5] 0 으로 나누기 -> 오류
-- @expect-error: ORA-01476
SELECT 1 / 0 FROM dual;
