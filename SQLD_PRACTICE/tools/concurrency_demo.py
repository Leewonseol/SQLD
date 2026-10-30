#!/usr/bin/env python3
"""두 세션 동시성 실험: 커밋되지 않은 변경을 다른 세션이 읽으면 어떻게 되는가 (Dirty Read 와 블로킹).

세션 A: 값을 999 로 UPDATE 하고 4초 동안 커밋하지 않다가 ROLLBACK.
세션 B: A 시작 1초 뒤에 같은 행을 읽는다.
  - Oracle READ COMMITTED      : 기다리지 않고 '커밋된 이전 값' 100 을 읽는다(다중 버전 읽기 일관성).
  - SQL Server READ UNCOMMITTED : 기다리지 않고 '커밋되지 않은 값' 999 를 읽는다(Dirty Read).
  - SQL Server READ COMMITTED   : (READ_COMMITTED_SNAPSHOT OFF 이면) A 가 끝날 때까지 잠금 대기 후 100 을 읽는다.
결과는 14_transactions_permissions/expected_results/ex02_concurrency_demo.txt 에 저장한다.
"""
import subprocess, threading, time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "14_transactions_permissions" / "expected_results" / "ex02_concurrency_demo.txt"
ORA = ["docker", "exec", "-i", "sqld_ora", "sqlplus", "-S", "sqld_lab/SqldLab2026@localhost/XEPDB1"]
MSS = ["docker", "exec", "-i", "sqld_mssql", "/opt/mssql-tools18/bin/sqlcmd", "-S", "localhost", "-U", "sqld_lab",
       "-P", "Sqld_Lab_2026!", "-C", "-I", "-d", "SQLD_LAB", "-h", "-1", "-W"]


def run(cmd, sql):
    return subprocess.run(cmd, input=sql.encode(), stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.decode().strip()


def scenario(name, cmd, setup, writer, reader, delay=1.0):
    run(cmd, setup)
    res = {}
    t0 = time.time()

    def a():
        run(cmd, writer)
        res["writer_done"] = time.time() - t0

    def b():
        time.sleep(delay)
        start = time.time() - t0
        out = run(cmd, reader)
        res["reader"] = (start, time.time() - t0, out)

    ta, tb = threading.Thread(target=a), threading.Thread(target=b)
    ta.start(); tb.start(); ta.join(); tb.join()
    s, e, out = res["reader"]
    val = [l for l in out.splitlines() if l.strip().isdigit()]
    return (f"[{name}]\n  읽은 값: {val[-1] if val else out}\n  읽기 시작 {s:.1f}s, 읽기 종료 {e:.1f}s (대기 {e - s:.1f}s), "
            f"쓰기 세션 ROLLBACK {res['writer_done']:.1f}s\n")


ORA_SETUP = "EXEC lab_drop('D14_CC')\nCREATE TABLE d14_cc (id NUMBER PRIMARY KEY, v NUMBER);\nINSERT INTO d14_cc VALUES (1, 100);\nCOMMIT;\nEXIT\n"
ORA_WRITER = "UPDATE d14_cc SET v = 999 WHERE id = 1;\nEXEC DBMS_SESSION.SLEEP(4)\nROLLBACK;\nEXIT\n"
ORA_READER = "SET HEADING OFF FEEDBACK OFF\nSELECT v FROM d14_cc WHERE id = 1;\nEXIT\n"
MSS_SETUP = "DROP TABLE IF EXISTS d14_cc;\nCREATE TABLE d14_cc (id INT PRIMARY KEY, v INT);\nINSERT INTO d14_cc VALUES (1, 100);\nGO\n"
MSS_WRITER = "BEGIN TRAN;\nUPDATE d14_cc SET v = 999 WHERE id = 1;\nWAITFOR DELAY '00:00:04';\nROLLBACK;\nGO\n"
MSS_READER_RU = "SET NOCOUNT ON;\nSET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;\nSELECT v FROM d14_cc WHERE id = 1;\nGO\n"
MSS_READER_RC = "SET NOCOUNT ON;\nSET TRANSACTION ISOLATION LEVEL READ COMMITTED;\nSELECT v FROM d14_cc WHERE id = 1;\nGO\n"

if __name__ == "__main__":
    lines = ["-- 실행 결과: tools/concurrency_demo.py (두 세션 동시 실행, 시간은 쓰기 세션 시작 기준 초)\n"]
    lines.append(scenario("Oracle 21c / READ COMMITTED", ORA, ORA_SETUP, ORA_WRITER, ORA_READER))
    lines.append(scenario("SQL Server 2022 / READ UNCOMMITTED", MSS, MSS_SETUP, MSS_WRITER, MSS_READER_RU))
    lines.append(scenario("SQL Server 2022 / READ COMMITTED (READ_COMMITTED_SNAPSHOT OFF)", MSS, MSS_SETUP, MSS_WRITER, MSS_READER_RC))
    run(ORA, "EXEC lab_drop('D14_CC')\nEXIT\n")
    run(MSS, "DROP TABLE IF EXISTS d14_cc;\nGO\n")
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print("\n".join(lines))
