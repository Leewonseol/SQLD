-- ex03 버전 전용 예제: Oracle Database 23ai (FREE 23.x)  -- PDF E-07 "23c 이전 버전" 대비
-- 이 파일만 23ai 컨테이너에서 실행한다. 19c/21c 에서는 Q1, Q2, Q3 모두 오류다.
PROMPT == [Q1] FROM 절 없는 SELECT (23ai 부터 허용)
SELECT 1 + 1 AS two;

PROMPT == [Q2] DROP TABLE IF EXISTS (23ai 부터 허용)
DROP TABLE IF EXISTS v23_emp PURGE;
CREATE TABLE v23_emp (deptno NUMBER, sal NUMBER);
INSERT INTO v23_emp VALUES (10, 100);
INSERT INTO v23_emp VALUES (10, 200);
INSERT INTO v23_emp VALUES (20, 300);
COMMIT;

PROMPT == [Q3] GROUP BY 에 SELECT 별칭 사용 (23ai 부터 허용)
SELECT deptno AS d, SUM(sal) AS s FROM v23_emp GROUP BY d ORDER BY d;

PROMPT == [Q4] 버전 확인
SELECT banner_full FROM v$version;
DROP TABLE IF EXISTS v23_emp PURGE;
