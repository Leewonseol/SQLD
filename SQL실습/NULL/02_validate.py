"""NULL 실습 검증 스크립트.

JOIN-표준JOIN/02_validate.py와 완전히 동일한 방식으로 동작한다 - 모델을
학습하지 않고, 실제 DB 연결이 있으면 실행 결과를 비교하고, 없으면 정적
검증 모드로 전환한다. 자세한 원칙은 ../_common/db_helpers.py 참고.

실행:
    python3 02_validate.py
    python3 02_validate.py --dbms oracle
    python3 02_validate.py --dbms sqlserver
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "_common"))
import db_helpers as dbh  # noqa: E402

TOPIC = "NULL"
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
    parser = argparse.ArgumentParser(description="NULL 실습 결과 검증")
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
