-- ex07 비교 대상 자료형 일치와 암시적 형변환 (PDF E-06 "데이터 타입이 일치하는 것이 좋음")  | Oracle
PROMPT == [Q1] 숫자 컬럼 = 문자 상수: 상수 '7369' 가 숫자로 변환 -> 정상
SELECT ename FROM emp WHERE empno = '7369';

PROMPT == [Q2] 문자 컬럼 = 숫자 상수: 컬럼 쪽이 TO_NUMBER 로 변환된다 -> 'A1' 행에서 오류
-- @expect-error: ORA-01722
SELECT id, code FROM w_code WHERE code = 1;

PROMPT == [Q3] 숫자로 바뀔 수 있는 행만 남기면 '001','01','1' 셋이 모두 1 과 같다 (문자 비교였다면 '1' 만)
SELECT id, code FROM w_code WHERE id <= 4 AND code = 1 ORDER BY id;

PROMPT == [Q4] 자료형을 맞춘 문자 비교
SELECT id, code FROM w_code WHERE code = '1' ORDER BY id;
