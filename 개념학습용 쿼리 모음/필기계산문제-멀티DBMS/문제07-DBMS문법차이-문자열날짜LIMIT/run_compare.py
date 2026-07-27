"""문제07: 문자열 결합·날짜 차이·NULL 처리·상위 N행을 세 엔진에서 서로 다른 문법으로
실행하고 같은 결과가 나오는지 확인한다. 부수적으로 MariaDB `||`가 결합이 아니라
논리 OR로 해석되는 함정을 직접 보여준다.
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_engine"))
from engines import get_duckdb, get_mariadb, get_sqlite, print_table, run, run_script  # noqa: E402

SETUP = """
CREATE TABLE customers(last_name TEXT, first_name TEXT, signup_date TEXT, phone TEXT);
INSERT INTO customers VALUES
    ('김','민준','2024-03-15','010-1111-2222'),
    ('이','서연','2024-07-01', NULL),
    ('박','도윤','2023-11-20','010-3333-4444'),
    ('최','하은','2025-01-10', NULL),
    ('정','지호','2024-05-05','010-5555-6666')
"""

SQL_SQLITE = """
SELECT
    last_name || first_name AS full_name,
    signup_date,
    CAST(JULIANDAY('2025-06-01') - JULIANDAY(signup_date) AS INT) AS days_since_signup,
    COALESCE(phone, '미등록') AS phone_display
FROM customers
ORDER BY signup_date DESC
LIMIT 3
"""

SQL_DUCKDB = """
SELECT
    last_name || first_name AS full_name,
    signup_date,
    DATEDIFF('day', CAST(signup_date AS DATE), DATE '2025-06-01') AS days_since_signup,
    COALESCE(phone, '미등록') AS phone_display
FROM customers
ORDER BY signup_date DESC
LIMIT 3
"""

SQL_MARIADB = """
SELECT
    CONCAT(last_name, first_name) AS full_name,
    signup_date,
    DATEDIFF('2025-06-01', signup_date) AS days_since_signup,
    COALESCE(phone, '미등록') AS phone_display
FROM customers
ORDER BY signup_date DESC
LIMIT 3
"""


def main():
    conn = get_sqlite()
    run_script(conn, "sqlite", SETUP)
    cols, rows = run(conn, "sqlite", SQL_SQLITE)
    print_table("SQLite (||, JULIANDAY, LIMIT)", cols, rows)

    d, err = get_duckdb()
    if d is None:
        print(f"[DuckDB 건너뜀] {err}\n")
    else:
        run_script(d, "duckdb", SETUP)
        cols, rows = run(d, "duckdb", SQL_DUCKDB)
        print_table("DuckDB (||, DATEDIFF, LIMIT)", cols, rows)

    m, err = get_mariadb()
    if m is None:
        print(f"[MariaDB 건너뜀] {err}\n")
    else:
        run_script(m, "mariadb", "DROP TABLE IF EXISTS customers; " + SETUP)

        # 함정 시연: MariaDB 기본 설정에서 || 는 결합이 아니라 논리 OR
        cols, rows = run(m, "mariadb", "SELECT '김' || '민준' AS pipe_result_is_not_concat")
        print_table("MariaDB 함정: || 는 결합이 아니라 논리 OR", cols, rows)

        cols, rows = run(m, "mariadb", SQL_MARIADB)
        print_table("MariaDB (CONCAT, DATEDIFF, LIMIT)", cols, rows)


if __name__ == "__main__":
    main()
