"""문제05: 엔트로피·지니계수를 계산하고, 밑을 지정하지 않은 LOG(x)가 엔진마다
다른 로그(상용로그 vs 자연로그)를 반환하는 함정을 실제로 확인한다.
손계산 정답(README.md): Entropy≈0.72193, Gini=0.32
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_engine"))
from engines import get_duckdb, get_mariadb, get_sqlite, print_table, run, run_script  # noqa: E402

SETUP = "CREATE TABLE node_dist(label TEXT, n INT); INSERT INTO node_dist VALUES ('Yes',8),('No',2)"

# 밑을 지정하지 않은 LOG(p) - 엔진에 따라 log10 또는 ln이 나와 "틀린" 엔트로피가 나온다
SQL_WRONG_LOG = """
SELECT
    - SUM((1.0*n/10) * LOG(1.0*n/10)) AS entropy_using_bare_log
FROM node_dist
"""

# 밑 2를 명시한 올바른 엔트로피 (SQLite/DuckDB/MariaDB 공통: LOG(2, p) 또는 LOG2(p))
SQL_ENTROPY_SQLITE_DUCKDB = """
SELECT
    - SUM((1.0*n/10) * LOG(2, 1.0*n/10)) AS entropy_correct,
    1 - SUM((1.0*n/10) * (1.0*n/10)) AS gini
FROM node_dist
"""

SQL_ENTROPY_MARIADB = """
SELECT
    - SUM((1.0*n/10) * LOG2(1.0*n/10)) AS entropy_correct,
    1 - SUM((1.0*n/10) * (1.0*n/10)) AS gini
FROM node_dist
"""


def main():
    conn = get_sqlite()
    run_script(conn, "sqlite", SETUP)
    cols, rows = run(conn, "sqlite", SQL_WRONG_LOG)
    print_table("SQLite - LOG(p) 밑 미지정 (log10 반환 -> 틀린 값)", cols, rows)
    cols, rows = run(conn, "sqlite", SQL_ENTROPY_SQLITE_DUCKDB)
    print_table("SQLite - LOG(2,p) 밑 명시 (올바른 값)", cols, rows)

    d, err = get_duckdb()
    if d is None:
        print(f"[DuckDB 건너뜀] {err}\n")
    else:
        run_script(d, "duckdb", SETUP)
        cols, rows = run(d, "duckdb", SQL_WRONG_LOG)
        print_table("DuckDB - LOG(p) 밑 미지정 (log10 반환 -> 틀린 값)", cols, rows)
        cols, rows = run(d, "duckdb", SQL_ENTROPY_SQLITE_DUCKDB)
        print_table("DuckDB - LOG(2,p) 밑 명시 (올바른 값)", cols, rows)

    m, err = get_mariadb()
    if m is None:
        print(f"[MariaDB 건너뜀] {err}\n")
    else:
        run_script(m, "mariadb", "DROP TABLE IF EXISTS node_dist; " + SETUP)
        cols, rows = run(m, "mariadb", SQL_WRONG_LOG)
        print_table("MariaDB - LOG(p) 밑 미지정 (자연로그 반환 -> 틀린 값, SQLite/DuckDB와도 다름)", cols, rows)
        cols, rows = run(m, "mariadb", SQL_ENTROPY_MARIADB)
        print_table("MariaDB - LOG2(p) 사용 (올바른 값)", cols, rows)


if __name__ == "__main__":
    main()
