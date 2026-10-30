-- ex09 CROSS JOIN (PDF E-18)  | Oracle   데이터: [PDF] CJ_T1(3행), CJ_T2(3행)
PROMPT == [Q1] CROSS JOIN = 3 x 3 = 9행. 조인 조건이 없으므로 NULL 도 그대로 조합된다
SELECT * FROM cj_t1 CROSS JOIN cj_t2 ORDER BY cj_t1.x2 DESC, cj_t2.y2 DESC;

PROMPT == [Q2] Oracle 방식: FROM 에 테이블만 나열하고 WHERE 조인 조건이 없으면 카티션 곱
SELECT COUNT(*) AS cartesian_rows FROM cj_t1, cj_t2;

PROMPT == [Q3] 비교: 같은 데이터에 x1 으로 EQUI JOIN -> a, b 2행 (NULL 과 'C' 는 짝이 없다)
SELECT a.x1, a.x2, b.y2 FROM cj_t1 a JOIN cj_t2 b ON a.x1 = b.x1 ORDER BY a.x1;

PROMPT == [Q4] CROSS JOIN 에 ON -> 오류
-- @expect-error: ORA-00933
SELECT * FROM cj_t1 a CROSS JOIN cj_t2 b ON a.x1 = b.x1;

PROMPT == [Q5] 문자 정렬 비교: x1 오름차순 (Oracle 기본 BINARY 정렬, NULL 은 마지막)
SELECT x1 FROM cj_t1 UNION ALL SELECT x1 FROM cj_t2 ORDER BY 1;
