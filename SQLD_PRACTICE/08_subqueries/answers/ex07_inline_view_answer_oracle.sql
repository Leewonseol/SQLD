-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex07_inline_view | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex07_inline_view.md
-- =====================================================================

PROMPT == [G1] 작가별 최고가 작품
CREATE OR REPLACE VIEW ans08_07_g1 (artist, painting) AS
SELECT a.name, p.name FROM artists a JOIN paintings p ON p.artist_id = a.id
JOIN (SELECT artist_id, MAX(price) AS max_price FROM paintings GROUP BY artist_id) m ON m.artist_id = p.artist_id AND m.max_price = p.price;
CREATE OR REPLACE VIEW exp08_07_g1 (artist, painting) AS
-- (artist, painting)
SELECT '박성진', 'Pop!' FROM dual
UNION ALL SELECT '백에서', '너' FROM dual
UNION ALL SELECT '이지현', '밤의 도시' FROM dual
UNION ALL SELECT '정하나', '밤비' FROM dual
UNION ALL SELECT '황현석', '파도' FROM dual;
EXEC lab_check('08-ex07-G1', 'ANS08_07_G1', 'EXP08_07_G1')
SELECT * FROM ans08_07_g1 ORDER BY 1, 2;

PROMPT == [G2] 가격 상위 3개 그림
CREATE OR REPLACE VIEW ans08_07_g2 (id, name, price) AS
SELECT id, name, price FROM (SELECT id, name, price FROM paintings ORDER BY price DESC) WHERE ROWNUM <= 3;
CREATE OR REPLACE VIEW exp08_07_g2 (id, name, price) AS
-- (id, name, price)
SELECT 101, '숲과나', 1100000 FROM dual
UNION ALL SELECT 102, '밤의 도시', 1350000 FROM dual
UNION ALL SELECT 106, '밤비', 920000 FROM dual;
EXEC lab_check('08-ex07-G2', 'ANS08_07_G2', 'EXP08_07_G2')
SELECT * FROM ans08_07_g2 ORDER BY 1, 2, 3;
