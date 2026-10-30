# 11 윈도우 함수 — 단원 안내 (SELECT 단계의 확장)

윈도우 함수는 **SELECT 단계(처리 순서 5)** 에서 계산된다. WHERE·GROUP BY·HAVING이 끝난 행 집합 위에서 "창(window)"을 정해 집계·순위·이동 값을 구한다.
행 수를 줄이지 않는다는 점이 GROUP BY와 다르다(ex06). WHERE보다 늦게 계산되므로 WHERE에서는 쓸 수 없고, 인라인 뷰로 감싸서 거른다(ex03).

```
함수(인수) OVER ( [PARTITION BY 그룹] [ORDER BY 정렬] [ROWS|RANGE BETWEEN 시작 AND 끝] )
```

| 실습 | 주제 | 근거 |
|---|---|---|
| [ex01](examples/ex01_window_basics.md) | 윈도우 함수의 효과, 집계 윈도우, PARTITION BY | PDF E-32 |
| [ex02](examples/ex02_rows_range.md) | 프레임 ROWS·RANGE, 기본 프레임 | PDF E-33 |
| [ex03](examples/ex03_rank_functions.md) | RANK·DENSE_RANK·ROW_NUMBER, 그룹별 TOP-N | §7 |
| [ex04](examples/ex04_lag_lead_first_last.md) | LAG·LEAD·FIRST_VALUE·LAST_VALUE | PDF E-34 |
| [ex05](examples/ex05_ntile_ratio.md) | NTILE·PERCENT_RANK·CUME_DIST·RATIO_TO_REPORT | PDF E-35 |
| [ex06](examples/ex06_group_by_vs_window.md) | GROUP BY와 윈도우 함수의 차이 | §9 |

## PDF 서술과 실행 결과 대조 (외부검증)
| PDF | 실행 결과 | 판정 |
|---|---|---|
| E-32 BOOKSHELF 누적합 13000·29000·8800·19800·12000·25500·40700·14800 | 같음 | 일치 |
| E-32 누적 평균 '13,566.57' | 13566.67 (= 40700/3) | **PDF 오기** |
| E-33 RANGE 결과표 3행 '2050', ROWS CURRENT ROW 결과표 3행 '2050' | 2850 (800+950+1100) | **PDF 오기** |
| E-33 RANGE "값이 같으면 같은 범위로 취급하여 동시 연산" (WARD·MARTIN 5350·5350) | 같음 | 일치 |
| E-34 LAST_VALUE 기본 프레임 → V1 1300·2450·5000 | 같음 | 일치 |
| E-34 "FIRST_VALUE, LAST_VALUE (SQL Server 지원X)" | **SQL Server 2022에서 실행된다**(2012부터 지원 — 공식 문서) | **PDF와 다름** |
| E-35 "NTILE (SQL Server는 지원X)" | **SQL Server 2022에서 실행된다**(2005부터 지원 — 공식 문서) | **PDF와 다름** |
| E-35 14명 3그룹 → 5·5·4 | 같음 | 일치 |

## DBMS 차이
* SQL Server의 RANGE 프레임은 `UNBOUNDED PRECEDING/FOLLOWING`과 `CURRENT ROW`만 받는다(값 오프셋 `RANGE 150 PRECEDING`은 Msg 4194).
* `IGNORE NULLS`: Oracle은 `LAG(comm IGNORE NULLS)`, SQL Server 2022는 `LAG(comm) IGNORE NULLS OVER (...)`로 쓴다. 위치가 다르다.
* RATIO_TO_REPORT는 Oracle 전용이다. SQL Server는 `x / SUM(x) OVER ()`로 쓴다.
* SQL Server의 PERCENT_RANK·CUME_DIST는 FLOAT라 `0.20000000000000001`처럼 표시된다.
* ORDER BY 키에 동점이 있으면 ROWS 프레임·LAG·ROW_NUMBER 결과가 실행마다(DBMS마다) 달라질 수 있다. ex04 Q2에서 FORD·SCOTT의 LAG 값이 두 DBMS에서 서로 바뀌었다.
