-- 15_integrated_exam/setup_sqlserver.sql (재실행 가능)  데이터: [가상] "동영상 스트리밍 서비스"
USE SQLD_LAB;
GO
IF DB_NAME() <> N'SQLD_LAB' THROW 50000, N'SQLD_LAB DB에서만 실행한다.', 1;
DROP TABLE IF EXISTS x15_wish, x15_watch, x15_payment, x15_content_nopk, x15_content, x15_customer;
GO
CREATE TABLE x15_customer (cust_id VARCHAR(3) CONSTRAINT pk_x15_customer PRIMARY KEY, name NVARCHAR(10) NOT NULL, grade VARCHAR(5));
CREATE TABLE x15_content  (content_id VARCHAR(3) CONSTRAINT pk_x15_content PRIMARY KEY, title NVARCHAR(20) NOT NULL, genre VARCHAR(5) NOT NULL);
CREATE TABLE x15_content_nopk (content_id VARCHAR(3), title NVARCHAR(20), genre VARCHAR(5));
CREATE TABLE x15_watch (cust_id VARCHAR(3) CONSTRAINT fk_x15_watch_cust REFERENCES x15_customer(cust_id),
                        content_id VARCHAR(3) CONSTRAINT fk_x15_watch_content REFERENCES x15_content(content_id),
                        watch_dt DATE, CONSTRAINT pk_x15_watch PRIMARY KEY (cust_id, content_id, watch_dt));
CREATE TABLE x15_wish  (cust_id VARCHAR(3) CONSTRAINT fk_x15_wish_cust REFERENCES x15_customer(cust_id),
                        content_id VARCHAR(3) CONSTRAINT fk_x15_wish_content REFERENCES x15_content(content_id),
                        CONSTRAINT pk_x15_wish PRIMARY KEY (cust_id, content_id));
CREATE TABLE x15_payment (pay_id INT CONSTRAINT pk_x15_payment PRIMARY KEY, cust_id VARCHAR(3) CONSTRAINT fk_x15_payment_cust REFERENCES x15_customer(cust_id),
                          amount INT, pay_dt DATE NOT NULL);
INSERT INTO x15_customer VALUES ('C1', N'가', 'VIP'), ('C2', N'나', 'GOLD'), ('C3', N'다', 'GOLD'), ('C4', N'라', NULL);
INSERT INTO x15_content VALUES ('T1', N'SQL 강의', 'EDU'), ('T2', N'액션 영화', 'MOVIE'), ('T3', N'바다 다큐', 'DOCU'), ('T4', N'음악 쇼', 'SHOW');
INSERT INTO x15_content_nopk SELECT content_id, title, genre FROM x15_content;
INSERT INTO x15_content_nopk VALUES ('T1', N'SQL강의(구)', 'EDU');
INSERT INTO x15_watch VALUES ('C1', 'T1', '2024-03-01'), ('C1', 'T1', '2024-03-05'), ('C1', 'T2', '2024-03-02'), ('C2', 'T2', '2024-03-03'), ('C3', 'T3', '2024-03-04');
INSERT INTO x15_wish VALUES ('C1', 'T2'), ('C1', 'T3'), ('C2', 'T1'), ('C2', 'T2'), ('C4', 'T4');
INSERT INTO x15_payment VALUES (1, 'C1', 10000, '2024-03-01'), (2, 'C1', 10000, '2024-04-01'), (3, 'C2', NULL, '2024-03-15'),
                               (4, 'C3', 5000, '2024-03-20'), (5, NULL, 3000, '2024-03-21');
GO
