"""문제06: Z-score 표준화와 Min-Max 정규화를 파티션 없는 윈도우 함수로 구현하고 비교한다.
손계산 정답(README.md): A(12) z≈-0.816, D(18) z≈1.633, E(14) z=0 / minmax: C=0, D=1
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_engine"))
from engines import get_duckdb, get_mariadb, get_sqlite, print_table, run, run_script  # noqa: E402

SETUP = "CREATE TABLE sales(store TEXT, amount DOUBLE); " \
        "INSERT INTO sales VALUES ('A',12),('B',15),('C',11),('D',18),('E',14)"

# SQLite: STDDEV 내장함수가 없어 윈도우로 수식을 직접 전개
SQL_SQLITE = """
SELECT
    store, amount,
    (amount - AVG(amount) OVER())
        / SQRT(AVG(amount*amount) OVER() - AVG(amount) OVER()*AVG(amount) OVER()) AS z_score,
    (amount - MIN(amount) OVER()) * 1.0 / (MAX(amount) OVER() - MIN(amount) OVER()) AS min_max
FROM sales
ORDER BY store
"""

# DuckDB/MariaDB: STDDEV_POP()을 윈도우 함수로 그대로 사용 가능
SQL_BUILTIN = """
SELECT
    store, amount,
    (amount - AVG(amount) OVER()) / STDDEV_POP(amount) OVER() AS z_score,
    (amount - MIN(amount) OVER()) * 1.0 / (MAX(amount) OVER() - MIN(amount) OVER()) AS min_max
FROM sales
ORDER BY store
"""


def main():
    conn = get_sqlite()
    run_script(conn, "sqlite", SETUP)
    cols, rows = run(conn, "sqlite", SQL_SQLITE)
    print_table("SQLite (STDDEV_POP 수식 직접 전개)", cols, rows)

    d, err = get_duckdb()
    if d is None:
        print(f"[DuckDB 건너뜀] {err}\n")
    else:
        run_script(d, "duckdb", SETUP)
        cols, rows = run(d, "duckdb", SQL_BUILTIN)
        print_table("DuckDB (STDDEV_POP OVER())", cols, rows)

    m, err = get_mariadb()
    if m is None:
        print(f"[MariaDB 건너뜀] {err}\n")
    else:
        run_script(m, "mariadb", "DROP TABLE IF EXISTS sales; " + SETUP)
        cols, rows = run(m, "mariadb", SQL_BUILTIN)
        print_table("MariaDB (STDDEV_POP OVER())", cols, rows)


if __name__ == "__main__":
    main()
