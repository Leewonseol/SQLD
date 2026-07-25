# 10. NULL과 형변환

## 1. 학습 목표

- `CAST`/`CONVERT` 등 어떤 형변환 함수를 쓰더라도 NULL을 값 있는 상태로
  바꿀 수 없다는 기본 원칙을 확인한다.
- Oracle `TO_CHAR`/`TO_NUMBER`/`TO_DATE`와 SQL Server `CONVERT`/`CAST`/
  `TRY_CONVERT`/`TRY_CAST`에 NULL을 입력했을 때 모두 NULL을 반환함을
  확인한다.
- 자료형이 섞인 컬럼(`membership_code`)을 명시적으로 숫자로 변환할 때,
  변환 불가능한 값을 만나면 Oracle은 `ORA-01722`, SQL Server는 변환 에러를
  낸다는 것과, 이를 안전하게 피하는 `TRY_CAST`/`TRY_CONVERT`(SQL Server)와
  `TO_NUMBER(... DEFAULT NULL ON CONVERSION ERROR)`(Oracle)를 비교한다.
- 날짜를 문자열로 변환할 때 NULL 행은 여전히 SQL NULL로 남지, 문자열
  `"NULL"`이 되지 않는다는 것을 확인한다.

## 2. 핵심 원리

- 형변환 함수(`CAST`, `CONVERT`, `TO_CHAR`, `TO_NUMBER`, `TO_DATE` 등)는
  값의 **표현 형식**만 바꿀 뿐, "값이 없음"이라는 NULL의 상태 자체를
  없애지 못한다. `CAST(NULL AS 어떤자료형)`은 언제나 그 자료형의 NULL이다.
- **Oracle**: `TO_CHAR`, `TO_NUMBER`, `TO_DATE`에 NULL을 넣으면 예외 없이
  NULL을 반환한다. 반면 변환 **불가능한 실제 값**(예: `'A001'`을 숫자로)을
  넣으면 `ORA-01722: invalid number` 같은 런타임 에러가 발생한다 — "NULL
  입력"과 "잘못된 값 입력"은 전혀 다른 상황이라는 점이 핵심이다.
- **SQL Server**: `CONVERT`, `CAST`에 NULL을 넣어도 마찬가지로 NULL을
  반환한다. 변환 불가능한 값을 넣으면 SQL Server도 에러를 던진다(Oracle과
  동일). 다만 SQL Server 2012부터는 `TRY_CONVERT`/`TRY_CAST`가 추가되어,
  변환에 실패하면 에러 대신 **NULL을 반환**하도록 만들 수 있다.
- **Oracle에는 `TRY_CAST`가 없다.** 대신 Oracle 12c부터 `TO_NUMBER`,
  `TO_DATE`, `TO_CHAR`에 `DEFAULT 값 ON CONVERSION ERROR` 절을 붙여
  `TRY_CAST`와 비슷한 효과(변환 실패 시 지정한 기본값, 보통 NULL을 반환)를
  낼 수 있다. 12c 이전 버전에는 이 구문도 없어 PL/SQL의 예외 처리
  (`EXCEPTION WHEN VALUE_ERROR`)로 우회해야 했다.
- 날짜를 문자열로 변환(`TO_CHAR(join_date, ...)`, `CONVERT(VARCHAR, ...,
  120)`)할 때 원본 `join_date`가 NULL이면 변환 결과도 NULL이다. 이는 진짜
  문자열 `"NULL"`이 아니라 SQL의 NULL이라는 것 — 화면에 "NULL"이라는
  글자가 찍히는 것은 클라이언트 툴(SQL*Plus, SSMS 등)이 NULL을 표시하는
  방식일 뿐, DB 안에 저장된 값이 문자열 `"NULL"`인 것은 아니다.

## 3. 공통 입력 데이터

`00-NULL의미와3값논리`와 완전히 같은 `null_lab_customer`/`null_lab_dept`/
`null_lab_excluded_codes`를 재사용한다. 이 폴더가 실제로 쓰는 컬럼:

- `membership_code`(VARCHAR2(5)/VARCHAR(5)) — customer_id=5만 `'0'`(숫자로
  변환 가능), 나머지는 `'A001'`~`'A012'` 형태(숫자로 변환 불가능).
- `join_date`(DATE, NULL 2행: customer_id 3, 11) — 문자열 변환 시 NULL
  유지 확인.

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — 공통 데이터셋 생성 후 4단계.

1. `CAST(NULL AS ...)`이 여전히 NULL임을 확인
2. `TO_CHAR(NULL)`/`TO_NUMBER(NULL)`/`TO_DATE(NULL)` 모두 NULL 확인
3. `membership_code`를 숫자로 변환 — 정상 변환(3-1), `ORA-01722` 에러
   데모(3-2, 의도된 에러), `TO_NUMBER ... DEFAULT NULL ON CONVERSION
   ERROR`로 안전하게 변환(3-3)
4. `join_date`를 `TO_CHAR(..., 'YYYY-MM-DD')`로 변환 — NULL 행은 NULL로
   유지됨을 확인

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — 로직은 Oracle과 같되, 안전한 변환에
`TRY_CAST`/`TRY_CONVERT`를 쓰고, 날짜 문자열 변환에 `CONVERT(VARCHAR(10),
join_date, 120)`을 쓴다.

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고.

## 7. 결과 차이의 이유

NULL을 형변환하면 NULL이 나온다는 원칙 자체는 두 DBMS가 완전히 같다(ANSI
SQL 공통 규칙). 차이가 나는 지점은 **"변환 불가능한 실제 값"을 만났을 때의
에러 처리 방식**이다 — Oracle은 12c 이전까지 예외 처리 없이는 변환 실패를
피할 방법이 없었고(에러를 던지거나, PL/SQL로 감싸거나 둘 중 하나), SQL
Server는 2012부터 `TRY_CONVERT`/`TRY_CAST`라는 전용 함수를 SQL 레벨에서
바로 제공해 더 간단하게 안전한 변환을 쓸 수 있게 했다. 이는 NULL 처리
규칙의 차이가 아니라 **각 벤더가 "변환 실패"라는 별개의 문제를 해결한
시점과 방식의 차이**다.

## 8. SQLD 함정

- **"형변환하면 NULL이 어떤 기본값(0, 빈 문자열 등)으로 바뀔 것"이라는
  착각** — `CAST(NULL AS NUMBER)`는 0이 아니라 여전히 NULL이다. 기본값을
  넣으려면 `NVL`/`COALESCE`/`ISNULL`을 형변환과 별도로 써야 한다(`02` 폴더
  참고).
- **"TO_NUMBER/TO_DATE에 NULL을 넣으면 에러가 난다"는 착각** — NULL 입력은
  에러가 아니라 그냥 NULL을 반환한다. 에러가 나는 건 "값은 있지만 변환할
  수 없는 형식"일 때뿐이다. 이 둘을 구분하지 못하면 시험에서 결과를
  잘못 예측하게 된다.
- **"Oracle에도 TRY_CAST가 있을 것"이라는 착각** — Oracle에는 이 함수가
  없다. `DEFAULT ... ON CONVERSION ERROR`(12c+)가 실질적인 대체제라는
  것을 알고 있어야 한다.
- **`membership_code`처럼 문자열 컬럼에 숫자 문자열과 비숫자 문자열이
  섞여 있을 때, 전체 컬럼에 `CAST(col AS NUMBER)`를 무심코 걸었다가
  런타임에야 에러를 발견하는 함정** — 실무에서 데이터 정제 없이 형변환을
  거는 흔한 실수 패턴이다. `TRY_CAST`나 `DEFAULT ON CONVERSION ERROR`로
  먼저 안전하게 훑어본 뒤 실제 변환을 걸어야 한다.

## 9. 빅분기 결측치 처리와의 연결

빅데이터분석기사 실기에서 `pandas.to_numeric(series, errors='coerce')`는
숫자로 변환할 수 없는 값을 NaN(결측)으로 바꿔준다 — 이것이 정확히 SQL
Server의 `TRY_CAST`/`TRY_CONVERT`, Oracle의 `DEFAULT NULL ON CONVERSION
ERROR`와 같은 역할을 한다(`errors='raise'`가 기본값 CAST/CONVERT의 에러
발생 동작에 대응). 자료형이 섞인 원본 컬럼을 숫자로 강제 변환해야 할 때
"실패하면 에러를 낼지, 결측으로 처리하고 넘어갈지"를 선택하는 것은 SQL과
Python 데이터 파이프라인 모두에서 똑같이 마주치는 설계 결정이다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) 참고.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증** — 이 세션에는 두 DBMS를 실행할 환경이
없다(저장소 루트 `README.md` §5, `../README.md` 참고). `ORA-01722` 에러
메시지, SQL Server 변환 에러 메시지, `TRY_CAST`/`TRY_CONVERT`의 버전
지원 범위(2012+), Oracle `DEFAULT ... ON CONVERSION ERROR`의 버전
지원 범위(12c+)는 각 벤더 공식 문서에 근거해 작성했으며, `oracle.sql`/
`sqlserver.sql`은 각자의 환경에 그대로 복사해 실행할 수 있는 완전한
스크립트다. 실행했다고 보고하지 않는다 — 실제 결과는 각 환경에서
재확인이 필요하다.
