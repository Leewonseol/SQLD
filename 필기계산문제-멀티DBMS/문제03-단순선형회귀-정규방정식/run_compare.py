"""문제03: 단순선형회귀 계수(β0, β1)를 SQLite/DuckDB/MariaDB에서 계산·비교한다.
손계산 정답(README.md): β1=0.6, β0=2.2, X=6일 때 예측값 5.8
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_engine"))
from engines import get_duckdb, get_mariadb, get_sqlite, print_table, run, run_script  # noqa: E402

SETUP = "CREATE TABLE ad_sales(month INT, x DOUBLE, y DOUBLE); " \
        "INSERT INTO ad_sales VALUES (1,1,2),(2,2,4),(3,3,5),(4,4,4),(5,5,5)"

# SQLite/MariaDB 공통: REGR_SLOPE/REGR_INTERCEPT가 없어 정규방정식을 직접 전개
SQL_MANUAL = """
SELECT
    (AVG(x*y) - AVG(x)*AVG(y)) / (AVG(x*x) - AVG(x)*AVG(x)) AS beta1,
    AVG(y) - ((AVG(x*y) - AVG(x)*AVG(y)) / (AVG(x*x) - AVG(x)*AVG(x))) * AVG(x) AS beta0,
    AVG(y) + ((AVG(x*y) - AVG(x)*AVG(y)) / (AVG(x*x) - AVG(x)*AVG(x))) * (6 - AVG(x)) AS predict_at_x6
FROM ad_sales
"""

# DuckDB(그리고 Oracle)는 REGR_SLOPE/REGR_INTERCEPT 내장함수를 그대로 사용 가능
SQL_DUCKDB = """
SELECT
    REGR_SLOPE(y, x) AS beta1,
    REGR_INTERCEPT(y, x) AS beta0,
    REGR_INTERCEPT(y, x) + REGR_SLOPE(y, x) * 6 AS predict_at_x6,
    REGR_R2(y, x) AS r_squared
FROM ad_sales
"""


def main():
    conn = get_sqlite()
    run_script(conn, "sqlite", SETUP)
    cols, rows = run(conn, "sqlite", SQL_MANUAL)
    print_table("SQLite (정규방정식 직접 전개)", cols, rows)

    d, err = get_duckdb()
    if d is None:
        print(f"[DuckDB 건너뜀] {err}\n")
    else:
        run_script(d, "duckdb", SETUP)
        cols, rows = run(d, "duckdb", SQL_DUCKDB)
        print_table("DuckDB (내장 REGR_SLOPE/REGR_INTERCEPT/REGR_R2)", cols, rows)

    m, err = get_mariadb()
    if m is None:
        print(f"[MariaDB 건너뜀] {err}\n")
    else:
        run_script(m, "mariadb", "DROP TABLE IF EXISTS ad_sales; " + SETUP)
        cols, rows = run(m, "mariadb", SQL_MANUAL)
        print_table("MariaDB (REGR_* 없음 -> 정규방정식 직접 전개)", cols, rows)


if __name__ == "__main__":
    main()
