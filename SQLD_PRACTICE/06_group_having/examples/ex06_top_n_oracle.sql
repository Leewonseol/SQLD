-- ex06 TOP-N 과 행 제한 (PDF E-36 ROWNUM, 요구목록 §7 TOP-N)  | Oracle
PROMPT == [Q1] WHERE ROWNUM > 1 : 오류는 없지만 0행 (첫 행이 ROWNUM 1 이라 탈락 -> 다음 행이 다시 1 ...)
SELECT COUNT(*) AS cnt FROM emp WHERE ROWNUM > 1;

PROMPT == [Q2] WHERE ROWNUM = 3 : 0행 (1, 2 가 먼저 부여되지 않으면 3 에 도달하지 못한다)
SELECT COUNT(*) AS cnt FROM emp WHERE ROWNUM = 3;

PROMPT == [Q3] WHERE ROWNUM >= 1 : 전체 14행 / ROWNUM = 1 : 1행
SELECT (SELECT COUNT(*) FROM emp WHERE ROWNUM >= 1) AS ge1, (SELECT COUNT(*) FROM emp WHERE ROWNUM = 1) AS eq1 FROM dual;

PROMPT == [Q4] ROWNUM <= 3 : 3행. 어떤 3행인지는 읽는 순서(실행 계획)에 달려 있다 -> 단정 불가
SELECT ROWNUM, ename, sal FROM emp WHERE ROWNUM <= 3;

PROMPT == [Q5] PDF 의 '잘못된 상위 3명' 쿼리: ROWNUM 이 ORDER BY 보다 먼저 -> 먼저 읽힌 3행을 정렬할 뿐
SELECT ename, sal FROM emp WHERE ROWNUM <= 3 ORDER BY sal DESC;

PROMPT == [Q6] 올바른 TOP-N: 인라인 뷰에서 먼저 정렬(동점은 ename 으로 결정) -> 바깥에서 ROWNUM
SELECT ROWNUM AS rn, ename, sal FROM (SELECT ename, sal FROM emp ORDER BY sal DESC, ename) WHERE ROWNUM <= 3;

PROMPT == [Q7] 12c 이상: FETCH FIRST n ROWS ONLY / WITH TIES / PERCENT / OFFSET
SELECT ename, sal FROM emp ORDER BY sal DESC, ename FETCH FIRST 3 ROWS ONLY;
SELECT ename, sal FROM emp ORDER BY sal DESC FETCH FIRST 2 ROWS WITH TIES;
SELECT COUNT(*) AS pct20_rows FROM (SELECT ename FROM emp ORDER BY sal DESC FETCH FIRST 20 PERCENT ROWS ONLY);
SELECT ename, sal FROM emp ORDER BY sal DESC, ename OFFSET 3 ROWS FETCH NEXT 3 ROWS ONLY;

PROMPT == [Q8] 페이지 처리(4~6위)를 ROWNUM 으로: 안쪽에서 ROWNUM 을 별칭으로 고정해야 바깥에서 > 비교 가능
SELECT rn, ename, sal FROM (
  SELECT ROWNUM AS rn, ename, sal FROM (SELECT ename, sal FROM emp ORDER BY sal DESC, ename) WHERE ROWNUM <= 6
) WHERE rn > 3;
