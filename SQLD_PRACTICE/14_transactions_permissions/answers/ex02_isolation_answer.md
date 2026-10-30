# ex02 정답 (H)
| 경우 | B가 읽는 값 | 대기 | 근거 |
|---|---|---|---|
| (1) Oracle 기본 READ COMMITTED | 100(이전 커밋 값) | 없음 | `expected_results/ex02_concurrency_demo.txt` 실행 결과(0.2초) |
| (2) SQL Server 기본 READ COMMITTED, RCSI OFF | A가 끝난 뒤 커밋된 값 | A가 COMMIT/ROLLBACK 할 때까지 | 같은 파일(3.1초 대기) |
| (3) SQL Server READ UNCOMMITTED | 0(커밋 안 된 값, Dirty Read) | 없음 | 같은 파일(999를 읽음) |
| (4) SQL Server SNAPSHOT | 100(트랜잭션 시작 시점 버전) | 없음 | **미실행**: 이 DB는 ALLOW_SNAPSHOT_ISOLATION OFF라 Msg 3952(ex02 Q3). 공식 문서 기준 답 |
검증 방식: 두 세션이 필요해 lab_check 대신 `tools/concurrency_demo.py`로 검증했다.
