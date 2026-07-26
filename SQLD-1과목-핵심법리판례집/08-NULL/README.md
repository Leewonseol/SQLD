# 08 NULL

기본 학습은 아래 비교표와 결정 트리로 진행한다. 상세 근거와 기출 해설이 필요할 때만 하단 "상세 기출 해설" 링크를 연다.

## 1. 핵심 개념 비교표

### NULL 연산 결과 요약

| 표현 | 결과 |
| --- | --- |
| `NULL = NULL` | UNKNOWN |
| `COL = NULL` | UNKNOWN(0건 반환, `IS NULL`과 다름) |
| `COL IS NULL` | TRUE 또는 FALSE(정상 판정) |
| `100 + NULL` | NULL(전파) |
| `COUNT(COL)` | NULL 제외 |
| `COUNT(*)` | 전체 행 집계(NULL 무관, 유일한 예외) |
| `SUM(A+B)` | 행별 산술 결과가 NULL인 행은 집계에서 제외 |
| `SUM(A)+SUM(B)` | 각 열에서 NULL을 각각 제외한 뒤 합산(SUM(A+B)와 값이 다를 수 있음) |

### NULL·0·공백·빈 문자열 비교

| 구분 | NULL | 0 | 공백 | 빈 문자열 |
| --- | --- | --- | --- | --- |
| 의미 | 값 없음·알 수 없음 | 숫자값 | 문자값 | 길이 0 문자열 |
| Oracle | NULL | 0 | 공백 | NULL처럼 처리(예외) |
| 일반 DBMS 원칙 | NULL | 0 | 공백 | NULL과 구분되는 값 |

### 3값 논리

| 결과 | WHERE 통과 여부 |
| --- | :-: |
| TRUE | O |
| FALSE | X |
| UNKNOWN | X |

### ERD 표기법별 NULL 허용 표시

| 표기법 | NULL 허용 표시 |
| --- | --- |
| Barker | 속성 앞 o(허용)/*(비허용) |
| IE | 표시 관례 없음 |

## 2. 판정 순서

```text
NULL이 어디에 사용됐는가?
├─ 일반 비교(=, <>, > 등) → UNKNOWN
├─ IS NULL / IS NOT NULL → TRUE/FALSE
├─ 산술(+, -, *, /) → 결과 NULL(전파)
└─ 집계함수
   ├─ COUNT(*) → 행 전체(NULL 무관)
   └─ COUNT(col), SUM, AVG, MAX, MIN → NULL 제외
```

## 3. 유사 사례 비교 — 행별 계산 예시

SAMPLE 테이블: COL1(10, NULL, 30), COL2(NULL, 15, 25)

| 행 | COL1 | COL2 | `COL1+COL2` | 이유 |
| --: | --: | --: | --: | --- |
| 1 | 10 | NULL | NULL | COL2가 NULL |
| 2 | NULL | 15 | NULL | COL1이 NULL |
| 3 | 30 | 25 | 55 | 둘 다 존재 |

| 표현 | 계산 과정 | 결과 |
| --- | --- | --: |
| `COUNT(COL1)*10` | NULL 제외 개수(2)×10 | 20 |
| `SUM(COL1+COL2)/4` | 행별 결과 중 NULL 제외 합계(55)/4 | 13.75 |
| `SUM(COL2)/2` | NULL 제외 합계(40)/2 | 20 |
| `AVG(COL1)` | NULL 제외 합계(40)/개수(2) | 20 |

## 4. 반복 오답

| 선지 표현 | O/X | 틀린 이유 | 올바르게 고치면 |
| --- | :-: | --- | --- |
| NULL은 숫자 0과 동일하게 취급된다 | X | NULL은 값 없음, 0은 숫자값(값·상태 혼동, D9) | NULL은 0과 다른, 값이 없는 상태다 |
| `WHERE COL IS NULL`과 `WHERE COL = NULL`은 같은 조건이다 | X | `=NULL`은 항상 UNKNOWN(값·상태 혼동, D9) | NULL 여부 판단은 반드시 `IS NULL`을 써야 한다 |
| `COL = NULL`의 결과는 FALSE다 | X | 정확히는 UNKNOWN(원칙·예외 혼동, D10) | `COL = NULL`의 결과는 UNKNOWN이다 |
| NULL이 포함된 산술연산은 0을 더한 것처럼 원래 값이 나온다 | X | 결과는 NULL로 전파(값·상태 혼동, D9) | NULL이 산술연산에 하나라도 섞이면 결과는 NULL이다 |
| 집계함수는 NULL이 있으면 결과도 NULL이 된다 | X | 이는 산술연산의 전파 규칙, 집계함수는 NULL을 제외하고 계산(행·열 혼동, D8) | 집계함수는 NULL을 제외하고 나머지 값만으로 계산한다 |
| `COUNT(*)`와 `COUNT(컬럼)`은 NULL에 대해 같은 방식으로 동작한다 | X | `COUNT(*)`만 NULL 무관, `COUNT(컬럼)`은 NULL 제외(행·열 혼동, D8) | `COUNT(*)`는 NULL과 무관하게 행을 세고, `COUNT(컬럼)`은 NULL을 제외하고 센다 |
| IE표기법도 NULL 허용 여부를 표시할 수 있다 | X | IE는 NULL 표기 관례가 없음(기호 오독, D7) | NULL 허용 여부는 Barker표기법의 o/* 기호로만 표시한다 |

## 5. 문제 풀이 규칙

```text
표·계산형: 원본 표 재작성 → 행별 산술(1단계, NULL 전파 여부) → 집계 계산(2단계, NULL 제외 여부, COUNT(*) 예외) → 선지별 결과 비교
```

산술연산(NULL 전파)과 집계함수(NULL 제외)는 서로 반대되는 처리 방식이므로 반드시 단계를 나눠서 계산한다.

## 6. 상세 기출 해설

- [NULL-01 NULL의 의미와 표기법](./NULL-01-NULL의-의미와-표기법.md) — NULL 정의, ERD 표기법별 표시 대표 판례
- [NULL-02 NULL과 비교연산](./NULL-02-NULL과-비교연산.md) — 3값 논리, `IS NULL` vs `=NULL` 대표 판례
- [NULL-03 NULL과 산술연산](./NULL-03-NULL과-산술연산.md) — NULL 전파 대표 판례
- [NULL-04 NULL과 집계함수](./NULL-04-NULL과-집계함수.md) — `COUNT(*)` 예외 대표 판례
