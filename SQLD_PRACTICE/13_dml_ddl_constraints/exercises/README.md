# 13 직접 작성 문제 (G) — 사용법

1. 각 `exNN_*.md`의 문제만 보고 SQL을 작성한다. 정답 SQL은 `../answers/`에 있다. **먼저 보지 않는다.**
2. 검증하는 법: `../answers/exNN_*_answer_oracle.sql`(또는 `_answer_sqlserver.sql`)에서 `CREATE ... VIEW ans13_NN_gK AS` 아래 본문을 자기 SQL로 바꾸고 그 파일을 실행한다.
   `lab_check`가 기대 결과 뷰(`exp13_NN_gK`)와 집합·행 수를 비교해 `CHECK_PASS` / `CHECK_FAIL`을 출력한다.
3. 뷰 안에는 ORDER BY를 쓰지 않는다(SQL Server는 TOP 없이 뷰에 ORDER BY를 둘 수 없다). 순서는 비교하지 않는다.
4. 출력 열 이름과 순서는 문제에 적힌 대로 맞춘다. 비교는 열 위치 기준이다.
5. 이 단원의 정답 파일은 손으로 작성했다. DML·DDL을 실행한 뒤 **결과 테이블(또는 데이터 사전)을 보여 주는 뷰**를 기대 결과와 비교한다.
   직접 풀 때는 answers 파일의 "-- [학습자 작성 구간]" 부분을 자기 SQL로 바꾼다.
