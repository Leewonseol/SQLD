-- =====================================================================
-- 04_select_from_join/setup_oracle.sql  (재실행 가능, SQLD_LAB 스키마 전용)
-- 데이터 출처 표기
--   [PDF] = 텍스트 추출본에 값이 그대로 있는 데이터 (E-xx 는 _source/extract_index.md)
--   [가상] = 학습용 가상 데이터
-- =====================================================================
EXEC lab_drop('BOOK_LIST')
EXEC lab_drop('PUBLISHER')
EXEC lab_drop('NJ_T1')
EXEC lab_drop('NJ_T2')
EXEC lab_drop('NJ_T3')
EXEC lab_drop('CJ_T1')
EXEC lab_drop('CJ_T2')
EXEC lab_drop('PDF_EMP_SG')
EXEC lab_drop('PDF_SALGRADE')
EXEC lab_drop('EMPLOYEES')
EXEC lab_drop('STAFF')
EXEC lab_drop('PLAYER')
EXEC lab_drop('TEAM')
EXEC lab_drop('STADIUM')
EXEC lab_drop('CUST')
EXEC lab_drop('ORDERS')
EXEC lab_drop('ORDER_LINE')
EXEC lab_drop('ENROLL')
EXEC lab_drop('REQ_COURSE')

-- [PDF E-19] 도서·출판사. Publisher_id=8 인 b03 은 출판사가 없다, 4 한빛미디어는 책이 없다.
CREATE TABLE publisher (
  publisher_id   NUMBER        CONSTRAINT pk_publisher PRIMARY KEY,
  publisher_name VARCHAR2(30)  NOT NULL
);
-- FK를 일부러 두지 않았다: PDF 데이터에 존재하지 않는 출판사(8)를 참조하는 행이 있기 때문.
CREATE TABLE book_list (
  book_id      VARCHAR2(3)   CONSTRAINT pk_book_list PRIMARY KEY,
  book_name    VARCHAR2(40)  NOT NULL,
  writer       VARCHAR2(40),
  publisher_id NUMBER
);
INSERT INTO publisher VALUES (1, '열린책들');
INSERT INTO publisher VALUES (2, '민음사');
INSERT INTO publisher VALUES (3, '현대문학');
INSERT INTO publisher VALUES (4, '한빛미디어');
INSERT INTO book_list VALUES ('b01', '데미안', '헤르만 헤세', 1);
INSERT INTO book_list VALUES ('b02', '어린왕자', '앙투안 드 생텍쥐페리', 2);
INSERT INTO book_list VALUES ('b03', '1984', '조지 오웰', 8);
INSERT INTO book_list VALUES ('b04', '나미야 잡화점의 기적', '히가시노 게이고', 3);

-- [PDF E-17] NATURAL JOIN 예시 테이블 (PK 없음: PDF 예시에 NULL 키가 있다)
CREATE TABLE nj_t1 (no NUMBER, name VARCHAR2(10));
CREATE TABLE nj_t2 (no NUMBER, name VARCHAR2(10));
CREATE TABLE nj_t3 (no NUMBER, pos  VARCHAR2(10));
INSERT INTO nj_t1 VALUES (1, 'A');
INSERT INTO nj_t1 VALUES (2, 'B');
INSERT INTO nj_t1 VALUES (NULL, 'C');
INSERT INTO nj_t2 VALUES (1, 'A');
INSERT INTO nj_t2 VALUES (2, 'C');
INSERT INTO nj_t2 VALUES (NULL, 'C');
INSERT INTO nj_t3 VALUES (1, '탑');
INSERT INTO nj_t3 VALUES (2, '미드');
INSERT INTO nj_t3 VALUES (1, '정글');
INSERT INTO nj_t3 VALUES (NULL, '서포터');

-- [PDF E-18] CROSS JOIN 예시
CREATE TABLE cj_t1 (x1 VARCHAR2(5), x2 NUMBER);
CREATE TABLE cj_t2 (x1 VARCHAR2(5), y2 NUMBER(3,1));
INSERT INTO cj_t1 VALUES ('a', 12);
INSERT INTO cj_t1 VALUES ('b', 3);
INSERT INTO cj_t1 VALUES (NULL, 8);
INSERT INTO cj_t2 VALUES ('a', 4.8);
INSERT INTO cj_t2 VALUES ('b', 1.2);
INSERT INTO cj_t2 VALUES ('C', 3.6);

-- [PDF E-10] NON EQUI JOIN 예시 (PDF 고유 값: MARTIN 1280, KING 8000, 1등급 800~1200)
CREATE TABLE pdf_emp_sg (ename VARCHAR2(10) CONSTRAINT pk_pdf_emp_sg PRIMARY KEY, sal NUMBER);
CREATE TABLE pdf_salgrade (grade NUMBER CONSTRAINT pk_pdf_salgrade PRIMARY KEY, losal NUMBER, hisal NUMBER);
INSERT INTO pdf_emp_sg VALUES ('SMITH', 800);
INSERT INTO pdf_emp_sg VALUES ('ALLEN', 1600);
INSERT INTO pdf_emp_sg VALUES ('WARD', 1250);
INSERT INTO pdf_emp_sg VALUES ('JONES', 2975);
INSERT INTO pdf_emp_sg VALUES ('MARTIN', 1280);
INSERT INTO pdf_emp_sg VALUES ('KING', 8000);
INSERT INTO pdf_salgrade VALUES (1,  800, 1200);
INSERT INTO pdf_salgrade VALUES (2, 1201, 1400);
INSERT INTO pdf_salgrade VALUES (3, 1401, 2000);
INSERT INTO pdf_salgrade VALUES (4, 2001, 3000);
INSERT INTO pdf_salgrade VALUES (5, 3001, 9999);

-- [PDF E-12] SELF JOIN 예시
CREATE TABLE employees (
  emp_id NUMBER       CONSTRAINT pk_employees PRIMARY KEY,
  name   VARCHAR2(10) NOT NULL,
  mgr_id NUMBER       CONSTRAINT fk_employees_mgr REFERENCES employees(emp_id)
);
INSERT INTO employees VALUES (100, 'KING',   NULL);
INSERT INTO employees VALUES (101, 'ALLEN',  100);
INSERT INTO employees VALUES (102, 'WARD',   100);
INSERT INTO employees VALUES (103, 'JONES',  102);
INSERT INTO employees VALUES (104, 'MARTIN', 101);
INSERT INTO employees VALUES (105, 'SMITH',  103);

-- [PDF E-02] 직원·상사. 박현석의 직원ID는 추출본에서 빠져 있어 5로 보충했다(학습용 보충).
CREATE TABLE staff (
  staff_id NUMBER       CONSTRAINT pk_staff PRIMARY KEY,
  name     VARCHAR2(20) NOT NULL,
  boss_id  NUMBER       CONSTRAINT fk_staff_boss REFERENCES staff(staff_id)
);
INSERT INTO staff VALUES (1, '나사장', NULL);
INSERT INTO staff VALUES (2, '김철수', 1);
INSERT INTO staff VALUES (3, '이지현', 1);
INSERT INTO staff VALUES (4, '황수지', 2);
INSERT INTO staff VALUES (5, '박현석', 3);

-- [가상] 선수·팀·경기장 (PDF는 PLAYER/TEAM/STADIUM 쿼리만 있고 데이터가 추출본에 없다)
CREATE TABLE stadium (
  stadium_id   VARCHAR2(3)  CONSTRAINT pk_stadium PRIMARY KEY,
  stadium_name VARCHAR2(30) NOT NULL
);
CREATE TABLE team (
  team_id     VARCHAR2(3)  CONSTRAINT pk_team PRIMARY KEY,
  team_name   VARCHAR2(20 CHAR) NOT NULL,
  region_name VARCHAR2(10),
  stadium_id  VARCHAR2(3)  CONSTRAINT fk_team_stadium REFERENCES stadium(stadium_id)
);
CREATE TABLE player (
  player_id   NUMBER       CONSTRAINT pk_player PRIMARY KEY,
  player_name VARCHAR2(20) NOT NULL,
  position    VARCHAR2(2),
  back_no     NUMBER,
  team_id     VARCHAR2(3)  CONSTRAINT fk_player_team REFERENCES team(team_id)
);
INSERT INTO stadium VALUES ('S01', '하늘경기장');
INSERT INTO stadium VALUES ('S02', '바다경기장');
INSERT INTO stadium VALUES ('S03', '숲경기장');
INSERT INTO team VALUES ('K01', '하늘FC', '서울', 'S01');
INSERT INTO team VALUES ('K02', '바다유나이티드', '부산', 'S02');
INSERT INTO team VALUES ('K03', '숲시티', '대전', NULL);
INSERT INTO player VALUES (1, '강감찬', 'GK', 1,  'K01');
INSERT INTO player VALUES (2, '을지문', 'DF', 4,  'K01');
INSERT INTO player VALUES (3, '이순신', 'GK', 21, 'K02');
INSERT INTO player VALUES (4, '권율',   'FW', 9,  'K02');
INSERT INTO player VALUES (5, '김유신', 'GK', 31, 'K03');
INSERT INTO player VALUES (6, '연개소', 'MF', 8,  NULL);

-- [가상] 고객·주문·주문상세 (1:N 행 증가, ON/WHERE 실험)
CREATE TABLE cust (
  cust_id   VARCHAR2(3)  CONSTRAINT pk_cust PRIMARY KEY,
  cust_name VARCHAR2(20) NOT NULL,
  grade     VARCHAR2(10)
);
CREATE TABLE orders (
  order_id   NUMBER       CONSTRAINT pk_orders PRIMARY KEY,
  cust_id    VARCHAR2(3)  NOT NULL CONSTRAINT fk_orders_cust REFERENCES cust(cust_id),
  order_date DATE         NOT NULL,
  status     VARCHAR2(10) NOT NULL,
  amount     NUMBER       NOT NULL
);
CREATE TABLE order_line (
  order_id NUMBER      CONSTRAINT fk_ol_orders REFERENCES orders(order_id),
  line_no  NUMBER,
  item     VARCHAR2(20) NOT NULL,
  qty      NUMBER       NOT NULL,
  CONSTRAINT pk_order_line PRIMARY KEY (order_id, line_no)
);
INSERT INTO cust VALUES ('C01', '가나', 'VIP');
INSERT INTO cust VALUES ('C02', '다라', 'GOLD');
INSERT INTO cust VALUES ('C03', '마바', 'GOLD');
INSERT INTO cust VALUES ('C04', '사아', NULL);
INSERT INTO orders VALUES (1001, 'C01', DATE '2024-03-01', 'PAID',     30000);
INSERT INTO orders VALUES (1002, 'C01', DATE '2024-03-05', 'CANCELED', 12000);
INSERT INTO orders VALUES (1003, 'C02', DATE '2024-03-07', 'PAID',     50000);
INSERT INTO orders VALUES (1004, 'C03', DATE '2024-03-09', 'CANCELED',  8000);
INSERT INTO order_line VALUES (1001, 1, '펜',   2);
INSERT INTO order_line VALUES (1001, 2, '노트', 1);
INSERT INTO order_line VALUES (1001, 3, '자',   4);
INSERT INTO order_line VALUES (1002, 1, '펜',   1);
INSERT INTO order_line VALUES (1003, 1, '가방', 1);
INSERT INTO order_line VALUES (1003, 2, '펜',   3);
INSERT INTO order_line VALUES (1004, 1, '자',   1);

-- [가상] DIVIDE(나누기) 실험: 필수 과목을 모두 수강한 학생
CREATE TABLE enroll (student VARCHAR2(10), course VARCHAR2(10), CONSTRAINT pk_enroll PRIMARY KEY (student, course));
CREATE TABLE req_course (course VARCHAR2(10) CONSTRAINT pk_req_course PRIMARY KEY);
INSERT INTO req_course VALUES ('DB');
INSERT INTO req_course VALUES ('SQL');
INSERT INTO enroll VALUES ('민수', 'DB');
INSERT INTO enroll VALUES ('민수', 'SQL');
INSERT INTO enroll VALUES ('민수', 'AI');
INSERT INTO enroll VALUES ('지영', 'DB');
INSERT INTO enroll VALUES ('하늘', 'SQL');
INSERT INTO enroll VALUES ('하늘', 'DB');
COMMIT;
PROMPT 04 setup done
