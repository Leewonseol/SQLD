"""JOIN·표준 JOIN 실습 검증 스크립트.

이 스크립트는 모델을 학습하지 않는다. 하는 일은 다음 세 가지뿐이다.
  1) 환경변수(ORACLE_DSN/ORACLE_USER/ORACLE_PASSWORD 또는
     SQLSERVER_CONNECTION_STRING)로 실제 DB 연결을 시도한다.
  2) 연결에 성공한 DBMS가 있으면, 그 DBMS에 이미 Oracle/02_examples.sql 또는
     SQLServer/02_examples.sql이 채워 둔 sql_example_result를
     _common/expected_results.csv(=sql_example_expectation)와 비교해
     PASS/FAIL을 판정하고 sql_example_validation에 적재한다.
  3) 연결에 실패하면(드라이버 없음, 환경변수 없음, 접속 실패) 정적 검증
     모드로 전환한다 - 02_examples.sql에 example_id가 실제로 존재하는지만
     확인하고, "실제로 실행해서 검증했다"고 주장하지 않는다.

실행:
    python3 02_validate.py            # Oracle, SQL Server 순서로 연결 시도
    python3 02_validate.py --dbms oracle
    python3 02_validate.py --dbms sqlserver
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "_common"))
import db_helpers as dbh  # noqa: E402

TOPIC = "JOIN"
HERE = Path(__file__).resolve().parent


def run_for_dbms(dbms: str) -> dbh.ValidationReport:
    expected_rows = dbh.load_expected_rows(TOPIC, dbms)
    if not expected_rows:
        raise SystemExit(f"_common/expected_results.csv에 topic={TOPIC}, dbms={dbms} 데이터가 없음")

    conn = dbh.try_connect_oracle() if dbms.upper() == "ORACLE" else dbh.try_connect_sqlserver()
    if conn is not None:
        try:
            return dbh.compare_live(conn, expected_rows)
        finally:
            conn.close()

    examples_path = HERE / ("Oracle" if dbms.upper() == "ORACLE" else "SQLServer") / "02_examples.sql"
    return dbh.static_check(TOPIC, dbms, examples_path, expected_rows)


def main() -> None:
    parser = argparse.ArgumentParser(description="JOIN 실습 결과 검증")
    parser.add_argument("--dbms", choices=["oracle", "sqlserver"], default=None)
    args = parser.parse_args()

    targets = [args.dbms.upper()] if args.dbms else ["ORACLE", "SQLSERVER"]

    overall_fail = 0
    for dbms in targets:
        report = run_for_dbms(dbms)
        dbh.print_report(report)
        overall_fail += report.fail_count

    if overall_fail:
        print(f"\n총 {overall_fail}건 FAIL — 03_verify.sql에서 실패 예제를 다시 조회하라.")
        sys.exit(1)
    print("\n실행된 모든 검증이 PASS(또는 정적 점검 통과)했다.")


if __name__ == "__main__":
    main()
