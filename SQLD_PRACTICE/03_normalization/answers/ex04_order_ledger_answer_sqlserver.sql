-- H. 정답 및 검증 | 03 G4 | SQL Server
DROP VIEW IF EXISTS ans03_04_g4, exp03_04_g4;
DROP TABLE IF EXISTS n03_g_item, n03_g_order, n03_g_product, n03_g_cust, n03_g_grade, n03_g_ledger;
CREATE TABLE n03_g_ledger (ord_no INT, ord_dt DATE, cust_no VARCHAR(3), cust_nm NVARCHAR(10), grade VARCHAR(5), disc INT,
                           prod_cd VARCHAR(3), prod_nm NVARCHAR(10), price INT, qty INT, PRIMARY KEY (ord_no, prod_cd));
INSERT INTO n03_g_ledger VALUES (1001, '2024-05-01', 'C1', N'가', 'VIP', 10, 'P1', N'펜', 1000, 2),
  (1001, '2024-05-01', 'C1', N'가', 'VIP', 10, 'P2', N'노트', 3000, 1), (1002, '2024-05-02', 'C2', N'나', 'GOLD', 5, 'P1', N'펜', 1000, 5);
-- [학습자 작성 구간 시작]
CREATE TABLE n03_g_grade (grade VARCHAR(5) PRIMARY KEY, disc INT);
CREATE TABLE n03_g_cust (cust_no VARCHAR(3) PRIMARY KEY, cust_nm NVARCHAR(10), grade VARCHAR(5) REFERENCES n03_g_grade(grade));
CREATE TABLE n03_g_product (prod_cd VARCHAR(3) PRIMARY KEY, prod_nm NVARCHAR(10), price INT);
CREATE TABLE n03_g_order (ord_no INT PRIMARY KEY, ord_dt DATE, cust_no VARCHAR(3) REFERENCES n03_g_cust(cust_no));
CREATE TABLE n03_g_item (ord_no INT REFERENCES n03_g_order(ord_no), prod_cd VARCHAR(3) REFERENCES n03_g_product(prod_cd), qty INT, PRIMARY KEY (ord_no, prod_cd));
INSERT INTO n03_g_grade SELECT DISTINCT grade, disc FROM n03_g_ledger;
INSERT INTO n03_g_cust SELECT DISTINCT cust_no, cust_nm, grade FROM n03_g_ledger;
INSERT INTO n03_g_product SELECT DISTINCT prod_cd, prod_nm, price FROM n03_g_ledger;
INSERT INTO n03_g_order SELECT DISTINCT ord_no, ord_dt, cust_no FROM n03_g_ledger;
INSERT INTO n03_g_item SELECT ord_no, prod_cd, qty FROM n03_g_ledger;
-- [학습자 작성 구간 끝]
GO
CREATE OR ALTER VIEW ans03_04_g4 AS
SELECT o.ord_no, o.ord_dt, c.cust_no, c.cust_nm, g.grade, g.disc, p.prod_cd, p.prod_nm, p.price, i.qty
FROM n03_g_item i JOIN n03_g_order o ON i.ord_no = o.ord_no JOIN n03_g_cust c ON o.cust_no = c.cust_no
JOIN n03_g_grade g ON c.grade = g.grade JOIN n03_g_product p ON i.prod_cd = p.prod_cd;
GO
CREATE OR ALTER VIEW exp03_04_g4 AS SELECT * FROM n03_g_ledger;
GO
EXEC lab_check N'03-G4-lossless', N'ans03_04_g4', N'exp03_04_g4';
SELECT (SELECT COUNT(*) FROM n03_g_grade) grades, (SELECT COUNT(*) FROM n03_g_cust) custs, (SELECT COUNT(*) FROM n03_g_product) products,
       (SELECT COUNT(*) FROM n03_g_order) orders, (SELECT COUNT(*) FROM n03_g_item) items;
GO
