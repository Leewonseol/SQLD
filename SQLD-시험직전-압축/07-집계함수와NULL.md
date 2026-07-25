[← 이전](./06-NULL-비교와3값논리.md) | [목차](./README.md) | [다음 →](./08-최종1분압축.md)

# 집계함수와 NULL

## 핵심 질문

> NULL을 먼저 계산하는가, 나중에 건너뛰는가?

```text
집계함수는 일반적으로 NULL을 제외한다.
산술식에 NULL이 포함되면 결과는 NULL이다.
```

## 분기표

```text
NULL이 낀 값을 어디서 다루는가?
│
├─ 집계함수(SUM/AVG/COUNT(col)/MAX/MIN) 안에서 다룬다
│  └─ NULL을 건너뛰고 나머지만 계산
│
└─ 산술식(col1 + col2)에서 먼저 다룬다
   └─ 하나라도 NULL이면 그 행의 결과는 NULL
      → 이 NULL을 다시 집계하면 그 행은 집계에서도 제외
```

## 핵심 개념 표

예시 데이터:

```text
TAB_A
COL1 | COL2 | COL3
30   | NULL | 20
NULL | 50   | 10
0    | 10   | NULL
```

| 표현 | 처리 방식 | 이 데이터의 결과 |
|---|---|---|
| `SUM(col)` | NULL 제외 | `SUM(COL2)=60`, `SUM(COL3)=30` |
| `AVG(col)` | NULL 제외 | 분모(개수)에도 NULL 미포함 |
| `COUNT(col)` | NULL 제외 | |
| `COUNT(*)` | 행 자체 집계 | NULL 여부 무관하게 3 |
| `col1 + col2` | 하나라도 NULL이면 결과 NULL | |
| `SUM(col1 + col2)` | 산술 결과가 NULL인 행은 집계에서 제외 | |

`SUM(COL2) + SUM(COL3) = 60 + 30 = 90`.

`WHERE COL1 > 0`: 1행(30)만 통과 — 2행은 COL1이 NULL이라 `NULL > 0`이 UNKNOWN이 되어
제외되고, 3행은 COL1이 0이라 `0 > 0`이 FALSE라서 제외된다.

`WHERE COL1 IS NOT NULL`: 1행(30), 3행(0) — 값이 0인 행도 NULL이 아니므로 포함된다.

`WHERE COL1 IS NULL`: 2행만 해당한다.

> **집계함수는 NULL을 건너뛰지만, 산술식에 NULL이 섞이면 먼저 결과가 NULL이 된다.**

## 최소 SQL 예시

Oracle:

```sql
CREATE TABLE TAB_A (
    COL1 NUMBER,
    COL2 NUMBER,
    COL3 NUMBER
);

INSERT INTO TAB_A VALUES (30, NULL, 20);
INSERT INTO TAB_A VALUES (NULL, 50, 10);
INSERT INTO TAB_A VALUES (0, 10, NULL);
COMMIT;

SELECT SUM(COL2) AS SUM_COL2,
       SUM(COL3) AS SUM_COL3,
       COUNT(COL1) AS COUNT_COL1,
       COUNT(*) AS COUNT_STAR
FROM TAB_A;

SELECT * FROM TAB_A WHERE COL1 > 0;
SELECT * FROM TAB_A WHERE COL1 IS NOT NULL;
SELECT * FROM TAB_A WHERE COL1 IS NULL;
```

SQL Server:

```sql
CREATE TABLE TAB_A (
    COL1 INT,
    COL2 INT,
    COL3 INT
);

INSERT INTO TAB_A VALUES (30, NULL, 20);
INSERT INTO TAB_A VALUES (NULL, 50, 10);
INSERT INTO TAB_A VALUES (0, 10, NULL);

SELECT SUM(COL2) AS SUM_COL2,
       SUM(COL3) AS SUM_COL3,
       COUNT(COL1) AS COUNT_COL1,
       COUNT(*) AS COUNT_STAR
FROM TAB_A;

SELECT * FROM TAB_A WHERE COL1 > 0;
SELECT * FROM TAB_A WHERE COL1 IS NOT NULL;
SELECT * FROM TAB_A WHERE COL1 IS NULL;
```

## 시험 함정

- `SUM`/`AVG`/`COUNT(col)`/`MAX`/`MIN`은 모두 NULL을 먼저 제외하고 계산한다.
- `AVG`는 NULL을 분자에서만 빼는 게 아니라 **분모(개수)에서도 뺀다**.
- `COUNT(*)`는 NULL과 무관하게 행 자체를 센다.
- `col1 + col2`처럼 산술식에 NULL이 하나라도 있으면 그 행의 결과는 NULL이 되고,
  그 NULL을 다시 `SUM`하면 그 행은 집계 대상에서도 빠진다.
- 값이 **0인 행**과 **NULL인 행**을 혼동하지 않는다 — `0`은 실제 값이고 `WHERE col IS
  NULL`로 걸리지 않는다.

## 상세 학습

- [Concepts/COUNT.md](<../Concepts/COUNT.md>)
- [Concepts/집계 함수.md](<../Concepts/집계 함수.md>)
- [NULL-집중학습/04-NULL과집계함수/README.md](<../NULL-집중학습/04-NULL과집계함수/README.md>) — COUNT/SUM/AVG/MIN/MAX의 NULL 처리 상세, SQL Server AVG(INT) 절삭 함정
- [Questions/M01-Q11.md](<../Questions/M01-Q11.md>) — GROUP BY 없는 SUM과 NULL 기출
- [Questions/M01-Q19.md](<../Questions/M01-Q19.md>) — LEFT OUTER JOIN 결과의 COUNT(열) 기출
- [Questions/M01-Q29.md](<../Questions/M01-Q29.md>) — 집계 함수와 NULL의 상호작용 기출
- [Questions/M01-Q38.md](<../Questions/M01-Q38.md>) — NVL과 SUM의 결합 기출
