-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex07_inline_view | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex07_inline_view.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 작가별 최고가 작품';
GO
CREATE OR ALTER VIEW ans08_07_g1 (artist, painting) AS
SELECT a.name, p.name FROM artists a JOIN paintings p ON p.artist_id = a.id
JOIN (SELECT artist_id, MAX(price) AS max_price FROM paintings GROUP BY artist_id) m ON m.artist_id = p.artist_id AND m.max_price = p.price;
GO
CREATE OR ALTER VIEW exp08_07_g1 (artist, painting) AS
SELECT * FROM (VALUES (N'박성진', N'Pop!'),
       (N'백에서', N'너'),
       (N'이지현', N'밤의 도시'),
       (N'정하나', N'밤비'),
       (N'황현석', N'파도')) v(artist, painting);
GO
EXEC lab_check N'08-ex07-G1', N'ans08_07_g1', N'exp08_07_g1';
SELECT * FROM ans08_07_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 가격 상위 3개 그림';
GO
CREATE OR ALTER VIEW ans08_07_g2 (id, name, price) AS
SELECT TOP 3 id, name, price FROM paintings ORDER BY price DESC;
GO
CREATE OR ALTER VIEW exp08_07_g2 (id, name, price) AS
SELECT * FROM (VALUES (101, N'숲과나', 1100000),
       (102, N'밤의 도시', 1350000),
       (106, N'밤비', 920000)) v(id, name, price);
GO
EXEC lab_check N'08-ex07-G2', N'ans08_07_g2', N'exp08_07_g2';
SELECT * FROM ans08_07_g2 ORDER BY 1, 2, 3;
GO
