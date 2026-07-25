"""각 기법 폴더의 02_analyze.py 가 공통으로 사용하는 DB 연결 헬퍼."""

import os
import sqlite3

DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "bigdata_exam.db")


def get_conn():
    """bigdata_exam.db 커넥션을 반환한다. 없으면 build_db.py를 먼저 실행하라는 에러를 낸다."""
    if not os.path.exists(DB_PATH):
        raise FileNotFoundError(
            f"{DB_PATH} 가 없습니다. 먼저 `python3 분석기법/_data/build_db.py` 를 실행하세요."
        )
    return sqlite3.connect(DB_PATH)


def run_sql_file(conn, path):
    """prepare.sql / verify.sql 파일을 그대로 실행한다(여러 statement 지원)."""
    with open(path, encoding="utf-8") as f:
        script = f.read()
    conn.executescript(script)
    conn.commit()
