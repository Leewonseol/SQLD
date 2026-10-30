#!/usr/bin/env python3
"""SQL Server 스크립트에서 '-- @expect-error' 바로 앞의 PRINT 를 별도 배치로 분리한다.
구문 오류(Msg 102·156 등)는 배치 전체를 컴파일 단계에서 실패시켜 같은 배치의 PRINT 도 출력되지 않기 때문."""
import re, sys
from pathlib import Path
root = Path(__file__).resolve().parent.parent
pat = re.compile(r"^(PRINT N?'[^\n]*';)\n(-- @expect-error)", re.M)
for f in root.rglob("*_sqlserver.sql"):
    s = f.read_text(encoding="utf-8")
    n = pat.sub(r"\1\nGO\n\2", s)
    if n != s:
        f.write_text(n, encoding="utf-8")
        print("split:", f.relative_to(root))
