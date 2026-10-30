-- 08_subqueries/setup_sqlserver.sql (재실행 가능)
USE SQLD_LAB;
GO
IF DB_NAME() <> N'SQLD_LAB' THROW 50000, N'SQLD_LAB DB에서만 실행한다.', 1;
DROP TABLE IF EXISTS paintings, artists, order_items, bonus;
GO
CREATE TABLE artists (id INT CONSTRAINT pk_artists PRIMARY KEY, name NVARCHAR(20) NOT NULL);
CREATE TABLE paintings (id INT CONSTRAINT pk_paintings PRIMARY KEY, name NVARCHAR(20) NOT NULL, artist_id INT, price INT NOT NULL);
INSERT INTO artists VALUES (1, N'이지현'), (2, N'황현석'), (3, N'박성진'), (4, N'백에서'), (5, N'정하나');
INSERT INTO paintings VALUES (101, N'숲과나', 1, 1100000), (102, N'밤의 도시', 1, 1350000), (103, N'파도', 2, 470000),
  (104, N'Pop!', 3, 750000), (105, N'너', 4, 640000), (106, N'밤비', 5, 920000), (107, N'기억', 5, 380000), (108, N'여행', 10, 150000);
CREATE TABLE order_items (order_id INT, product_id INT, quantity INT, price DECIMAL(10,2),
                          CONSTRAINT pk_order_items PRIMARY KEY (order_id, product_id));
INSERT INTO order_items VALUES (1, 10, 2, 1000), (1, 20, 1, 5000), (2, 10, 3, 1000), (2, 30, 1, 2500), (3, 20, 2, 5000);
CREATE TABLE bonus (empno INT CONSTRAINT pk_bonus PRIMARY KEY, amt INT NOT NULL);
INSERT INTO bonus VALUES (7369, 100), (7499, 200);
GO
