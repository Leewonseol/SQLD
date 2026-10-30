-- ex02 집합 연산의 규칙 (PDF E-27 "컬럼의 순서와 데이터 타입이 상호 호환", "컬럼명과 데이터 타입은 첫 번째 집합에 의해 결정")  | Oracle
PROMPT == [Q1] 결과 컬럼명은 첫 번째 SELECT 의 이름
SELECT ename AS first_name, sal FROM emp WHERE empno = 7369
UNION ALL
SELECT dname AS second_name, deptno FROM dept WHERE deptno = 10;

PROMPT == [Q2] ORDER BY 는 맨 끝에 한 번. 첫 SELECT 의 이름이나 위치 번호로
SELECT ename AS nm, sal FROM emp WHERE deptno = 10 UNION ALL SELECT dname, deptno FROM dept ORDER BY nm;

PROMPT == [Q3] 두 번째 SELECT 의 별칭으로 정렬 -> 오류
-- @expect-error: ORA-00904
SELECT ename AS nm FROM emp WHERE deptno = 10 UNION ALL SELECT dname AS dn FROM dept ORDER BY dn;

PROMPT == [Q4] 컬럼 수가 다르면 오류
-- @expect-error: ORA-01789
SELECT ename, sal FROM emp UNION SELECT dname FROM dept;

PROMPT == [Q5] 자료형이 호환되지 않으면 오류 (문자 vs 숫자)
-- @expect-error: ORA-01790
SELECT ename FROM emp UNION SELECT deptno FROM dept;

PROMPT == [Q6] 연산자 우선순위: Oracle 은 모든 집합 연산자가 같은 우선순위 -> 왼쪽부터: (A UNION B) INTERSECT C
SELECT v FROM s_a UNION SELECT v FROM s_b INTERSECT SELECT v FROM s_c ORDER BY 1;

PROMPT == [Q7] 각 SELECT 안에는 ORDER BY 를 둘 수 없다 (괄호로 감싼 인라인 뷰 안이라면 가능)
-- @expect-error: ORA-00933
SELECT ename FROM emp WHERE deptno = 10 ORDER BY ename UNION SELECT dname FROM dept;
