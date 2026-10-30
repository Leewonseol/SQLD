-- ex04 BETWEEN  | SQL Server
PRINT N'== [Q1] 양 끝 포함';
SELECT ename, sal FROM emp WHERE sal BETWEEN 1250 AND 1600 ORDER BY sal, ename;
PRINT N'== [Q2] 거꾸로 쓴 BETWEEN';
SELECT COUNT(*) AS cnt FROM emp WHERE sal BETWEEN 1600 AND 1250;
PRINT N'== [Q3] NOT BETWEEN';
SELECT ename, sal FROM emp WHERE sal NOT BETWEEN 1250 AND 3000 ORDER BY sal;
PRINT N'== [Q4] 시각이 있는 DATETIME2 에 날짜만으로 BETWEEN';
SELECT id, FORMAT(ts, 'yyyy-MM-dd HH:mm') AS ts FROM w_ts
WHERE ts BETWEEN '2024-03-01' AND '2024-03-31' ORDER BY id;
PRINT N'== [Q5] 반열린 구간';
SELECT id, FORMAT(ts, 'yyyy-MM-dd HH:mm') AS ts FROM w_ts
WHERE ts >= '2024-03-01' AND ts < '2024-04-01' ORDER BY id;
PRINT N'== [Q6] 문자열 BETWEEN';
SELECT ename FROM emp WHERE ename BETWEEN 'A' AND 'C' ORDER BY ename;
GO
