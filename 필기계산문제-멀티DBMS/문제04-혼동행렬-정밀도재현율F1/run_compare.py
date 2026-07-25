"""문제04: 혼동행렬 지표를 계산하면서, "캐스팅 없는 정수 나눗셈"이 엔진마다 다른 결과를
내는 것을 실제로 확인한다. 손계산 정답(README.md): 정확도=0.8, 정밀도=재현율=F1=0.75
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_engine"))
from engines import get_duckdb, get_mariadb, get_sqlite, print_table, run, run_script  # noqa: E402

SETUP = """
CREATE TABLE preds(customer_id INT, actual INT, predicted INT);
INSERT INTO preds VALUES
    (1,1,1),(2,1,0),(3,1,1),(4,0,1),(5,0,0),
    (6,0,0),(7,0,0),(8,0,0),(9,1,1),(10,0,0)
"""

# 캐스팅 없이 그대로 나눈 버전 (SQLite/SQL Server에서는 틀린 값이 나온다)
SQL_NO_CAST = """
SELECT
    SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual=0 AND predicted=1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual=0 AND predicted=0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual=1 AND predicted=0 THEN 1 ELSE 0 END) AS FN,
    SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
        / (SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
           + SUM(CASE WHEN actual=0 AND predicted=1 THEN 1 ELSE 0 END)) AS precision_no_cast
FROM preds
"""

# 1.0을 곱해 실수로 승격시킨 버전 (모든 엔진에서 0.75가 나와야 정상)
SQL_CAST = """
SELECT
    ROUND(1.0 * SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
        / (SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
           + SUM(CASE WHEN actual=0 AND predicted=1 THEN 1 ELSE 0 END)), 4) AS precision_metric,
    ROUND(1.0 * SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
        / (SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
           + SUM(CASE WHEN actual=1 AND predicted=0 THEN 1 ELSE 0 END)), 4) AS recall,
    ROUND(1.0 * (SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END)
                 + SUM(CASE WHEN actual=0 AND predicted=0 THEN 1 ELSE 0 END)) / COUNT(*), 4) AS accuracy
FROM preds
"""


def show(engine_label, conn, engine):
    cols, rows = run(conn, engine, SQL_NO_CAST)
    print_table(f"{engine_label} - 캐스팅 없이 (TP/(TP+FP))", cols, rows)
    cols, rows = run(conn, engine, SQL_CAST)
    print_table(f"{engine_label} - 1.0 캐스팅 적용", cols, rows)


def main():
    conn = get_sqlite()
    run_script(conn, "sqlite", SETUP)
    show("SQLite", conn, "sqlite")

    d, err = get_duckdb()
    if d is None:
        print(f"[DuckDB 건너뜀] {err}\n")
    else:
        run_script(d, "duckdb", SETUP)
        show("DuckDB", d, "duckdb")

    m, err = get_mariadb()
    if m is None:
        print(f"[MariaDB 건너뜀] {err}\n")
    else:
        run_script(m, "mariadb", "DROP TABLE IF EXISTS preds; " + SETUP)
        show("MariaDB", m, "mariadb")


if __name__ == "__main__":
    main()
