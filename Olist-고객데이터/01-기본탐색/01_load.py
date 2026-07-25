"""olist_customers_dataset.csv를 SQLite(olist.db)의 customers_raw 테이블로 그대로 적재한다.
변형·파생 없이 원본 5개 열을 문자열 그대로 적재하는 것이 이 스크립트의 유일한 역할이다.
(zip prefix를 정수로 캐스팅하지 않는 이유는 00-데이터사전/README.md §6 참고)
"""

import os
import sqlite3

import pandas as pd

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(HERE))
CSV_PATH = os.path.join(REPO_ROOT, "olist_customers_dataset.csv")
DB_PATH = os.path.join(HERE, "olist.db")


def main():
    df = pd.read_csv(CSV_PATH, dtype=str, keep_default_na=False)

    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
    conn = sqlite3.connect(DB_PATH)
    try:
        df.to_sql("customers_raw", conn, index=False)
        conn.commit()
        n = conn.execute("SELECT COUNT(*) FROM customers_raw").fetchone()[0]
        print(f"customers_raw 적재 완료: {n}행 -> {DB_PATH}")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
