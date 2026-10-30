-- ex01 집계 함수와 NULL  | SQL Server  데이터: G_NUM(v INT: 1, 2, NULL, 4, 4)
PRINT N'== [Q1] COUNT(*) / COUNT(v) / COUNT(DISTINCT v)';
SELECT COUNT(*) AS cnt_star, COUNT(v) AS cnt_v, COUNT(DISTINCT v) AS cnt_dist_v FROM g_num;
PRINT N'== [Q2] SUM·AVG·MAX·MIN (v 가 INT 라 AVG 도 INT: 11/4 = 2)';
SELECT SUM(v) AS sum_v, AVG(v) AS avg_v, MAX(v) AS max_v, MIN(v) AS min_v,
       SUM(v) / COUNT(*) AS sum_div_all, AVG(ISNULL(v, 0)) AS avg_isnull, AVG(CAST(v AS DECIMAL(10,4))) AS avg_decimal FROM g_num;
PRINT N'== [Q3] 정수 평균 (1, 2) -> 1 (소수 버림)';
SELECT AVG(v) AS avg_v, AVG(v * 1.0) AS avg_v_float FROM g_num WHERE id IN (1, 2);
PRINT N'== [Q4] 빈 집합 집계';
SELECT COUNT(*) AS cnt, SUM(v) AS sum_v, AVG(v) AS avg_v, MAX(v) AS max_v FROM g_empty;
PRINT N'== [Q5] 빈 집합 + GROUP BY';
SELECT v, COUNT(*) AS cnt FROM g_empty GROUP BY v;
PRINT N'== [Q6] 분산·표준편차 함수 이름: SQL Server VAR / STDEV';
SELECT ROUND(VAR(sal), 2) AS var_sal, ROUND(STDEV(sal), 2) AS std_sal FROM emp;
GO
