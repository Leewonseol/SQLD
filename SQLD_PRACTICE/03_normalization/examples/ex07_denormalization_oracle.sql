-- ex07 반정규화와 중복 데이터 관리 (요구목록 §6 "반정규화와 중복 데이터 관리")  | Oracle
-- 주문 합계(파생 컬럼)를 주문 테이블에 중복 저장 -> 조회는 빨라지지만 일관성을 따로 지켜야 한다
EXEC lab_drop('N03_OLINE')
EXEC lab_drop('N03_ORD')
CREATE TABLE n03_ord (ord_id NUMBER PRIMARY KEY, total_amt NUMBER DEFAULT 0 NOT NULL);
CREATE TABLE n03_oline (ord_id NUMBER REFERENCES n03_ord(ord_id), line_no NUMBER, amt NUMBER NOT NULL, PRIMARY KEY (ord_id, line_no));
INSERT INTO n03_ord (ord_id) VALUES (1);
INSERT INTO n03_oline VALUES (1, 1, 100);
INSERT INTO n03_oline VALUES (1, 2, 200);
UPDATE n03_ord o SET total_amt = (SELECT SUM(amt) FROM n03_oline l WHERE l.ord_id = o.ord_id);
COMMIT;
PROMPT == [Q1] 반정규화 값과 원천 값의 일치 검사 쿼리 (불일치 행 수)
SELECT COUNT(*) AS mismatches FROM n03_ord o WHERE o.total_amt <> (SELECT NVL(SUM(amt), 0) FROM n03_oline l WHERE l.ord_id = o.ord_id);

PROMPT == [Q2] 상세만 바꾸고 합계를 갱신하지 않으면 불일치가 생긴다 (갱신 이상의 재등장)
UPDATE n03_oline SET amt = 500 WHERE ord_id = 1 AND line_no = 2;
SELECT COUNT(*) AS mismatches FROM n03_ord o WHERE o.total_amt <> (SELECT NVL(SUM(amt), 0) FROM n03_oline l WHERE l.ord_id = o.ord_id);
ROLLBACK;

PROMPT == [Q3] 트리거로 동기화: 상세가 바뀌면 합계를 다시 계산 (문장 단위 트리거)
CREATE OR REPLACE TRIGGER trg_n03_oline_sync AFTER INSERT OR UPDATE OR DELETE ON n03_oline
BEGIN
  UPDATE n03_ord o SET total_amt = (SELECT NVL(SUM(amt), 0) FROM n03_oline l WHERE l.ord_id = o.ord_id);
END;
/
UPDATE n03_oline SET amt = 500 WHERE ord_id = 1 AND line_no = 2;
INSERT INTO n03_oline VALUES (1, 3, 50);
SELECT ord_id, total_amt FROM n03_ord;
SELECT COUNT(*) AS mismatches FROM n03_ord o WHERE o.total_amt <> (SELECT NVL(SUM(amt), 0) FROM n03_oline l WHERE l.ord_id = o.ord_id);
ROLLBACK;
EXEC lab_drop('TRG_N03_OLINE_SYNC', 'TRIGGER')
EXEC lab_drop('N03_OLINE')
EXEC lab_drop('N03_ORD')
