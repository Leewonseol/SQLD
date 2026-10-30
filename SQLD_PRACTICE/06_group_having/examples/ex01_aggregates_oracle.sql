-- ex01 집계 함수와 NULL (요구목록 §7 SUM·COUNT·AVG 등)  | Oracle  데이터: G_NUM(v: 1, 2, NULL, 4, 4)
PROMPT == [Q1] COUNT(*) 는 행 수, COUNT(컬럼) 은 NULL 이 아닌 값 수, COUNT(DISTINCT) 는 서로 다른 값 수
SELECT COUNT(*) AS cnt_star, COUNT(v) AS cnt_v, COUNT(DISTINCT v) AS cnt_dist_v FROM g_num;

PROMPT == [Q2] SUM·AVG·MAX·MIN 은 NULL 을 무시한다: AVG = 11 / 4 (5 가 아니다)
SELECT SUM(v) AS sum_v, AVG(v) AS avg_v, MAX(v) AS max_v, MIN(v) AS min_v,
       SUM(v) / COUNT(*) AS sum_div_all, AVG(NVL(v, 0)) AS avg_nvl FROM g_num;

PROMPT == [Q3] 정수 컬럼 평균: Oracle 은 NUMBER 라 소수까지 계산 (SQL Server 결과와 비교)
SELECT AVG(v) AS avg_v FROM g_num WHERE id IN (1, 2);

PROMPT == [Q4] 행이 없는 집합의 집계: 집계 결과 1행. COUNT 는 0, 나머지는 NULL
SELECT COUNT(*) AS cnt, SUM(v) AS sum_v, AVG(v) AS avg_v, MAX(v) AS max_v FROM g_empty;

PROMPT == [Q5] 같은 빈 집합에 GROUP BY 를 붙이면 그룹이 없으니 0행
SELECT v, COUNT(*) AS cnt FROM g_empty GROUP BY v;

PROMPT == [Q6] 분산·표준편차 함수 이름: Oracle VARIANCE / STDDEV
SELECT ROUND(VARIANCE(sal), 2) AS var_sal, ROUND(STDDEV(sal), 2) AS std_sal FROM emp;
