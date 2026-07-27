"""문제01: 평균·분산·표준편차를 SQLite/DuckDB/MariaDB 3개 엔진에서 실제로 계산하고 비교한다.
손계산 정답(README.md): 평균=14, 모분산=6, 모표준편차≈2.449, 표본분산=7.5, 표본표준편차≈2.739
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_engine"))
from engines import get_duckdb, get_mariadb, get_sqlite, print_table, run, run_script  # noqa: E402

SETUP = "CREATE TABLE sales(store TEXT, amount DOUBLE); " \
        "INSERT INTO sales VALUES ('A',12),('B',15),('C',11),('D',18),('E',14)"

# SQLite: 내장 통계함수가 없어 공식을 직접 SQL로 전개한다.
SQL_SQLITE = """
SELECT
    AVG(amount) AS mean,
    AVG(amount*amount) - AVG(amount)*AVG(amount) AS pop_variance,
    SQRT(AVG(amount*amount) - AVG(amount)*AVG(amount)) AS pop_stddev,
    (AVG(amount*amount) - AVG(amount)*AVG(amount)) * COUNT(*) / (COUNT(*)-1) AS sample_variance,
    SQRT((AVG(amount*amount) - AVG(amount)*AVG(amount)) * COUNT(*) / (COUNT(*)-1)) AS sample_stddev
FROM sales
"""

# DuckDB: ANSI 표준에 가까운 _POP/_SAMP 접미사 내장함수를 그대로 사용
SQL_DUCKDB = """
SELECT
    AVG(amount) AS mean,
    VAR_POP(amount) AS pop_variance,
    STDDEV_POP(amount) AS pop_stddev,
    VAR_SAMP(amount) AS sample_variance,
    STDDEV_SAMP(amount) AS sample_stddev
FROM sales
"""

# MariaDB(MySQL 호환): VARIANCE()/STD()가 "모"통계량이라는 점에 주의(README 함정 포인트)
SQL_MARIADB = """
SELECT
    AVG(amount) AS mean,
    VARIANCE(amount) AS pop_variance,
    STD(amount) AS pop_stddev,
    VAR_SAMP(amount) AS sample_variance,
    STDDEV_SAMP(amount) AS sample_stddev
FROM sales
"""


def main():
    conn = get_sqlite()
    run_script(conn, "sqlite", SETUP)
    cols, rows = run(conn, "sqlite", SQL_SQLITE)
    print_table("SQLite (수식 직접 전개)", cols, rows)

    d, err = get_duckdb()
    if d is None:
        print(f"[DuckDB 건너뜀] {err}\n")
    else:
        run_script(d, "duckdb", SETUP)
        cols, rows = run(d, "duckdb", SQL_DUCKDB)
        print_table("DuckDB (내장 _POP/_SAMP 함수)", cols, rows)

    m, err = get_mariadb()
    if m is None:
        print(f"[MariaDB 건너뜀] {err}\n")
    else:
        run_script(m, "mariadb", "DROP TABLE IF EXISTS sales; " + SETUP)
        cols, rows = run(m, "mariadb", SQL_MARIADB)
        print_table("MariaDB (VARIANCE/STD = 모통계량 주의)", cols, rows)


if __name__ == "__main__":
    main()
