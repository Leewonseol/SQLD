-- ex03 LIKE 와 와일드카드, ESCAPE (요구목록 §7, PDF E-06 "비교문자열과 형태 일치")  | Oracle
PROMPT == [Q1] _ 는 정확히 한 글자: 두 번째 글자가 A 인 이름
SELECT ename FROM emp WHERE ename LIKE '_A%' ORDER BY ename;

PROMPT == [Q2] % 는 0글자 이상: S 로 끝나는 이름
SELECT ename FROM emp WHERE ename LIKE '%S' ORDER BY ename;

PROMPT == [Q3] 'A_B' 패턴: _ 가 와일드카드라 A_B, AXB 둘 다 일치 (AB 는 가운데 글자가 없어 불일치)
SELECT id, txt FROM w_like WHERE txt LIKE 'A_B' ORDER BY id;

PROMPT == [Q4] ESCAPE 로 _ 를 문자 그대로: A_B 만
SELECT id, txt FROM w_like WHERE txt LIKE 'A\_B' ESCAPE '\' ORDER BY id;

PROMPT == [Q5] % 문자 자체를 찾기: 100% 만
SELECT id, txt FROM w_like WHERE txt LIKE '%!%' ESCAPE '!' ORDER BY id;

PROMPT == [Q6] 대소문자: Oracle 기본 비교는 대소문자를 구분 -> 'ab' 는 'A%' 에 불일치
SELECT id, txt FROM w_like WHERE txt LIKE 'A%' ORDER BY id;

PROMPT == [Q7] NULL 은 LIKE '%' 에도 일치하지 않는다
SELECT (SELECT COUNT(*) FROM w_like WHERE txt LIKE '%') AS like_all, (SELECT COUNT(*) FROM w_like) AS total FROM dual;
PROMPT (참고: COUNT(*) 와 스칼라 서브쿼리를 한 SELECT 에 섞으면 Oracle 은 오류(not a single-group group function), SQL Server 는 허용)
