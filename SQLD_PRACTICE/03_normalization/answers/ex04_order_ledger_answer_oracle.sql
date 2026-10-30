-- H. 정답 및 검증 | 03 G4 | Oracle : 3NF 분해 후 JOIN 이 원래 장부와 같은지 lab_check
EXEC lab_drop('N03_G_LEDGER')
EXEC lab_drop('N03_G_ITEM')
EXEC lab_drop('N03_G_ORDER')
EXEC lab_drop('N03_G_PRODUCT')
EXEC lab_drop('N03_G_CUST')
EXEC lab_drop('N03_G_GRADE')
CREATE TABLE n03_g_ledger (ord_no NUMBER, ord_dt DATE, cust_no VARCHAR2(3), cust_nm VARCHAR2(10 CHAR), grade VARCHAR2(5), disc NUMBER,
                           prod_cd VARCHAR2(3), prod_nm VARCHAR2(10 CHAR), price NUMBER, qty NUMBER, PRIMARY KEY (ord_no, prod_cd));
INSERT INTO n03_g_ledger VALUES (1001, DATE '2024-05-01', 'C1', '가', 'VIP', 10, 'P1', '펜', 1000, 2);
INSERT INTO n03_g_ledger VALUES (1001, DATE '2024-05-01', 'C1', '가', 'VIP', 10, 'P2', '노트', 3000, 1);
INSERT INTO n03_g_ledger VALUES (1002, DATE '2024-05-02', 'C2', '나', 'GOLD', 5, 'P1', '펜', 1000, 5);
COMMIT;
-- [학습자 작성 구간 시작] 분해
CREATE TABLE n03_g_grade   AS SELECT DISTINCT grade, disc FROM n03_g_ledger;
CREATE TABLE n03_g_cust    AS SELECT DISTINCT cust_no, cust_nm, grade FROM n03_g_ledger;
CREATE TABLE n03_g_product AS SELECT DISTINCT prod_cd, prod_nm, price FROM n03_g_ledger;
CREATE TABLE n03_g_order   AS SELECT DISTINCT ord_no, ord_dt, cust_no FROM n03_g_ledger;
CREATE TABLE n03_g_item    AS SELECT ord_no, prod_cd, qty FROM n03_g_ledger;
ALTER TABLE n03_g_grade ADD PRIMARY KEY (grade);
ALTER TABLE n03_g_cust ADD PRIMARY KEY (cust_no);
ALTER TABLE n03_g_cust ADD FOREIGN KEY (grade) REFERENCES n03_g_grade(grade);
ALTER TABLE n03_g_product ADD PRIMARY KEY (prod_cd);
ALTER TABLE n03_g_order ADD PRIMARY KEY (ord_no);
ALTER TABLE n03_g_order ADD FOREIGN KEY (cust_no) REFERENCES n03_g_cust(cust_no);
ALTER TABLE n03_g_item ADD PRIMARY KEY (ord_no, prod_cd);
ALTER TABLE n03_g_item ADD FOREIGN KEY (ord_no) REFERENCES n03_g_order(ord_no);
ALTER TABLE n03_g_item ADD FOREIGN KEY (prod_cd) REFERENCES n03_g_product(prod_cd);
-- [학습자 작성 구간 끝]
CREATE OR REPLACE VIEW ans03_04_g4 AS
SELECT o.ord_no, o.ord_dt, c.cust_no, c.cust_nm, g.grade, g.disc, p.prod_cd, p.prod_nm, p.price, i.qty
FROM n03_g_item i JOIN n03_g_order o ON i.ord_no = o.ord_no JOIN n03_g_cust c ON o.cust_no = c.cust_no
JOIN n03_g_grade g ON c.grade = g.grade JOIN n03_g_product p ON i.prod_cd = p.prod_cd;
CREATE OR REPLACE VIEW exp03_04_g4 AS SELECT * FROM n03_g_ledger;
EXEC lab_check('03-G4-lossless', 'ANS03_04_G4', 'EXP03_04_G4')
SELECT (SELECT COUNT(*) FROM n03_g_grade) grades, (SELECT COUNT(*) FROM n03_g_cust) custs, (SELECT COUNT(*) FROM n03_g_product) products,
       (SELECT COUNT(*) FROM n03_g_order) orders, (SELECT COUNT(*) FROM n03_g_item) items FROM dual;
