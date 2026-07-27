"""문제02: 피어슨 상관계수를 SQLite/DuckDB/MariaDB에서 계산·비교한다.
손계산 정답(README.md): r ≈ 0.7746
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_engine"))
from engines import get_duckdb, get_mariadb, get_sqlite, print_table, run, run_script  # noqa: E402

SETUP = "CREATE TABLE ad_sales(month INT, x DOUBLE, y DOUBLE); " \
        "INSERT INTO ad_sales VALUES (1,1,2),(2,2,4),(3,3,5),(4,4,4),(5,5,5)"

# SQLite/MariaDB 공통: CORR·COVAR_POP 내장함수가 없어 공식을 직접 전개
SQL_MANUAL = """
SELECT
    (AVG(x*y) - AVG(x)*AVG(y))
    / (
        SQRT(AVG(x*x) - AVG(x)*AVG(x)) * SQRT(AVG(y*y) - AVG(y)*AVG(y))
      ) AS r_manual
FROM ad_sales
"""

# DuckDB(그리고 Oracle)는 CORR 내장함수를 그대로 사용 가능
SQL_DUCKDB = "SELECT CORR(y, x) AS r_builtin FROM ad_sales"


def main():
    conn = get_sqlite()
    run_script(conn, "sqlite", SETUP)
    cols, rows = run(conn, "sqlite", SQL_MANUAL)
    print_table("SQLite (수식 직접 전개)", cols, rows)

    d, err = get_duckdb()
    if d is None:
        print(f"[DuckDB 건너뜀] {err}\n")
    else:
        run_script(d, "duckdb", SETUP)
        cols, rows = run(d, "duckdb", SQL_DUCKDB)
        print_table("DuckDB (내장 CORR)", cols, rows)
        # 검산: DuckDB에서도 수식을 직접 전개해 내장함수 결과와 일치하는지 확인
        cols2, rows2 = run(d, "duckdb", SQL_MANUAL)
        print_table("DuckDB (수식 직접 전개, 검산용)", cols2, rows2)

    m, err = get_mariadb()
    if m is None:
        print(f"[MariaDB 건너뜀] {err}\n")
    else:
        run_script(m, "mariadb", "DROP TABLE IF EXISTS ad_sales; " + SETUP)
        cols, rows = run(m, "mariadb", SQL_MANUAL)
        print_table("MariaDB (CORR/COVAR_POP 없음 -> 수식 직접 전개)", cols, rows)


if __name__ == "__main__":
    main()
