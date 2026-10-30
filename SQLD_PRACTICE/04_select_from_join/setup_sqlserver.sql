-- =====================================================================
-- 04_select_from_join/setup_sqlserver.sql  (재실행 가능, SQLD_LAB DB 전용)
-- [PDF] = 텍스트 추출본 데이터, [가상] = 학습용 가상 데이터. 상세는 setup_oracle.sql 주석과 같다.
-- 한글은 NVARCHAR + N'' 리터럴로 저장한다(VARCHAR 는 DB 기본 데이터 정렬의 코드 페이지에 따라 깨질 수 있다).
-- =====================================================================
USE SQLD_LAB;
GO
IF DB_NAME() <> N'SQLD_LAB' THROW 50000, N'SQLD_LAB DB에서만 실행한다.', 1;
DROP TABLE IF EXISTS book_list, publisher, nj_t1, nj_t2, nj_t3, cj_t1, cj_t2, pdf_emp_sg, pdf_salgrade;
DROP TABLE IF EXISTS employees, staff, player, team, stadium, order_line, orders, cust, enroll, req_course;
GO
CREATE TABLE publisher (publisher_id INT CONSTRAINT pk_publisher PRIMARY KEY, publisher_name NVARCHAR(30) NOT NULL);
CREATE TABLE book_list (book_id VARCHAR(3) CONSTRAINT pk_book_list PRIMARY KEY, book_name NVARCHAR(40) NOT NULL,
                        writer NVARCHAR(40), publisher_id INT);
INSERT INTO publisher VALUES (1, N'열린책들'), (2, N'민음사'), (3, N'현대문학'), (4, N'한빛미디어');
INSERT INTO book_list VALUES ('b01', N'데미안', N'헤르만 헤세', 1), ('b02', N'어린왕자', N'앙투안 드 생텍쥐페리', 2),
                             ('b03', N'1984', N'조지 오웰', 8), ('b04', N'나미야 잡화점의 기적', N'히가시노 게이고', 3);

CREATE TABLE nj_t1 (no INT, name NVARCHAR(10));
CREATE TABLE nj_t2 (no INT, name NVARCHAR(10));
CREATE TABLE nj_t3 (no INT, pos  NVARCHAR(10));
INSERT INTO nj_t1 VALUES (1, N'A'), (2, N'B'), (NULL, N'C');
INSERT INTO nj_t2 VALUES (1, N'A'), (2, N'C'), (NULL, N'C');
INSERT INTO nj_t3 VALUES (1, N'탑'), (2, N'미드'), (1, N'정글'), (NULL, N'서포터');

CREATE TABLE cj_t1 (x1 VARCHAR(5), x2 INT);
CREATE TABLE cj_t2 (x1 VARCHAR(5), y2 DECIMAL(3,1));
INSERT INTO cj_t1 VALUES ('a', 12), ('b', 3), (NULL, 8);
INSERT INTO cj_t2 VALUES ('a', 4.8), ('b', 1.2), ('C', 3.6);

CREATE TABLE pdf_emp_sg (ename VARCHAR(10) CONSTRAINT pk_pdf_emp_sg PRIMARY KEY, sal INT);
CREATE TABLE pdf_salgrade (grade INT CONSTRAINT pk_pdf_salgrade PRIMARY KEY, losal INT, hisal INT);
INSERT INTO pdf_emp_sg VALUES ('SMITH', 800), ('ALLEN', 1600), ('WARD', 1250), ('JONES', 2975), ('MARTIN', 1280), ('KING', 8000);
INSERT INTO pdf_salgrade VALUES (1, 800, 1200), (2, 1201, 1400), (3, 1401, 2000), (4, 2001, 3000), (5, 3001, 9999);

CREATE TABLE employees (emp_id INT CONSTRAINT pk_employees PRIMARY KEY, name VARCHAR(10) NOT NULL,
                        mgr_id INT CONSTRAINT fk_employees_mgr REFERENCES employees(emp_id));
INSERT INTO employees VALUES (100, 'KING', NULL), (101, 'ALLEN', 100), (102, 'WARD', 100),
                             (103, 'JONES', 102), (104, 'MARTIN', 101), (105, 'SMITH', 103);

CREATE TABLE staff (staff_id INT CONSTRAINT pk_staff PRIMARY KEY, name NVARCHAR(20) NOT NULL,
                    boss_id INT CONSTRAINT fk_staff_boss REFERENCES staff(staff_id));
INSERT INTO staff VALUES (1, N'나사장', NULL), (2, N'김철수', 1), (3, N'이지현', 1), (4, N'황수지', 2), (5, N'박현석', 3);

CREATE TABLE stadium (stadium_id VARCHAR(3) CONSTRAINT pk_stadium PRIMARY KEY, stadium_name NVARCHAR(30) NOT NULL);
CREATE TABLE team (team_id VARCHAR(3) CONSTRAINT pk_team PRIMARY KEY, team_name NVARCHAR(20) NOT NULL,
                   region_name NVARCHAR(10), stadium_id VARCHAR(3) CONSTRAINT fk_team_stadium REFERENCES stadium(stadium_id));
CREATE TABLE player (player_id INT CONSTRAINT pk_player PRIMARY KEY, player_name NVARCHAR(20) NOT NULL,
                     position VARCHAR(2), back_no INT, team_id VARCHAR(3) CONSTRAINT fk_player_team REFERENCES team(team_id));
INSERT INTO stadium VALUES ('S01', N'하늘경기장'), ('S02', N'바다경기장'), ('S03', N'숲경기장');
INSERT INTO team VALUES ('K01', N'하늘FC', N'서울', 'S01'), ('K02', N'바다유나이티드', N'부산', 'S02'), ('K03', N'숲시티', N'대전', NULL);
INSERT INTO player VALUES (1, N'강감찬', 'GK', 1, 'K01'), (2, N'을지문', 'DF', 4, 'K01'), (3, N'이순신', 'GK', 21, 'K02'),
                          (4, N'권율', 'FW', 9, 'K02'), (5, N'김유신', 'GK', 31, 'K03'), (6, N'연개소', 'MF', 8, NULL);

CREATE TABLE cust (cust_id VARCHAR(3) CONSTRAINT pk_cust PRIMARY KEY, cust_name NVARCHAR(20) NOT NULL, grade VARCHAR(10));
CREATE TABLE orders (order_id INT CONSTRAINT pk_orders PRIMARY KEY,
                     cust_id VARCHAR(3) NOT NULL CONSTRAINT fk_orders_cust REFERENCES cust(cust_id),
                     order_date DATE NOT NULL, status VARCHAR(10) NOT NULL, amount INT NOT NULL);
CREATE TABLE order_line (order_id INT CONSTRAINT fk_ol_orders REFERENCES orders(order_id), line_no INT,
                         item NVARCHAR(20) NOT NULL, qty INT NOT NULL, CONSTRAINT pk_order_line PRIMARY KEY (order_id, line_no));
INSERT INTO cust VALUES ('C01', N'가나', 'VIP'), ('C02', N'다라', 'GOLD'), ('C03', N'마바', 'GOLD'), ('C04', N'사아', NULL);
INSERT INTO orders VALUES (1001, 'C01', '2024-03-01', 'PAID', 30000), (1002, 'C01', '2024-03-05', 'CANCELED', 12000),
                          (1003, 'C02', '2024-03-07', 'PAID', 50000), (1004, 'C03', '2024-03-09', 'CANCELED', 8000);
INSERT INTO order_line VALUES (1001, 1, N'펜', 2), (1001, 2, N'노트', 1), (1001, 3, N'자', 4), (1002, 1, N'펜', 1),
                              (1003, 1, N'가방', 1), (1003, 2, N'펜', 3), (1004, 1, N'자', 1);

CREATE TABLE enroll (student NVARCHAR(10), course VARCHAR(10), CONSTRAINT pk_enroll PRIMARY KEY (student, course));
CREATE TABLE req_course (course VARCHAR(10) CONSTRAINT pk_req_course PRIMARY KEY);
INSERT INTO req_course VALUES ('DB'), ('SQL');
INSERT INTO enroll VALUES (N'민수', 'DB'), (N'민수', 'SQL'), (N'민수', 'AI'), (N'지영', 'DB'), (N'하늘', 'SQL'), (N'하늘', 'DB');
GO
PRINT N'04 setup done';
