-- 10_grouping_extensions/setup_oracle.sql (재실행 가능)
--   [가상] ANIMAL_HOTEL: PDF E-28 은 결과표만 있고 원본 행이 추출본에 없어, 성질만 재현하는 학습용 가상 데이터를 만들었다.
--   [가상] AH_NULL: 실제 NULL 값이 있는 그룹과 소계 NULL 을 구별하는 실험
EXEC lab_drop('ANIMAL_HOTEL')
EXEC lab_drop('AH_NULL')
CREATE TABLE animal_hotel (id NUMBER CONSTRAINT pk_animal_hotel PRIMARY KEY, species VARCHAR2(10 CHAR) NOT NULL,
                           breed VARCHAR2(20 CHAR) NOT NULL, age NUMBER(4,1) NOT NULL);
INSERT INTO animal_hotel VALUES (1, '강아지', '말티즈', 6);
INSERT INTO animal_hotel VALUES (2, '강아지', '말티즈', 6);
INSERT INTO animal_hotel VALUES (3, '강아지', '푸들', 7);
INSERT INTO animal_hotel VALUES (4, '강아지', '푸들', 6);
INSERT INTO animal_hotel VALUES (5, '고양이', '샴', 3);
INSERT INTO animal_hotel VALUES (6, '고양이', '샴', 4);
INSERT INTO animal_hotel VALUES (7, '고양이', '페르시안', 5);
INSERT INTO animal_hotel VALUES (8, '토끼', '미니렉스', 2);
CREATE TABLE ah_null (species VARCHAR2(5), breed VARCHAR2(5), cnt NUMBER);
INSERT INTO ah_null VALUES ('A', 'x', 1);
INSERT INTO ah_null VALUES ('A', NULL, 3);
INSERT INTO ah_null VALUES ('B', 'y', 5);
COMMIT;
