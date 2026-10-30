-- 11_window_functions/setup_sqlserver.sql (재실행 가능)  데이터: [PDF E-32] BOOKSHELF
USE SQLD_LAB;
GO
IF DB_NAME() <> N'SQLD_LAB' THROW 50000, N'SQLD_LAB DB에서만 실행한다.', 1;
DROP TABLE IF EXISTS bookshelf;
GO
CREATE TABLE bookshelf (book_name NVARCHAR(40) CONSTRAINT pk_bookshelf PRIMARY KEY, writer NVARCHAR(30), publisher NVARCHAR(20), price DECIMAL(10,2) NOT NULL);
INSERT INTO bookshelf VALUES (N'멋진 신세계', N'올더스 헉슬리', N'문학동네', 13000), (N'천개의 찬란한 태양', N'할레드 호세이니', N'문학동네', 16000),
  (N'어린 왕자', N'앙투안 드 생텍쥐페리', N'민음사', 8800), (N'참을 수 없는 존재의 가벼움', N'밀란 쿤데라', N'민음사', 11000),
  (N'데미안', N'헤르만 헤세', N'열린책들', 12000), (N'1984', N'조지 오웰', N'열린책들', 13500),
  (N'창문 넘어 도망친 100세 노인', N'요나스 요나슨', N'열린책들', 15200), (N'나미야 잡화점의 기적', N'히가시노 게이고', N'현대문학', 14800);
GO
