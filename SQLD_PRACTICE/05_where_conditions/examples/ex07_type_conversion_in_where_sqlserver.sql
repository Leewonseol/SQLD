-- ex07 비교 대상 자료형 일치와 암시적 형변환  | SQL Server (자료형 우선순위: INT 가 VARCHAR 보다 높아 문자 쪽이 INT 로 변환)
PRINT N'== [Q1] 숫자 컬럼 = 문자 상수';
SELECT ename FROM emp WHERE empno = '7369';
GO
PRINT N'== [Q2] 문자 컬럼 = 숫자 상수 -> A1 변환 실패';
GO
-- @expect-error: MSG-245
SELECT id, code FROM w_code WHERE code = 1;
GO
PRINT N'== [Q3] 숫자로 바뀔 수 있는 행만';
SELECT id, code FROM w_code WHERE id <= 4 AND code = 1 ORDER BY id;
PRINT N'== [Q4] 문자 비교';
SELECT id, code FROM w_code WHERE code = '1' ORDER BY id;
GO
