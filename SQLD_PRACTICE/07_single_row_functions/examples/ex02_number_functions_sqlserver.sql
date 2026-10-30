-- ex02 숫자 함수  | SQL Server
PRINT N'== [Q1] ROUND(x, n) / 버림은 ROUND(x, n, 1) (TRUNC 없음)';
SELECT ROUND(15.193, 1) r1, ROUND(15.193, -1) r2, ROUND(15.5, 0) r3, ROUND(-15.5, 0) r4,
       ROUND(15.79, 1, 1) t1, ROUND(15.79, 0, 1) t2, ROUND(-15.79, 0, 1) t3;
PRINT N'== [Q2] CEILING / FLOOR';
SELECT CEILING(15.1) c1, CEILING(-15.1) c2, FLOOR(15.9) f1, FLOOR(-15.1) f2;
PRINT N'== [Q3] % 연산자와 나눗셈: 정수 / 정수 = 정수';
SELECT 11 % 4 m1, -11 % 4 m2, 11 % -4 m3, 7 / 2 div, 7 / 2.0 real_div, 7.0 / 2 real_div2;
PRINT N'== [Q4] ABS / SIGN / POWER / SQRT';
SELECT ABS(-3.5) a, SIGN(-3.5) s1, SIGN(0) s2, POWER(2, 10) p, SQRT(16) q;
GO
PRINT N'== [Q5] 0 으로 나누기 -> 오류';
GO
-- @expect-error: MSG-8134
SELECT 1 / 0;
GO
PRINT N'== [Q6] MOD / TRUNC 는 없는 함수';
GO
-- @expect-error: MSG-195
SELECT MOD(11, 4);
GO
