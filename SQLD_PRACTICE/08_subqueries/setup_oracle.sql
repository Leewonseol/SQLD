-- 08_subqueries/setup_oracle.sql (재실행 가능)
--   [PDF E-20] PAINTINGS·ARTISTS 값은 추출본 그대로(108 여행은 artist_id 10, PDF 가정 그대로)
--   [가상] ORDER_ITEMS 값(구조는 PDF E-23), BONUS
EXEC lab_drop('PAINTINGS')
EXEC lab_drop('ARTISTS')
EXEC lab_drop('ORDER_ITEMS')
EXEC lab_drop('BONUS')
CREATE TABLE artists (id NUMBER CONSTRAINT pk_artists PRIMARY KEY, name VARCHAR2(20 CHAR) NOT NULL);
-- FK 를 두지 않았다: PDF 가 '존재하지 않는 작가 10번'을 참조하는 그림을 일부러 넣었기 때문
CREATE TABLE paintings (id NUMBER CONSTRAINT pk_paintings PRIMARY KEY, name VARCHAR2(20 CHAR) NOT NULL,
                        artist_id NUMBER, price NUMBER NOT NULL);
INSERT INTO artists VALUES (1, '이지현');
INSERT INTO artists VALUES (2, '황현석');
INSERT INTO artists VALUES (3, '박성진');
INSERT INTO artists VALUES (4, '백에서');
INSERT INTO artists VALUES (5, '정하나');
INSERT INTO paintings VALUES (101, '숲과나',    1, 1100000);
INSERT INTO paintings VALUES (102, '밤의 도시', 1, 1350000);
INSERT INTO paintings VALUES (103, '파도',      2,  470000);
INSERT INTO paintings VALUES (104, 'Pop!',      3,  750000);
INSERT INTO paintings VALUES (105, '너',        4,  640000);
INSERT INTO paintings VALUES (106, '밤비',      5,  920000);
INSERT INTO paintings VALUES (107, '기억',      5,  380000);
INSERT INTO paintings VALUES (108, '여행',     10,  150000);
CREATE TABLE order_items (order_id NUMBER, product_id NUMBER, quantity NUMBER, price NUMBER(10,2),
                          CONSTRAINT pk_order_items PRIMARY KEY (order_id, product_id));
INSERT INTO order_items VALUES (1, 10, 2, 1000);
INSERT INTO order_items VALUES (1, 20, 1, 5000);
INSERT INTO order_items VALUES (2, 10, 3, 1000);
INSERT INTO order_items VALUES (2, 30, 1, 2500);
INSERT INTO order_items VALUES (3, 20, 2, 5000);
CREATE TABLE bonus (empno NUMBER CONSTRAINT pk_bonus PRIMARY KEY, amt NUMBER NOT NULL);
INSERT INTO bonus VALUES (7369, 100);
INSERT INTO bonus VALUES (7499, 200);
COMMIT;
