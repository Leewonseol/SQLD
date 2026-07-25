"""sqlite3 CLI가 없는 환경에서 .sql 파일을 실행하기 위한 대체 스크립트.

sqlite3 CLI가 설치되어 있다면 다음과 동일하다:
    sqlite3 _data/bigdata_exam.db < 01-PCA/01_prepare.sql

CLI가 없다면:
    python3 _data/run_sql.py 01-PCA/01_prepare.sql
"""

import sqlite3
import sys
from dbutil import DB_PATH


def main(path):
    conn = sqlite3.connect(DB_PATH)
    with open(path, encoding="utf-8") as f:
        script = f.read()

    # 세미콜론 기준으로 statement를 나눠, SELECT는 결과를 출력하고
    # 나머지(DDL/DML)는 실행만 한다. 문자열 리터럴 안의 세미콜론은
    # 이 실습 파일들에서는 사용하지 않으므로 단순 split으로 충분하다.
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
    if len(sys.argv) != 2:
        print("usage: python3 run_sql.py <path-to-sql-file>")
        sys.exit(1)
    main(sys.argv[1])
