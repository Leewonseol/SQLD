# 10 그룹 확장(ROLLUP·CUBE·GROUPING SETS)과 PIVOT — 단원 안내 (GROUP BY 단계의 확장)

GROUP BY 단계(처리 순서 3)에서 **그룹 기준을 여러 개 동시에** 만든다. 소계·총계 행이 원래 그룹 행과 함께 나온다.
소계 행에서 집계되어 사라진 컬럼은 NULL로 표시된다. 이 NULL과 데이터에 원래 있던 NULL을 구별할 때 GROUPING 함수를 쓴다.

| 실습 | 주제 | 근거 | 데이터 |
|---|---|---|---|
| [ex01](examples/ex01_rollup.md) | ROLLUP, 인수 순서 | PDF E-28, E-29 | SCOTT(PDF 결과표와 일치 확인), ANIMAL_HOTEL(가상) |
| [ex02](examples/ex02_grouping_function.md) | GROUPING, DECODE/CASE, GROUPING_ID | PDF E-29 | SCOTT, AH_NULL(가상) |
| [ex03](examples/ex03_cube.md) | CUBE | PDF E-30 | SCOTT |
| [ex04](examples/ex04_grouping_sets.md) | GROUPING SETS, UNION ALL 대체 | PDF E-31 | SCOTT |
| [ex05](examples/ex05_pivot_unpivot.md) | PIVOT·UNPIVOT | §7(추출본 미확인) | SCOTT |

## PDF 결과표와 실행 결과 대조 (외부검증)
| PDF | 실행 결과 | 판정 |
|---|---|---|
| E-29 ROLLUP(DNAME, JOB): 14명 29025, ACCOUNTING 3/8750, RESEARCH 5/10875, SALES 6/9400 … | 13행. 값이 모두 같다 | 일치 |
| E-30 CUBE: "18개의 행", JOB 소계 CLERK 4/4150, ANALYST 2/6000, MANAGER 3/8275, SALESMAN 4/5600, PRESIDENT 1/5000 | 18행, 같은 값 | 일치 |
| E-30 "CUBE(DNAME, JOB)와 CUBE(JOB, DNAME) 결과는 같다" | 차집합 0행 | 일치 |
| E-31 GROUPING SETS "8개의 행", "총계가 자동으로 출력되지 않는다" | 8행 | 일치 |
| E-31 "GROUPING SETS (A, B, NULL)로 총계" | Oracle 9행(총계 포함), **SQL Server Msg 164** | Oracle 한정 |
| E-28 ROLLUP 인수 순서를 바꾸면 소계 기준이 바뀜 | 가상 데이터로 9행 vs 11행 확인 | 성질 일치(원본 데이터 없음) |

## DBMS 차이
* SQL Server는 `GROUP BY … WITH ROLLUP / WITH CUBE` 옛 문법도 받는다.
* SQL Server는 `ISNULL(VARCHAR컬럼, N'한글')`에서 결과가 첫 인수 형(VARCHAR(5))으로 바뀌어 **'??'** 로 깨지거나 잘린다(ex02 Q2·Q3). 소계 이름 붙이기에는 CASE + GROUPING을 쓰고, 결과 형을 NVARCHAR로 맞춘다.
* NULL 정렬 위치가 달라서 소계·총계 행의 위치가 DBMS마다 다르다. `ORDER BY GROUPING(col), col`로 맞춘다.
