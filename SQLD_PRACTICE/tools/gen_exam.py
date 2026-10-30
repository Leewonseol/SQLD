#!/usr/bin/env python3
"""15_integrated_exam 복합 문제 생성기.

tools/answer_specs/exam15.py 의 QUESTIONS 로부터 문제마다
  examples/qNN_*_oracle.sql, examples/qNN_*_sqlserver.sql  (보기 4개 실행 + 요구 결과와 MATCH/DIFF 비교 + 정답 lab_check)
  examples/qNN_*.md                                       (업무 설명·요구 결과·보기·실행 결과·정답 해설·변형 문제)
을 만든다. 보기 SQL 이 실제로 요구 결과와 같은지(MATCH)를 DBMS 가 판정하므로, 정답 표기가 틀리면 실행 결과에서 드러난다.
"""
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
UNIT = ROOT / "15_integrated_exam" / "examples"
spec = importlib.util.spec_from_file_location("ga", ROOT / "tools" / "gen_answers.py")
ga = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ga)
spec2 = importlib.util.spec_from_file_location("exam15", ROOT / "tools" / "answer_specs" / "exam15.py")
ex = importlib.util.module_from_spec(spec2)
spec2.loader.exec_module(ex)
CIRCLED = "①②③④"


def oracle_file(q):
    n = q["no"]
    cols = ", ".join(c for c, _ in q["cols"])
    order = ", ".join(str(i) for i in range(1, len(q["cols"]) + 1))
    out = [f"-- 15 Q{n} {q['title']} | Oracle | 생성: tools/gen_exam.py (명세 tools/answer_specs/exam15.py)"]
    for i, (o, _) in enumerate(q["choices"], 1):
        v = f"x15v_q{n}_c{i}"
        out.append(f"\nPROMPT == [보기 {CIRCLED[i-1]}]")
        out.append(f"CREATE OR REPLACE VIEW {v} ({cols}) AS\n{o};")
        out.append(f"SELECT * FROM {v} ORDER BY {order};")
    e = f"x15v_q{n}_exp"
    out.append(f"\nCREATE OR REPLACE VIEW {e} ({cols}) AS\n{ga.exp_ora(q['cols'], q['rows'])};")
    out.append("PROMPT == [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)")
    parts = []
    for i in range(1, 5):
        v = f"x15v_q{n}_c{i}"
        parts.append(f"SELECT '{CIRCLED[i-1]}' AS choice, (SELECT COUNT(*) FROM {v}) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM {v} MINUS SELECT * FROM {e})) = 0 "
                     f"AND (SELECT COUNT(*) FROM (SELECT * FROM {e} MINUS SELECT * FROM {v})) = 0 AND (SELECT COUNT(*) FROM {v}) = (SELECT COUNT(*) FROM {e}) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual")
    out.append("\nUNION ALL ".join(parts) + ";")
    out.append(f"EXEC lab_check('15-Q{n}-answer-{q['answer']}', 'X15V_Q{n}_C{q['answer']}', 'X15V_Q{n}_EXP')")
    for i in range(1, 5):
        out.append(f"DROP VIEW x15v_q{n}_c{i};")
    out.append(f"DROP VIEW {e};")
    return "\n".join(out) + "\n"


def mss_file(q):
    n = q["no"]
    cols = ", ".join(c for c, _ in q["cols"])
    order = ", ".join(str(i) for i in range(1, len(q["cols"]) + 1))
    out = [f"-- 15 Q{n} {q['title']} | SQL Server | 생성: tools/gen_exam.py"]
    for i, (o, m) in enumerate(q["choices"], 1):
        v = f"x15v_q{n}_c{i}"
        out.append(f"PRINT N'== [보기 {CIRCLED[i-1]}]';\nGO")
        out.append(f"CREATE OR ALTER VIEW {v} ({cols}) AS\n{m or o};\nGO")
        out.append(f"SELECT * FROM {v} ORDER BY {order};\nGO")
    e = f"x15v_q{n}_exp"
    out.append(f"CREATE OR ALTER VIEW {e} ({cols}) AS\n{ga.exp_mss(q['cols'], q['rows'])};\nGO")
    out.append("PRINT N'== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)';")
    parts = []
    for i in range(1, 5):
        v = f"x15v_q{n}_c{i}"
        parts.append(f"SELECT N'{CIRCLED[i-1]}' AS choice, (SELECT COUNT(*) FROM {v}) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM {v} EXCEPT SELECT * FROM {e}) "
                     f"AND NOT EXISTS (SELECT * FROM {e} EXCEPT SELECT * FROM {v}) AND (SELECT COUNT(*) FROM {v}) = (SELECT COUNT(*) FROM {e}) THEN 'MATCH' ELSE 'DIFF' END AS verdict")
    out.append("\nUNION ALL ".join(parts) + ";")
    out.append(f"EXEC lab_check N'15-Q{n}-answer-{q['answer']}', N'x15v_q{n}_c{q['answer']}', N'{e}';")
    out.append("DROP VIEW " + ", ".join([f"x15v_q{n}_c{i}" for i in range(1, 5)] + [e]) + ";\nGO")
    return "\n".join(out) + "\n"


def md_file(q, slug):
    n = q["no"]
    rows = "\n".join("| " + " | ".join("NULL" if v is None else str(v) for v in r) + " |" for r in q["rows"])
    head = "| " + " | ".join(c for c, _ in q["cols"]) + " |\n|" + "---|" * len(q["cols"])
    choices = []
    for i, (o, m) in enumerate(q["choices"], 1):
        block = f"**보기 {CIRCLED[i-1]}**\n```sql\n{o};\n```"
        if m:
            block += f"\nSQL Server 문법\n```sql\n{m};\n```"
        choices.append(block)
    why = "\n".join(f"* 보기 {CIRCLED[i]}: {w}" for i, w in enumerate(q["why"]))
    return f"""# Q{n}. {q['title']}

> 출제 의도: {q['topic']} · 데이터: 학습용 가상 데이터(스트리밍 서비스, [ERD](../explanation.md)) · 검증: Oracle 21c / SQL Server 2022 실행. 각 보기의 MATCH/DIFF는 DBMS가 판정했다.

## ① ERD
[단원 안내의 ERD](../explanation.md#erd)를 본다. X15_CUSTOMER 1 : N X15_WATCH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_WISH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_PAYMENT(비회원 결제는 cust_id NULL).

## ② 업무 설명
{q['business']}

## ③ 요구되는 조회 결과
{q['requirement']}

{head}
{rows}

## ④ SQL 보기 (정답은 하나)
{chr(10).join(choices)}

## ⑤ 각 보기가 만드는 결과 비교 (실제 실행)
Oracle 21c XE
<!-- RESULT: {slug}_oracle.sql -->
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: {slug}_sqlserver.sql -->
<!-- /RESULT -->

## ⑥ 정답과 오답 원인
**정답: 보기 {CIRCLED[q['answer']-1]}** (위 비교표에서 MATCH가 이 보기 하나이고, lab_check가 CHECK_PASS다)

{why}

## 변형 문제 (외우지 말고 다시 풀기)
{q['variant']}
"""


def main():
    for q in ex.QUESTIONS:
        slug = q["slug"]
        (UNIT / f"{slug}_oracle.sql").write_text(oracle_file(q), encoding="utf-8")
        (UNIT / f"{slug}_sqlserver.sql").write_text(mss_file(q), encoding="utf-8")
        md = UNIT / f"{slug}.md"
        md.write_text(md_file(q, slug), encoding="utf-8")
        print("written", slug)


if __name__ == "__main__":
    main()
