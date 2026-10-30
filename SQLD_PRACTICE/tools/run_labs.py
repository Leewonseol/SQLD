#!/usr/bin/env python3
"""SQLD_PRACTICE 실행기.

각 *_oracle.sql / *_sqlserver.sql 파일을 실제 DBMS 컨테이너에서 실행하고
  1) 출력 전문을 <단원>/expected_results/<파일명>.txt 로 저장하고
  2) 예상 오류(-- @expect-error: ORA-00918 / MSG-209) 발생 여부,
     예상하지 않은 오류 발생 여부, 자동검증 토큰(CHECK_PASS / CHECK_FAIL)을 판정해
  3) verification_report.csv 에 기록하고
  4) *.md 안의 <!-- RESULT: 상대경로.sql --> ... <!-- /RESULT --> 블록을 실제 출력으로 갱신한다.

사용:
  python3 tools/run_labs.py                 # 전체
  python3 tools/run_labs.py 05_where_conditions 11_window_functions/examples/ex02_rows_range_oracle.sql
  python3 tools/run_labs.py --inject-only   # DB 실행 없이 md 블록만 갱신

환경변수(기본값은 docker 실습 컨테이너 기준):
  ORA_CONTAINER=sqld_ora      ORA_CONNECT=sqld_lab/SqldLab2026@localhost/XEPDB1
  ORA23_CONTAINER=sqld_ora23  ORA23_CONNECT=sqld_lab/SqldLab2026@localhost/FREEPDB1   (파일명이 *_oracle23ai.sql 인 경우)
  MSSQL_CONTAINER=sqld_mssql  MSSQL_USER=sqld_lab  MSSQL_PASSWORD=Sqld_Lab_2026!
"""
import csv
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ENV = os.environ.get

ORA_HEADER = """SET MARKUP CSV ON DELIMITER | QUOTE OFF
SET NULL (null)
SET FEEDBACK OFF
SET PAGESIZE 50000
SET LINESIZE 32767
SET TRIMOUT ON
SET TAB OFF
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
SET FEEDBACK 1
"""

ERR_PATTERNS = {
    "oracle": re.compile(r"\b(ORA-\d{5}|SP2-\d{4}|PLS-\d{5})\b"),
    "sqlserver": re.compile(r"^Msg (\d+), Level \d+", re.M),
}
EXPECT_RE = re.compile(r"@expect-error:\s*([A-Z0-9,\- ]+)")


def engine_of(path: Path):
    n = path.name
    if n.endswith("_oracle23ai.sql"):
        return "oracle23ai"
    if n.endswith("_oracle.sql") or n == "setup_oracle.sql":
        return "oracle"
    if n.endswith("_sqlserver.sql") or n == "setup_sqlserver.sql":
        return "sqlserver"
    return None


def run_oracle(sql: str, container: str, connect: str) -> str:
    body = ORA_HEADER + sql + "\nEXIT\n"
    p = subprocess.run(
        ["docker", "exec", "-i", "-e", "NLS_LANG=AMERICAN_AMERICA.AL32UTF8", container,
         "sqlplus", "-S", connect],
        input=body.encode("utf-8"), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=600)
    return p.stdout.decode("utf-8", "replace")


def run_sqlserver(sql: str) -> str:
    body = sql + "\nGO\n"
    p = subprocess.run(
        ["docker", "exec", "-i", ENV("MSSQL_CONTAINER", "sqld_mssql"),
         "/opt/mssql-tools18/bin/sqlcmd", "-S", "localhost",
         "-U", ENV("MSSQL_USER", "sqld_lab"), "-P", ENV("MSSQL_PASSWORD", "Sqld_Lab_2026!"),
         "-C", "-I", "-d", "SQLD_LAB", "-f", "65001", "-s", "|", "-W"],
        input=body.encode("utf-8"), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=600)
    return p.stdout.decode("utf-8", "replace")


def normalize(out: str) -> str:
    lines = [l.rstrip() for l in out.replace("\r", "").split("\n")]
    # 연속 빈 줄 축소
    res, blank = [], 0
    for l in lines:
        blank = blank + 1 if l == "" else 0
        if blank <= 1:
            res.append(l)
    return "\n".join(res).strip() + "\n"


def found_errors(engine: str, out: str):
    if engine.startswith("oracle"):
        return sorted(set(ERR_PATTERNS["oracle"].findall(out)))
    return sorted(set("MSG-" + m for m in ERR_PATTERNS["sqlserver"].findall(out)))


def expected_errors(sql: str):
    exp = set()
    for m in EXPECT_RE.finditer(sql):
        for code in m.group(1).replace(" ", "").split(","):
            if code:
                exp.add(code)
    return sorted(exp)


def unit_dir(path: Path) -> Path:
    return path.parent.parent if path.parent.name in ("examples", "answers", "exercises") else path.parent


def collect(targets):
    files = []
    if not targets:
        targets = [str(ROOT)]
    for t in targets:
        p = (ROOT / t) if not Path(t).is_absolute() else Path(t)
        if p.is_file():
            files.append(p)
        else:
            for f in p.rglob("*.sql"):
                if "tools" in f.relative_to(ROOT).parts:
                    continue
                files.append(f)
    files = [f for f in files if engine_of(f)]

    def key(f: Path):
        rel = f.relative_to(ROOT)
        top = rel.parts[0]
        stage = 0 if f.name.startswith("setup_") else (1 if "examples" in rel.parts else 2)
        return (top, stage, str(rel))
    return sorted(set(files), key=key)


_ORA23_READY = []


def execute(f: Path):
    eng = engine_of(f)
    sql = f.read_text(encoding="utf-8")
    if eng == "oracle":
        out = run_oracle(sql, ENV("ORA_CONTAINER", "sqld_ora"),
                         ENV("ORA_CONNECT", "sqld_lab/SqldLab2026@localhost/XEPDB1"))
    elif eng == "oracle23ai":
        if "@requires: 00_common" in sql and not _ORA23_READY:
            run_oracle((ROOT / "00_common" / "setup_oracle.sql").read_text(encoding="utf-8"),
                       ENV("ORA23_CONTAINER", "sqld_ora23"), ENV("ORA23_CONNECT", "sqld_lab/SqldLab2026@localhost/FREEPDB1"))
            _ORA23_READY.append(True)
        out = run_oracle(sql, ENV("ORA23_CONTAINER", "sqld_ora23"),
                         ENV("ORA23_CONNECT", "sqld_lab/SqldLab2026@localhost/FREEPDB1"))
    else:
        out = run_sqlserver(sql)
    out = normalize(out)
    got = found_errors(eng, out)
    exp = expected_errors(sql)
    unexpected = [e for e in got if e not in exp]
    missing = [e for e in exp if e not in got]
    n_pass = len(re.findall(r"\bCHECK_PASS\b", out))
    n_fail = len(re.findall(r"\bCHECK_FAIL\b", out))
    status = "OK" if not unexpected and not missing and n_fail == 0 else "NG"
    dest = unit_dir(f) / "expected_results" / (f.stem + ".txt")
    dest.parent.mkdir(parents=True, exist_ok=True)
    header = f"-- 실행 결과: {f.relative_to(ROOT)} | 엔진: {eng} | 실행기: tools/run_labs.py\n"
    dest.write_text(header + out, encoding="utf-8")
    return dict(file=str(f.relative_to(ROOT)), engine=eng, status=status,
                errors_found=" ".join(got), errors_expected=" ".join(exp),
                unexpected=" ".join(unexpected), missing=" ".join(missing),
                check_pass=n_pass, check_fail=n_fail)


RESULT_BLOCK = re.compile(r"(<!-- RESULT: (?P<path>[^ ]+?) -->)(?P<body>.*?)(<!-- /RESULT -->)", re.S)


def inject():
    changed = 0
    for md in ROOT.rglob("*.md"):
        text = md.read_text(encoding="utf-8")
        if "<!-- RESULT:" not in text:
            continue

        def repl(m):
            sqlp = (md.parent / m.group("path")).resolve()
            res = unit_dir(sqlp) / "expected_results" / (sqlp.stem + ".txt")
            if res.exists():
                content = res.read_text(encoding="utf-8").split("\n", 1)[1].rstrip()
            else:
                content = "(아직 실행되지 않음 — 미실행)"
            return f"{m.group(1)}\n```text\n{content}\n```\n{m.group(4)}"
        new = RESULT_BLOCK.sub(repl, text)
        if new != text:
            md.write_text(new, encoding="utf-8")
            changed += 1
    return changed


def main(argv):
    if "--inject-only" in argv:
        print("md 갱신:", inject())
        return 0
    files = collect([a for a in argv if not a.startswith("--")])
    report_path = ROOT / "verification_report.csv"
    old = {}
    if report_path.exists():
        with report_path.open(encoding="utf-8") as fh:
            for row in csv.DictReader(fh):
                old[row["file"]] = row
    ng = 0
    for f in files:
        r = execute(f)
        old[r["file"]] = r
        flag = "OK" if r["status"] == "OK" else "NG"
        ng += flag == "NG"
        extra = ""
        if r["unexpected"]:
            extra += f" unexpected={r['unexpected']}"
        if r["missing"]:
            extra += f" missing={r['missing']}"
        if r["check_fail"]:
            extra += f" CHECK_FAIL={r['check_fail']}"
        print(f"[{flag}] {r['engine']:10s} {r['file']}{extra}")
    fields = ["file", "engine", "status", "errors_found", "errors_expected", "unexpected",
              "missing", "check_pass", "check_fail"]
    with report_path.open("w", encoding="utf-8", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=fields)
        w.writeheader()
        for k in sorted(old):
            w.writerow({x: old[k].get(x, "") for x in fields})
    print(f"총 {len(files)}개 실행, NG {ng}개. md 갱신 {inject()}개")
    return 1 if ng else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
