-- ex03 LIKE 와 와일드카드, ESCAPE  | SQL Server
PRINT N'== [Q1] _A%';
SELECT ename FROM emp WHERE ename LIKE '_A%' ORDER BY ename;
PRINT N'== [Q2] %S';
SELECT ename FROM emp WHERE ename LIKE '%S' ORDER BY ename;
PRINT N'== [Q3] A_B 패턴';
SELECT id, txt FROM w_like WHERE txt LIKE 'A_B' ORDER BY id;
PRINT N'== [Q4] ESCAPE';
SELECT id, txt FROM w_like WHERE txt LIKE 'A\_B' ESCAPE '\' ORDER BY id;
PRINT N'== [Q5] % 문자 자체';
SELECT id, txt FROM w_like WHERE txt LIKE '%!%' ESCAPE '!' ORDER BY id;
PRINT N'== [Q6] 대소문자: 기본 데이터 정렬 CI(대소문자 구분 안 함) -> ab 도 A% 에 일치';
SELECT id, txt FROM w_like WHERE txt LIKE 'A%' ORDER BY id;
PRINT N'== [Q7] NULL 과 LIKE %';
SELECT (SELECT COUNT(*) FROM w_like WHERE txt LIKE '%') AS like_all, (SELECT COUNT(*) FROM w_like) AS total;
PRINT N'== [Q8] SQL Server 전용: [ ] 문자 집합. 대괄호로 _ 를 감싸도 문자 그대로';
SELECT id, txt FROM w_like WHERE txt LIKE 'A[_]B' ORDER BY id;
SELECT id, txt FROM w_like WHERE txt LIKE '[0-9]%' ORDER BY id;
GO
