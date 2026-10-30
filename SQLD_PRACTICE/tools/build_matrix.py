#!/usr/bin/env python3
"""coverage_matrix.csv 생성기.

tools/concept_rows.py 의 개념 목록을 verification_report.csv(run_labs.py 결과)와 대조한다.
각 개념의 '예상 출력 검증 여부'와 '실습 완료 상태'를 계산한다.
경로 접두사(예: 04_select_from_join/examples/ex04_equi_join)에 해당하는 SQL 파일을 찾는다.
  Oracle·SQL Server 파일이 모두 OK 이고 오류가 없으면  → 완료(실행 검증)
  설계·이론 행이고 md 산출물이 있으면              → 완료(설계·이론 검증)
  어느 쪽이든 원문을 읽을 수 없는 행               → 부분(원문 판독 불가)
"""
import csv
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location("rows", ROOT / "tools" / "concept_rows.py")
cr = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cr)

HEAD = ["개념 ID", "원본 PDF 페이지", "교재 장·절", "개념명", "정의", "적용 조건", "관련 개념",
        "Oracle 지원 여부", "SQL Server 지원 여부", "실습 방법", "해당 SQL 파일 경로",
        "예상 출력 검증 여부", "실습 완료 상태", "근거구분", "비고"]
METHOD = {"실행": "실행 실습(Oracle·SQL Server 실행 검증)", "설계": "설계·도식 실습(ERD·대응표)", "이론": "이론 설명"}


def load_report():
    rep = {}
    with open(ROOT / "verification_report.csv", encoding="utf-8") as f:
        for r in csv.DictReader(f):
            rep[r["file"]] = r
    return rep


def main():
    rep = load_report()
    out, seen, problems = [], set(), []
    for (cid, src, sec, name, defi, cond, rel, ora, mss, method, paths, note) in cr.ROWS:
        assert cid not in seen, cid
        seen.add(cid)
        prefixes = [p for p in paths.split(";") if p]
        pref = prefixes + [p.replace("/examples/", "/answers/") + "_answer" for p in prefixes if "/examples/" in p]
        sql = sorted(f for f in rep if any(f.startswith(p + "_") or f.startswith(p + ".") for p in pref))
        docs = [p for p in prefixes if (ROOT / (p + ".md")).exists()]
        for p in prefixes:
            if not (ROOT / (p + ".md")).exists() and not any(f.startswith(p) for f in sql):
                problems.append(f"{cid}: 경로 없음 {p}")
        engines = {rep[f]["engine"] for f in sql}
        ok = sql and all(rep[f]["status"] == "OK" and rep[f]["check_fail"] in ("", "0") for f in sql)
        if sql:
            verified = ("검증됨(" + "·".join(sorted(engines)) + ", 예상 오류 포함 일치)") if ok else "불일치 있음"
        else:
            verified = "해당 없음(실행 대상 아님)"
        if src == "E-38":
            status = "부분(원문 판독 불가)"
        elif method == "실행" and ok and {"oracle", "sqlserver"} <= engines:
            status = "완료(실행 검증)"
        elif method in ("설계", "이론") and docs:
            status = "완료(설계·이론 검증)" if method == "설계" or sql else "미실행(이론만)"
        else:
            status = "미완료"
            problems.append(f"{cid}: 상태 미완료 ({method}, sql={len(sql)}, engines={engines})")
        basis = f"PDF추출본({src})" if src.startswith("E-") else f"요구목록({src[1:]})"
        files = "; ".join(sql) if sql else "; ".join(p + ".md" for p in docs)
        out.append([cid, "미확인(원본 PDF 미열람)", sec, name, defi, cond, rel, ora, mss, METHOD[method],
                    files, verified, status, basis, note])
    with open(ROOT / "coverage_matrix.csv", "w", encoding="utf-8-sig", newline="") as f:
        w = csv.writer(f)
        w.writerow(HEAD)
        w.writerows(out)
    from collections import Counter
    print("rows", len(out), Counter(r[12] for r in out), Counter(r[13][:3] for r in out))
    for p in problems:
        print("PROBLEM", p)


if __name__ == "__main__":
    main()
