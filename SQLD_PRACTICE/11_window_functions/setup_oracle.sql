-- 11_window_functions/setup_oracle.sql (재실행 가능)  데이터: [PDF E-32] BOOKSHELF 8권 (추출본 값 그대로)
EXEC lab_drop('BOOKSHELF')
CREATE TABLE bookshelf (book_name VARCHAR2(40 CHAR) CONSTRAINT pk_bookshelf PRIMARY KEY, writer VARCHAR2(30 CHAR),
                        publisher VARCHAR2(20 CHAR), price NUMBER NOT NULL);
INSERT INTO bookshelf VALUES ('멋진 신세계', '올더스 헉슬리', '문학동네', 13000);
INSERT INTO bookshelf VALUES ('천개의 찬란한 태양', '할레드 호세이니', '문학동네', 16000);
INSERT INTO bookshelf VALUES ('어린 왕자', '앙투안 드 생텍쥐페리', '민음사', 8800);
INSERT INTO bookshelf VALUES ('참을 수 없는 존재의 가벼움', '밀란 쿤데라', '민음사', 11000);
INSERT INTO bookshelf VALUES ('데미안', '헤르만 헤세', '열린책들', 12000);
INSERT INTO bookshelf VALUES ('1984', '조지 오웰', '열린책들', 13500);
INSERT INTO bookshelf VALUES ('창문 넘어 도망친 100세 노인', '요나스 요나슨', '열린책들', 15200);
INSERT INTO bookshelf VALUES ('나미야 잡화점의 기적', '히가시노 게이고', '현대문학', 14800);
COMMIT;
