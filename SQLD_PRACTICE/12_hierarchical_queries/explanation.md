# 12 계층형 질의 — 단원 안내 (별도 학습 분기)

자기참조 관계(사원–관리자, 01단원 ex05)를 **여러 단계**로 따라간다. 셀프 조인(04단원 ex07)은 한 단계만 가지만, 계층형 질의는 끝까지 전개한다.

* Oracle 전용 구문: `START WITH (루트 조건) CONNECT BY [NOCYCLE] PRIOR 부모쪽 = 자식쪽`
* 표준 구문(두 DBMS 공통): 재귀 WITH(CTE) — Oracle 11gR2+, SQL Server 2005+

| 실습 | 주제 | 근거 |
|---|---|---|
| [ex01](examples/ex01_connect_by.md) | START WITH·CONNECT BY PRIOR, 순방향·역방향, LEVEL·CONNECT_BY_ISLEAF·CONNECT_BY_ROOT·SYS_CONNECT_BY_PATH·ORDER SIBLINGS BY, WHERE와 CONNECT BY 조건 | PDF E-37 (E-38 도식은 판독 불가) |
| [ex02](examples/ex02_nocycle.md) | 순환 구조, NOCYCLE, CONNECT_BY_ISCYCLE | PDF E-37 |
| [ex03](examples/ex03_recursive_with.md) | 재귀 WITH, SEARCH·CYCLE 절 | §7 |

> **PRIOR 방향 기억법**: `PRIOR`가 붙은 쪽이 **이미 방문한(부모) 행**이다.
> `CONNECT BY PRIOR 사원 = 관리자`: 부모의 사원번호 = 자식의 관리자 → **위에서 아래로**(순방향).
> `CONNECT BY 사원 = PRIOR 관리자`: 자식의 사원번호 = 부모의 관리자 → **아래에서 위로**(역방향).
> PDF E-38의 방향 도식은 추출본에서 기호만 남아 대조하지 못했다.

## 실행으로 확인한 내용
* PDF E-37 결과표(루트 A, 경로 /A, /A/B, /A/C, /A/C/D)가 Oracle CONNECT BY와 SQL Server 재귀 CTE에서 같게 재현된다.
* PDF E-37 "NOCYCLE 명시하지 않아 오류" → ORA-01436. IS_CYCLE = 0, 1도 일치한다.
* SQL Server 재귀 CTE는 순환을 막지 않는다. 기본 `MAXRECURSION 100`을 넘으면 Msg 530이 나고, 그 전까지 101행이 이미 출력된다.
* SQL Server에서 CONNECT BY를 쓰면 Msg 336("…common table expression…")이 난다. `START`를 별칭으로 해석한 결과다.
