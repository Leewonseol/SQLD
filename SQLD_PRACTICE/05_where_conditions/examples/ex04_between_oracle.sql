-- ex04 BETWEEN a AND b (PDF E-06 "a, b 포함")  | Oracle
PROMPT == [Q1] 양 끝 포함: 1250 이상 1600 이하
SELECT ename, sal FROM emp WHERE sal BETWEEN 1250 AND 1600 ORDER BY sal, ename;

PROMPT == [Q2] 순서를 거꾸로 쓰면 (sal >= 1600 AND sal <= 1250) 이 되어 0행
SELECT COUNT(*) AS cnt FROM emp WHERE sal BETWEEN 1600 AND 1250;

PROMPT == [Q3] NOT BETWEEN: 양 끝 미포함 범위 밖
SELECT ename, sal FROM emp WHERE sal NOT BETWEEN 1250 AND 3000 ORDER BY sal;

PROMPT == [Q4] 시각이 포함된 DATE 에 날짜만으로 BETWEEN: 3월 31일 15시가 빠진다
SELECT id, TO_CHAR(ts, 'YYYY-MM-DD HH24:MI') AS ts FROM w_ts
WHERE ts BETWEEN DATE '2024-03-01' AND DATE '2024-03-31' ORDER BY id;

PROMPT == [Q5] 반열린 구간으로 해결: ts >= 3/1 AND ts < 4/1
SELECT id, TO_CHAR(ts, 'YYYY-MM-DD HH24:MI') AS ts FROM w_ts
WHERE ts >= DATE '2024-03-01' AND ts < DATE '2024-04-01' ORDER BY id;

PROMPT == [Q6] 문자열 BETWEEN 은 사전순: 'A' ~ 'C' 는 'C' 로 시작하는 긴 이름(CLARK)을 포함하지 않는다
SELECT ename FROM emp WHERE ename BETWEEN 'A' AND 'C' ORDER BY ename;
