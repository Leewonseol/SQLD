"""이 폴더의 모든 '문제NN' 실습이 공유하는 멀티 DBMS 커넥션 헬퍼.

실제로 이 세션에서 실행 가능한 엔진은 3개뿐이다.
  - SQLite  : Python 표준 라이브러리 내장, 항상 가능
  - DuckDB  : `pip install duckdb`로 설치, 이 저장소 세션에서 설치 확인됨
  - MariaDB : MySQL 호환 오픈소스 서버. `apt-get install mariadb-server`로 설치하고
              `service mariadb start` 후 아래 DB/계정을 만들어야 한다(README 참고).
              엄밀히는 "MySQL"이 아니라 "MySQL 호환 MariaDB"이지만, 문법·함수 체계가
              사실상 동일해 이 실습에서는 MySQL의 대체로 사용한다.

Oracle과 SQL Server는 이 샌드박스 환경(인터넷 제한, 도커 데몬 미기동, 상용 라이선스)에서
실행할 수 없다. 두 엔진은 각 문제 폴더의 README.md에 **문법만** 비교 대상으로 싣고,
실제 실행 비교에서는 제외한다 — 실행할 수 없는 것을 실행한 것처럼 꾸미지 않는다.

각 `run_compare.py`는 이 모듈의 `get_sqlite()`, `get_duckdb()`, `get_mariadb()`로
연결을 얻고, 얻지 못하면(엔진이 설치/기동되지 않은 환경) 그 엔진만 건너뛰고 나머지
결과로 비교를 계속한다.
"""

import sqlite3


def get_sqlite():
    """항상 사용 가능한 인메모리 SQLite 커넥션."""
    return sqlite3.connect(":memory:")


def get_duckdb():
    """설치되어 있으면 인메모리 DuckDB 커넥션, 아니면 (None, 사유)."""
    try:
        import duckdb
    except ImportError:
        return None, "duckdb 패키지가 설치되어 있지 않음 (pip install duckdb)"
    return duckdb.connect(":memory:"), None


def get_mariadb():
    """기동되어 있으면 MariaDB(bigdata_exam) 커넥션, 아니면 (None, 사유).

    사전 준비 (한 번만, README 참고):
        apt-get install -y mariadb-server
        service mariadb start
        mysql -u root -e "CREATE DATABASE IF NOT EXISTS bigdata_exam;
                           CREATE USER IF NOT EXISTS 'examuser'@'localhost' IDENTIFIED BY 'exampass';
                           GRANT ALL PRIVILEGES ON bigdata_exam.* TO 'examuser'@'localhost';"
    """
    try:
        import pymysql
    except ImportError:
        return None, "pymysql 패키지가 설치되어 있지 않음 (pip install pymysql)"
    try:
        conn = pymysql.connect(
            host="localhost",
            user="examuser",
            password="exampass",
            database="bigdata_exam",
            autocommit=True,
        )
    except Exception as e:  # noqa: BLE001 - 환경에 따라 다양한 접속 실패 사유를 그대로 보여줌
        return None, f"MariaDB 접속 실패: {e}"
    return conn, None


def run(conn, engine, sql):
    """engine별로 다른 커서 인터페이스를 통일해 (컬럼명, 행목록)을 반환한다."""
    if engine == "duckdb":
        cur = conn.execute(sql)
        cols = [d[0] for d in cur.description] if cur.description else []
        rows = cur.fetchall()
        return cols, rows
    cur = conn.cursor()
    cur.execute(sql)
    cols = [d[0] for d in cur.description] if cur.description else []
    rows = cur.fetchall()
    return cols, rows


def run_script(conn, engine, script):
    """세미콜론으로 구분된 여러 statement(DDL+INSERT 등)를 순서대로 실행한다."""
    statements = [s.strip() for s in script.split(";") if s.strip()]
    for stmt in statements:
        run(conn, engine, stmt)


def print_table(title, cols, rows):
    print(f"--- {title} ---")
    if not cols:
        print("(결과 없음)")
        return
    print(" | ".join(cols))
    for row in rows:
        print(" | ".join(str(v) for v in row))
    print()
