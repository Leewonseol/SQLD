-- ex03 집합 연산과 조인·EXISTS 의 관계 (PDF E-27 "두 개 이상의 테이블에서 JOIN을 사용하지 않고, 연관된 데이터를 조회")  | Oracle
PROMPT == [Q1] INTERSECT ≈ EXISTS (단, 중복 제거와 NULL 처리가 다르다)
SELECT v FROM s_a INTERSECT SELECT v FROM s_b ORDER BY 1;
SELECT DISTINCT a.v FROM s_a a WHERE EXISTS (SELECT 1 FROM s_b b WHERE b.v = a.v) ORDER BY 1;

PROMPT == [Q2] MINUS ≈ NOT EXISTS (NULL 행에서 결과가 갈린다)
SELECT v FROM s_a MINUS SELECT v FROM s_b ORDER BY 1;
SELECT DISTINCT a.v FROM s_a a WHERE NOT EXISTS (SELECT 1 FROM s_b b WHERE b.v = a.v) ORDER BY 1;

PROMPT == [Q3] UNION ALL 로 FULL OUTER JOIN 흉내 (04단원 ex10 의 UNION 방식과 비교)
SELECT a.v AS a_v, b.v AS b_v FROM s_a a LEFT JOIN s_b b ON a.v = b.v
UNION ALL
SELECT NULL, b.v FROM s_b b WHERE NOT EXISTS (SELECT 1 FROM s_a a WHERE a.v = b.v)
ORDER BY 1, 2;
