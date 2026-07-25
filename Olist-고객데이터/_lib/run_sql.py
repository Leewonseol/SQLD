"""sqlite3 CLI가 없는 환경에서 .sql 파일을 실행하기 위한 범용 스크립트.

sqlite3 CLI가 있다면:
    sqlite3 olist.db < 02_explore_basic.sql
CLI가 없다면:
    python3 ../_lib/run_sql.py olist.db 02_explore_basic.sql
"""

import sqlite3
import sys


def main(db_path, sql_path):
    conn = sqlite3.connect(db_path)
    with open(sql_path, encoding="utf-8") as f:
        script = f.read()

    statements = [s.strip() for s in script.split(";") if s.strip()]
    for stmt in statements:
        cur = conn.execute(stmt)
        if cur.description is not None:
            cols = [d[0] for d in cur.description]
            print(" | ".join(cols))
            for row in cur.fetchall():
                print(" | ".join(str(v) for v in row))
            print()
    conn.commit()
    conn.close()


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("usage: python3 run_sql.py <db_path> <sql_path>")
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])
