-- ex05 자기 자신과의 관계(순환 관계)  | SQL Server
DROP TABLE IF EXISTS m01_mem;
CREATE TABLE m01_mem (
  member_id INT CONSTRAINT pk_m01_mem PRIMARY KEY,
  name      VARCHAR(10) NOT NULL,
  recommender_id INT CONSTRAINT fk_m01_mem_rec REFERENCES m01_mem(member_id),
  CONSTRAINT ck_m01_mem_not_self CHECK (recommender_id <> member_id)
);
PRINT N'== [Q1] 자기참조 FK';
INSERT INTO m01_mem VALUES (1, 'A', NULL), (2, 'B', 1), (3, 'C', 2);
GO
-- @expect-error: MSG-547
INSERT INTO m01_mem VALUES (4, 'D', 99);
GO
PRINT N'== [Q2] 자기 자신 추천 금지 CHECK';
GO
INSERT INTO m01_mem VALUES (5, 'E', 5);
GO
PRINT N'== [Q3] 여러 행에 걸친 순환은 막지 못한다';
UPDATE m01_mem SET recommender_id = 3 WHERE member_id = 1;
SELECT member_id, recommender_id FROM m01_mem ORDER BY member_id;
PRINT N'== [Q4] 순환 탐지(재귀 CTE, 경로에 이미 있으면 멈춤)';
WITH t (member_id, lvl, path) AS (
  SELECT member_id, 1, CAST('/' + CAST(member_id AS VARCHAR(10)) + '/' AS VARCHAR(100)) FROM m01_mem WHERE member_id = 1
  UNION ALL
  SELECT m.recommender_id, t.lvl + 1, CAST(t.path + CAST(m.recommender_id AS VARCHAR(10)) + '/' AS VARCHAR(100))
  FROM m01_mem m JOIN t ON m.member_id = t.member_id
  WHERE m.recommender_id IS NOT NULL AND t.path NOT LIKE '%/' + CAST(m.recommender_id AS VARCHAR(10)) + '/%')
SELECT member_id, lvl, path FROM t ORDER BY lvl;
DROP TABLE IF EXISTS m01_mem;
GO
