-- 15_integrated_exam/setup_oracle.sql (재실행 가능)  데이터: [가상] 학습용 가상 데이터 "동영상 스트리밍 서비스"
EXEC lab_drop('X15_WISH')
EXEC lab_drop('X15_WATCH')
EXEC lab_drop('X15_PAYMENT')
EXEC lab_drop('X15_CONTENT_NOPK')
EXEC lab_drop('X15_CONTENT')
EXEC lab_drop('X15_CUSTOMER')
CREATE TABLE x15_customer (cust_id VARCHAR2(3) CONSTRAINT pk_x15_customer PRIMARY KEY, name VARCHAR2(10 CHAR) NOT NULL, grade VARCHAR2(5));
CREATE TABLE x15_content  (content_id VARCHAR2(3) CONSTRAINT pk_x15_content PRIMARY KEY, title VARCHAR2(20 CHAR) NOT NULL, genre VARCHAR2(5) NOT NULL);
-- PK 가 없는 콘텐츠 마스터(이관 과정에서 T1 이 두 번 들어간 상황)
CREATE TABLE x15_content_nopk (content_id VARCHAR2(3), title VARCHAR2(20 CHAR), genre VARCHAR2(5));
CREATE TABLE x15_watch (cust_id VARCHAR2(3) CONSTRAINT fk_x15_watch_cust REFERENCES x15_customer(cust_id),
                        content_id VARCHAR2(3) CONSTRAINT fk_x15_watch_content REFERENCES x15_content(content_id),
                        watch_dt DATE, CONSTRAINT pk_x15_watch PRIMARY KEY (cust_id, content_id, watch_dt));
CREATE TABLE x15_wish  (cust_id VARCHAR2(3) CONSTRAINT fk_x15_wish_cust REFERENCES x15_customer(cust_id),
                        content_id VARCHAR2(3) CONSTRAINT fk_x15_wish_content REFERENCES x15_content(content_id),
                        CONSTRAINT pk_x15_wish PRIMARY KEY (cust_id, content_id));
-- cust_id NULL = 비회원 결제, amount NULL = 결제 대기
CREATE TABLE x15_payment (pay_id NUMBER CONSTRAINT pk_x15_payment PRIMARY KEY, cust_id VARCHAR2(3) CONSTRAINT fk_x15_payment_cust REFERENCES x15_customer(cust_id),
                          amount NUMBER, pay_dt DATE NOT NULL);
INSERT INTO x15_customer VALUES ('C1', '가', 'VIP');
INSERT INTO x15_customer VALUES ('C2', '나', 'GOLD');
INSERT INTO x15_customer VALUES ('C3', '다', 'GOLD');
INSERT INTO x15_customer VALUES ('C4', '라', NULL);
INSERT INTO x15_content VALUES ('T1', 'SQL 강의', 'EDU');
INSERT INTO x15_content VALUES ('T2', '액션 영화', 'MOVIE');
INSERT INTO x15_content VALUES ('T3', '바다 다큐', 'DOCU');
INSERT INTO x15_content VALUES ('T4', '음악 쇼', 'SHOW');
INSERT INTO x15_content_nopk SELECT content_id, title, genre FROM x15_content;
INSERT INTO x15_content_nopk VALUES ('T1', 'SQL강의(구)', 'EDU');
INSERT INTO x15_watch VALUES ('C1', 'T1', DATE '2024-03-01');
INSERT INTO x15_watch VALUES ('C1', 'T1', DATE '2024-03-05');
INSERT INTO x15_watch VALUES ('C1', 'T2', DATE '2024-03-02');
INSERT INTO x15_watch VALUES ('C2', 'T2', DATE '2024-03-03');
INSERT INTO x15_watch VALUES ('C3', 'T3', DATE '2024-03-04');
INSERT INTO x15_wish VALUES ('C1', 'T2');
INSERT INTO x15_wish VALUES ('C1', 'T3');
INSERT INTO x15_wish VALUES ('C2', 'T1');
INSERT INTO x15_wish VALUES ('C2', 'T2');
INSERT INTO x15_wish VALUES ('C4', 'T4');
INSERT INTO x15_payment VALUES (1, 'C1', 10000, DATE '2024-03-01');
INSERT INTO x15_payment VALUES (2, 'C1', 10000, DATE '2024-04-01');
INSERT INTO x15_payment VALUES (3, 'C2', NULL, DATE '2024-03-15');
INSERT INTO x15_payment VALUES (4, 'C3', 5000, DATE '2024-03-20');
INSERT INTO x15_payment VALUES (5, NULL, 3000, DATE '2024-03-21');
COMMIT;
