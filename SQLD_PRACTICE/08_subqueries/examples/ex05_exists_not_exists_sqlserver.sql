-- ex05 EXISTS · NOT EXISTS 와 NOT IN 의 NULL 함정 (PDF E-26, 요구목록 §7·§9)  | SQL Server
PRINT N'== [Q1] EXISTS: 사원이 한 명이라도 있는 부서 (서브쿼리가 1행이라도 내면 참, SELECT 목록 내용은 무관)';
SELECT d.deptno, d.dname FROM dept d WHERE EXISTS (SELECT 1 FROM emp e WHERE e.deptno = d.deptno) ORDER BY d.deptno;

PRINT N'== [Q2] NOT EXISTS: 사원이 없는 부서 (PDF: 차집합)';
SELECT d.deptno, d.dname FROM dept d WHERE NOT EXISTS (SELECT 1 FROM emp e WHERE e.deptno = d.deptno) ORDER BY d.deptno;

PRINT N'== [Q3] EXISTS 안의 SELECT NULL 이나 SELECT 1/0 도 평가하지 않는다';
SELECT COUNT(*) AS cnt FROM dept d WHERE EXISTS (SELECT NULL FROM emp e WHERE e.deptno = d.deptno);

PRINT N'== [Q4] 부하가 없는 사원: NOT IN (SELECT mgr ...) -> mgr 에 NULL(KING) 이 있어 0행';
SELECT COUNT(*) AS not_in_cnt FROM emp WHERE empno NOT IN (SELECT mgr FROM emp);

PRINT N'== [Q5] NOT EXISTS 는 NULL 에 영향받지 않는다 -> 8행';
SELECT e.ename FROM emp e WHERE NOT EXISTS (SELECT 1 FROM emp s WHERE s.mgr = e.empno) ORDER BY e.empno;

PRINT N'== [Q6] NOT IN 을 쓰려면 서브쿼리에서 NULL 을 제거';
SELECT COUNT(*) AS not_in_fixed FROM emp WHERE empno NOT IN (SELECT mgr FROM emp WHERE mgr IS NOT NULL);
