-- ex02 트랜잭션 격리 수준  | SQL Server (4가지 ANSI 수준 + SNAPSHOT 을 모두 지원)
DROP TABLE IF EXISTS d14_iso;
CREATE TABLE d14_iso (id INT PRIMARY KEY, v INT);
INSERT INTO d14_iso VALUES (1, 100);
GO
PRINT N'== [Q1] 세션 격리 수준 바꾸기: 1 READ UNCOMMITTED, 2 READ COMMITTED(기본), 3 REPEATABLE READ, 4 SERIALIZABLE, 5 SNAPSHOT';
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT transaction_isolation_level AS lvl FROM sys.dm_exec_sessions WHERE session_id = @@SPID;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT transaction_isolation_level AS lvl FROM sys.dm_exec_sessions WHERE session_id = @@SPID;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT transaction_isolation_level AS lvl FROM sys.dm_exec_sessions WHERE session_id = @@SPID;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT transaction_isolation_level AS lvl FROM sys.dm_exec_sessions WHERE session_id = @@SPID;
PRINT N'== [Q2] 이 DB 의 READ COMMITTED 는 잠금 방식인가(0) 스냅숏 방식인가(1)? 스냅숏 격리 허용 여부는?';
SELECT is_read_committed_snapshot_on, snapshot_isolation_state_desc FROM sys.databases WHERE name = DB_NAME();
GO
PRINT N'== [Q3] ALLOW_SNAPSHOT_ISOLATION 이 꺼진 DB 에서 SNAPSHOT 트랜잭션으로 데이터 접근 -> 오류';
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRAN;
GO
-- @expect-error: MSG-3952
SELECT v FROM d14_iso;
GO
IF @@TRANCOUNT > 0 ROLLBACK;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
DROP TABLE IF EXISTS d14_iso;
GO
