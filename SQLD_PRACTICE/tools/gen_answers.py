#!/usr/bin/env python3
"""answers/ 정답·검증 스크립트 생성기.

tools/answer_specs/uNN.py 의 SPEC(단원 디렉터리, 실습별 문제 목록)을 읽어
<단원>/answers/<실습>_answer_oracle.sql, <실습>_answer_sqlserver.sql 을 만든다.

각 문제(G)는 다음을 가진다.
  title     : 문제 요약
  cols      : [(열이름, 'n'|'s'), ...]   — 기대 결과 뷰의 열과 자료형 종류
  rows      : 기대 결과 행 목록(손으로 계산한 값). None 은 NULL.
  oracle    : Oracle 정답 SQL (ORDER BY 없이)
  sqlserver : SQL Server 정답 SQL (ORDER BY 없이). 생략하면 oracle 과 같다.
  note      : 해설·오류 발생 조건(주석으로 기록)

생성된 스크립트를 run_labs.py 로 실행하면 lab_check 가 정답 SQL 결과와 기대 결과를 비교한다.
즉 "정답 SQL"과 "손으로 계산한 기대 결과"가 서로를 검증한다.
"""
import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def lit_ora(v, kind):
    if v is None:
        return "CAST(NULL AS NUMBER)" if kind == "n" else "CAST(NULL AS VARCHAR2(100))"
    if kind == "n":
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"


def lit_mss(v, kind):
    if v is None:
        return "NULL"
    if kind == "n":
        return str(v)
    return "N'" + str(v).replace("'", "''") + "'"


def exp_ora(cols, rows):
    names = ", ".join(c for c, _ in cols)
    if not rows:
        sel = ", ".join(f"{lit_ora(None, k)} AS {c}" for c, k in cols)
        return f"SELECT {sel} FROM dual WHERE 1 = 0"
    parts = []
    for r in rows:
        parts.append("SELECT " + ", ".join(lit_ora(v, k) for v, (_, k) in zip(r, cols)) + " FROM dual")
    return f"-- ({names})\n" + "\nUNION ALL ".join(parts)


def exp_mss(cols, rows):
    names = ", ".join(c for c, _ in cols)
    if not rows:
        sel = ", ".join(f"CAST(NULL AS {'DECIMAL(18,4)' if k == 'n' else 'NVARCHAR(100)'}) AS {c}" for c, k in cols)
        return f"SELECT {sel} WHERE 1 = 0"
    vals = ",\n       ".join("(" + ", ".join(lit_mss(v, k) for v, (_, k) in zip(r, cols)) + ")" for r in rows)
    return f"SELECT * FROM (VALUES {vals}) v({names})"


def comment(text):
    return "\n".join("-- " + l if l else "--" for l in text.strip().split("\n"))


def build(spec):
    unit = spec["unit"]
    code = spec["code"]          # 예: '04'
    for lab in spec["labs"]:
        slug = lab["slug"]       # 예: 'ex05_non_equi_join'
        num = slug[2:4]
        for eng in ("oracle", "sqlserver"):
            out = []
            out.append("-- " + "=" * 69)
            out.append(f"-- H. 정답 및 검증 | {unit} {slug} | {'Oracle' if eng == 'oracle' else 'SQL Server'}")
            out.append("-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.")
            out.append("-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/" + slug + ".md")
            out.append("-- " + "=" * 69)
            if eng == "sqlserver":
                out.append("USE SQLD_LAB;\nGO")
            for i, g in enumerate(lab["problems"], 1):
                v_ans = f"ans{code}_{num}_g{i}"
                v_exp = f"exp{code}_{num}_g{i}"
                sql = g["oracle"] if eng == "oracle" else g.get("sqlserver", g["oracle"])
                label = f"{code}-{slug[:4]}-G{i}"
                cols = ", ".join(c for c, _ in g["cols"])
                if eng == "oracle":
                    out.append(f"\nPROMPT == [G{i}] {g['title']}")
                else:
                    out.append("\nPRINT N'== [G" + str(i) + "] " + g['title'].replace("'", "''") + "';")
                if g.get("note"):
                    out.append(comment(g["note"]))
                if eng == "oracle":
                    out.append(f"CREATE OR REPLACE VIEW {v_ans} ({cols}) AS\n{sql.strip()};")
                    out.append(f"CREATE OR REPLACE VIEW {v_exp} ({cols}) AS\n{exp_ora(g['cols'], g['rows'])};")
                    out.append(f"EXEC lab_check('{label}', '{v_ans.upper()}', '{v_exp.upper()}')")
                    out.append(f"SELECT * FROM {v_ans} ORDER BY {', '.join(str(k) for k in range(1, len(g['cols']) + 1))};")
                else:
                    out.append("GO")
                    out.append(f"CREATE OR ALTER VIEW {v_ans} ({cols}) AS\n{sql.strip()};\nGO")
                    out.append(f"CREATE OR ALTER VIEW {v_exp} ({cols}) AS\n{exp_mss(g['cols'], g['rows'])};\nGO")
                    out.append(f"EXEC lab_check N'{label}', N'{v_ans}', N'{v_exp}';")
                    out.append(f"SELECT * FROM {v_ans} ORDER BY {', '.join(str(k) for k in range(1, len(g['cols']) + 1))};\nGO")
            path = ROOT / unit / "answers" / f"{slug}_answer_{eng}.sql"
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("\n".join(out) + "\n", encoding="utf-8")
            print("written", path.relative_to(ROOT))


def main(argv):
    specs = sorted((ROOT / "tools" / "answer_specs").glob("u*.py"))
    if argv:
        specs = [s for s in specs if s.stem in argv]
    for s in specs:
        m = importlib.util.spec_from_file_location(s.stem, s)
        mod = importlib.util.module_from_spec(m)
        m.loader.exec_module(mod)
        build(mod.SPEC)


if __name__ == "__main__":
    main(sys.argv[1:])
