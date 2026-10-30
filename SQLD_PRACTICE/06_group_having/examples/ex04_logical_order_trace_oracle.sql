-- ex04 논리적 처리 순서 단계별 추적 (PDF E-05, 요구목록 §3·학습능력 7)  | Oracle
-- 추적 대상 쿼리:
--   SELECT d.dname, COUNT(*) AS cnt, SUM(e.sal) AS total
--   FROM emp e JOIN dept d ON e.deptno = d.deptno
--   WHERE e.job <> 'PRESIDENT'
--   GROUP BY d.dname
--   HAVING COUNT(*) >= 2
--   ORDER BY total DESC
--   FETCH FIRST 2 ROWS ONLY;
PROMPT == [S1] FROM + JOIN ON : 조인 결과 행 (14행)
SELECT e.empno, e.ename, e.job, e.sal, d.dname FROM emp e JOIN dept d ON e.deptno = d.deptno ORDER BY e.empno;

PROMPT == [S2] WHERE job <> 'PRESIDENT' : KING 제외 (13행)
SELECT COUNT(*) AS rows_after_where FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE e.job <> 'PRESIDENT';

PROMPT == [S3] GROUP BY dname : 그룹별 행 (그룹 3개)
SELECT d.dname, LISTAGG(e.ename, ',') WITHIN GROUP (ORDER BY e.ename) AS members, COUNT(*) AS cnt, SUM(e.sal) AS total
FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE e.job <> 'PRESIDENT' GROUP BY d.dname ORDER BY d.dname;

PROMPT == [S4] HAVING COUNT(*) >= 2 : 세 그룹 모두 통과  -> [S5] SELECT 로 열 계산 -> [S6] ORDER BY total DESC
SELECT d.dname, COUNT(*) AS cnt, SUM(e.sal) AS total
FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE e.job <> 'PRESIDENT'
GROUP BY d.dname HAVING COUNT(*) >= 2 ORDER BY total DESC;

PROMPT == [S7] 행 제한 FETCH FIRST 2 ROWS ONLY : 최종 결과
SELECT d.dname, COUNT(*) AS cnt, SUM(e.sal) AS total
FROM emp e JOIN dept d ON e.deptno = d.deptno
WHERE e.job <> 'PRESIDENT'
GROUP BY d.dname
HAVING COUNT(*) >= 2
ORDER BY total DESC
FETCH FIRST 2 ROWS ONLY;

PROMPT == [T1] DISTINCT 는 ORDER BY·행 제한보다 먼저: 중복 제거 -> 정렬 -> 3개
SELECT DISTINCT job FROM emp ORDER BY job FETCH FIRST 3 ROWS ONLY;

PROMPT == [T2] (비교) 행 제한을 먼저 한 뒤 중복 제거하면 다른 결과: 이름순 3명(ADAMS, ALLEN, BLAKE)의 직무
SELECT DISTINCT job FROM (SELECT job FROM emp ORDER BY ename FETCH FIRST 3 ROWS ONLY) ORDER BY job;
