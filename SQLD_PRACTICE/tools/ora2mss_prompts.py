#!/usr/bin/env python3
"""Oracle 예제와 SQL 이 같은 경우, PROMPT 줄만 PRINT N'..'; 로 바꿔 SQL Server 파일을 만든다(작은따옴표 이스케이프).
사용: python3 tools/ora2mss_prompts.py <oracle.sql> <sqlserver.sql>"""
import sys
src, dst = sys.argv[1], sys.argv[2]
out = []
for line in open(src, encoding="utf-8").read().split("\n"):
    if line.startswith("PROMPT "):
        out.append("PRINT N'" + line[7:].replace("'", "''") + "';")
    else:
        out.append(line.replace("| Oracle", "| SQL Server"))
open(dst, "w", encoding="utf-8").write("\n".join(out))
