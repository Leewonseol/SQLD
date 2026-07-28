"""JOIN·NULL SQL 실습의 02_validate.py가 공통으로 쓰는 DB 연결/검증 헬퍼.

이 모듈은 모델을 학습하지 않는다. 하는 일은 세 가지뿐이다.
  1) 환경변수로 Oracle(python-oracledb) 또는 SQL Server(pyodbc) 연결을 시도한다.
  2) 연결에 성공하면 실제 sql_example_expectation / sql_example_result 테이블을
     조회해 PASS/FAIL을 판정하고 sql_example_validation에 적재한다.
  3) 연결에 실패하면(드라이버 없음, 환경변수 없음, 접속 실패) "정적 검증 모드"로
     전환한다 — SQL 파일 텍스트와 _common/expected_results.csv만으로 구조적
     점검(example_id 중복 여부, 기대값 존재 여부)만 수행하고, 실제 실행 결과와의
     비교는 절대 수행했다고 주장하지 않는다.
"""

from __future__ import annotations

import csv
import os
import re
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path


COMMON_DIR = Path(__file__).resolve().parent
EXPECTED_CSV = COMMON_DIR / "expected_results.csv"


@dataclass
class ExpectedRow:
    topic: str
    dbms: str
    example_id: str
    concept: str
    expected_row_count: int | None
    expected_numeric_value: float | None
    expected_text_value: str | None
    note: str


@dataclass
class ValidationResult:
    example_id: str
    status: str  # PASS / FAIL / NO_RESULT
    expected_value: str
    actual_value: str
    validation_message: str


@dataclass
class ValidationReport:
    mode: str  # "LIVE_DB" or "STATIC"
    dbms: str
    results: list[ValidationResult] = field(default_factory=list)

    @property
    def pass_count(self) -> int:
        return sum(1 for r in self.results if r.status == "PASS")

    @property
    def fail_count(self) -> int:
        return sum(1 for r in self.results if r.status == "FAIL")

    @property
    def no_result_count(self) -> int:
        """PASS도 FAIL도 아닌 상태(NO_RESULT) 건수. 전체 개수(len(results))에는
        포함되지만 pass_count/fail_count 어느 쪽에도 들어가지 않으므로 반드시
        따로 노출한다(섹션 8 규칙 - PASS/FAIL/NO_RESULT를 항상 구분해서 집계)."""
        return sum(1 for r in self.results if r.status not in ("PASS", "FAIL"))

    @property
    def skipped_count(self) -> int:
        """no_result_count의 이전 이름. 하위 호환을 위해 유지."""
        return self.no_result_count


def load_expected_rows(topic: str, dbms: str) -> list[ExpectedRow]:
    """_common/expected_results.csv에서 이 topic·dbms에 해당하는 기대값만 읽는다."""
    rows: list[ExpectedRow] = []
    with open(EXPECTED_CSV, encoding="utf-8", newline="") as f:
        for r in csv.DictReader(f):
            if r["topic"] != topic or r["dbms"].upper() != dbms.upper():
                continue
            rows.append(
                ExpectedRow(
                    topic=r["topic"],
                    dbms=r["dbms"],
                    example_id=r["example_id"],
                    concept=r["concept"],
                    expected_row_count=_to_int(r["expected_row_count"]),
                    expected_numeric_value=_to_float(r["expected_numeric_value"]),
                    expected_text_value=r["expected_text_value"] or None,
                    note=r["note"],
                )
            )
    return rows


def _to_int(v: str) -> int | None:
    v = (v or "").strip()
    return int(v) if v not in ("", "NULL") else None


def _to_float(v: str) -> float | None:
    v = (v or "").strip()
    return float(v) if v not in ("", "NULL") else None


# ---------------------------------------------------------------------------
# 실제 DB 연결 (환경변수 기반, 하드코딩 금지)
# ---------------------------------------------------------------------------

def try_connect_oracle():
    """ORACLE_DSN / ORACLE_USER / ORACLE_PASSWORD 가 모두 설정돼 있고
    python-oracledb가 설치돼 있으면 연결을 시도한다. 실패하면 None을 반환한다
    (예외를 던지지 않는다 — 정적 검증 모드로 넘어가야 하므로).
    """
    dsn = os.environ.get("ORACLE_DSN")
    user = os.environ.get("ORACLE_USER")
    password = os.environ.get("ORACLE_PASSWORD")
    if not (dsn and user and password):
        return None
    try:
        import oracledb  # type: ignore
    except ImportError:
        return None
    try:
        return oracledb.connect(user=user, password=password, dsn=dsn)
    except Exception:
        return None


def try_connect_sqlserver():
    """SQLSERVER_CONNECTION_STRING 이 설정돼 있고 pyodbc가 설치돼 있으면
    연결을 시도한다. 실패하면 None을 반환한다.
    """
    conn_str = os.environ.get("SQLSERVER_CONNECTION_STRING")
    if not conn_str:
        return None
    try:
        import pyodbc  # type: ignore
    except ImportError:
        return None
    try:
        return pyodbc.connect(conn_str)
    except Exception:
        return None


# ---------------------------------------------------------------------------
# 실제 실행 결과와 기대값 비교 (LIVE_DB 모드)
# ---------------------------------------------------------------------------

def compare_live(conn, expected_rows: list[ExpectedRow]) -> ValidationReport:
    dbms = expected_rows[0].dbms if expected_rows else "UNKNOWN"
    report = ValidationReport(mode="LIVE_DB", dbms=dbms)
    cur = conn.cursor()
    for exp in expected_rows:
        cur.execute(
            "SELECT actual_row_count, actual_numeric_value, actual_text_value "
            "FROM sql_example_result WHERE example_id = ?"
            if dbms.upper() == "SQLSERVER"
            else "SELECT actual_row_count, actual_numeric_value, actual_text_value "
            "FROM sql_example_result WHERE example_id = :example_id",
            (exp.example_id,) if dbms.upper() == "SQLSERVER" else {"example_id": exp.example_id},
        )
        row = cur.fetchone()
        if row is None:
            report.results.append(
                ValidationResult(
                    example_id=exp.example_id,
                    status="NO_RESULT",
                    expected_value=_expected_str(exp),
                    actual_value="(결과 없음: 02_examples.sql 미실행 가능성)",
                    validation_message="sql_example_result에 해당 example_id 없음",
                )
            )
            continue
        actual_row_count, actual_numeric_value, actual_text_value = row
        status, message = _judge(exp, actual_row_count, actual_numeric_value, actual_text_value)
        report.results.append(
            ValidationResult(
                example_id=exp.example_id,
                status=status,
                expected_value=_expected_str(exp),
                actual_value=f"row_count={actual_row_count}, numeric={actual_numeric_value}, text={actual_text_value}",
                validation_message=message,
            )
        )
    write_validation_rows(conn, dbms, report.results)
    return report


def _judge(exp: ExpectedRow, actual_row_count, actual_numeric_value, actual_text_value):
    problems = []
    if exp.expected_row_count is not None and actual_row_count != exp.expected_row_count:
        problems.append(f"row_count 기대={exp.expected_row_count} 실제={actual_row_count}")
    if exp.expected_numeric_value is not None:
        if actual_numeric_value is None or abs(float(actual_numeric_value) - exp.expected_numeric_value) > 1e-6:
            problems.append(f"numeric_value 기대={exp.expected_numeric_value} 실제={actual_numeric_value}")
    if exp.expected_text_value is not None and (actual_text_value or "") != exp.expected_text_value:
        problems.append(f"text_value 기대={exp.expected_text_value} 실제={actual_text_value}")
    if problems:
        return "FAIL", "; ".join(problems)
    return "PASS", "expected와 actual 일치"


def _expected_str(exp: ExpectedRow) -> str:
    return f"row_count={exp.expected_row_count}, numeric={exp.expected_numeric_value}, text={exp.expected_text_value}"


def write_validation_rows(conn, dbms: str, results: list[ValidationResult]) -> None:
    cur = conn.cursor()
    is_sqlserver = dbms.upper() == "SQLSERVER"
    if is_sqlserver:
        cur.execute("DELETE FROM sql_example_validation")
    else:
        cur.execute("DELETE FROM sql_example_validation")
    for r in results:
        if is_sqlserver:
            cur.execute(
                "INSERT INTO sql_example_validation "
                "(example_id, status, expected_value, actual_value, validation_message) "
                "VALUES (?, ?, ?, ?, ?)",
                (r.example_id, r.status, r.expected_value, r.actual_value, r.validation_message),
            )
        else:
            cur.execute(
                "INSERT INTO sql_example_validation "
                "(example_id, status, expected_value, actual_value, validation_message) "
                "VALUES (:1, :2, :3, :4, :5)",
                (r.example_id, r.status, r.expected_value, r.actual_value, r.validation_message),
            )
    conn.commit()


# ---------------------------------------------------------------------------
# 정적 검증 모드 (DB 연결 없음)
# ---------------------------------------------------------------------------

EXAMPLE_ID_PATTERN = re.compile(r"'([A-Z]{1,2}[0-9]{2}[A-Z]?)'")


def static_check(topic: str, dbms: str, examples_sql_path: Path, expected_rows: list[ExpectedRow]) -> ValidationReport:
    """DB 연결 없이 할 수 있는 것만 한다:
      - 02_examples.sql 안에 expected_results.csv의 모든 example_id가
        실제로 등장하는지(즉 예제가 작성은 됐는지) 텍스트로 확인한다.
      - 실제 실행 결과와는 절대 비교하지 않는다(실행하지 않았으므로).
    """
    report = ValidationReport(mode="STATIC", dbms=dbms)
    sql_text = examples_sql_path.read_text(encoding="utf-8") if examples_sql_path.exists() else ""
    found_ids = set(EXAMPLE_ID_PATTERN.findall(sql_text))
    for exp in expected_rows:
        if exp.example_id in found_ids:
            status = "NO_RESULT"
            msg = "02_examples.sql에 example_id 존재 확인(정적 점검) — 실제 실행 결과는 미검증"
        else:
            status = "FAIL"
            msg = "02_examples.sql에서 example_id를 찾지 못함"
        report.results.append(
            ValidationResult(
                example_id=exp.example_id,
                status=status,
                expected_value=_expected_str(exp),
                actual_value="(미실행: 실제 DB 연결 없음)",
                validation_message=msg,
            )
        )
    return report


def print_report(report: ValidationReport) -> None:
    print(f"\n=== 검증 모드: {report.mode} / DBMS: {report.dbms} ===")
    if report.mode == "STATIC":
        print("*** 실제 DB 실행 결과 미검증 — 정적 구조 점검만 수행함 ***")
    for r in report.results:
        marker = "OK" if r.status == "PASS" else ("!!" if r.status == "FAIL" else "--")
        print(f"[{marker}] {r.example_id:6s} {r.status:20s} {r.validation_message}")
        if r.status == "FAIL":
            print(f"        expected: {r.expected_value}")
            print(f"        actual  : {r.actual_value}")
    print(
        f"\npass_count={report.pass_count} fail_count={report.fail_count} "
        f"no_result_count={report.no_result_count} total_count={len(report.results)}"
    )


def now_utc_str() -> str:
    return datetime.now(timezone.utc).isoformat()
