# 07 단일행 함수 — 단원 안내 (별도 학습 분기)

단일행 함수는 **행마다 하나의 결과**를 낸다. SELECT·WHERE·ORDER BY·GROUP BY 어디에나 쓸 수 있으므로 처리 순서의 특정 단계에 속하지 않는다.
여러 행을 하나로 요약하는 집계함수(06단원)와 다르다.

> **원본 근거 주의**: 텍스트 추출본에는 문자·숫자·날짜·변환·NULL 함수 본문이 없다(SOURCE_ACCESS_REPORT "판독할 수 없었던 내용").
> 이 단원은 요구목록 §7을 근거로 작성했다. PDF가 실제로 다루는 함수 목록·설명과 대조하는 일은 **미완료**다.
> 함수 이름과 동작은 두 DBMS에서 실행해 확인했다.

| 실습 | 주제 |
|---|---|
| [ex01](examples/ex01_char_functions.md) | 문자 함수 |
| [ex02](examples/ex02_number_functions.md) | 숫자 함수 |
| [ex03](examples/ex03_date_functions.md) | 날짜 함수·날짜 연산 |
| [ex04](examples/ex04_conversion_functions.md) | 변환 함수·암시적 변환 |
| [ex05](examples/ex05_null_functions.md) | NVL·NVL2·ISNULL·NULLIF·COALESCE |
| [ex06](examples/ex06_case_decode.md) | CASE·DECODE·IIF·CHOOSE |
| [ex07](examples/ex07_regex.md) | 정규 표현식(Oracle) |

## Oracle ↔ SQL Server 함수 대응표 (실행 확인)
| 목적 | Oracle 21c | SQL Server 2022 | 결과 차이 |
|---|---|---|---|
| 첫 글자 대문자 | INITCAP | 없음(Msg 195) | |
| 길이 | LENGTH / LENGTHB | LEN / DATALENGTH | **LEN은 뒤 공백 제외**('AB  '→2), LENGTH는 4. `LENGTH('')`는 NULL, `LEN('')`은 0 |
| 부분 문자열 | SUBSTR(s, 시작[, 길이]), 음수 시작 | SUBSTRING(s, 시작, 길이) 길이 필수, RIGHT | |
| 위치 | INSTR(s, 찾을값, 시작, n번째) | CHARINDEX(찾을값, s, 시작) | **인수 순서 반대**, n번째 없음 |
| 채우기 | LPAD / RPAD | 없음 → RIGHT(REPLICATE()+s) | |
| 지정 문자 TRIM | LTRIM(s, c), TRIM(LEADING c FROM s) | 2022부터 같은 문법 | 2019 이하에서는 불가(외부 문서 기준, 미실행) |
| 결합 | `\|\|`, CONCAT(2개) | `+`, CONCAT(여러 개) | NULL 처리 다름(04단원 ex03) |
| 문자 코드 | ASCII / CHR | ASCII / CHAR | |
| 버림 | TRUNC(x, n) | ROUND(x, n, 1) | |
| 올림 | CEIL | CEILING | |
| 나머지 | MOD(a, b) | a % b | |
| 정수 나눗셈 | `7/2` = 3.5 | `7/2` = **3** | |
| 날짜 + n | DATE + 1 (일) | DATEADD(DAY, 1, d). DATE + 1은 Msg 206, DATETIME + 1은 허용 | |
| 개월 더하기 | ADD_MONTHS | DATEADD(MONTH) | 둘 다 1/31 + 1개월 = 2/29 |
| 개월 차이 | MONTHS_BETWEEN (실수) | DATEDIFF(MONTH) (경계 횟수, 정수) | 1/31→2/1: **0.0323 vs 1** |
| 말일 | LAST_DAY | EOMONTH | |
| 절사 | TRUNC(d, 'MM') | DATETRUNC(MONTH, d) (2022+) | |
| 현재 시각 | SYSDATE, SYSTIMESTAMP | GETDATE(), SYSDATETIME() | |
| 형변환 | TO_CHAR / TO_NUMBER / TO_DATE / CAST | CAST / CONVERT(스타일) / FORMAT / TRY_CAST | |
| `'10' + '1'` | 11 (산술) | '101' (결합) | **다름** |
| NULL 대체 | NVL, NVL2 | ISNULL, IIF | ISNULL은 첫 인수 길이로 잘림 |
| 조건 값 | CASE, DECODE | CASE, IIF, CHOOSE | DECODE는 NULL=NULL을 일치로 봄 |
| 정규식 | REGEXP_LIKE/SUBSTR/INSTR/COUNT/REPLACE | 2022 없음 → LIKE `[ ]`, PATINDEX | |
