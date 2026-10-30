# ex04 직접 작성 문제
G1. 다음 각 경우 Oracle과 SQL Server에서 '마지막 SELECT COUNT(*)' 결과를 예측하라. 테이블 t에는 처음에 3행이 있고 자동 커밋 모드다.
  (1) DELETE FROM t; ROLLBACK;  (2) TRUNCATE TABLE t; ROLLBACK;  (3) [SQL Server] BEGIN TRAN; TRUNCATE TABLE t; ROLLBACK;  (4) [Oracle] DELETE FROM t; CREATE TABLE x (a NUMBER); ROLLBACK;
