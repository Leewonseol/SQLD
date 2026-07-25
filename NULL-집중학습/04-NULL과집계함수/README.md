# 04. NULL과 집계함수 — COUNT/SUM/AVG/MIN/MAX의 NULL 처리

## 1. 학습 목표

- `COUNT(*)`(NULL 포함 전체 행 수)와 `COUNT(컬럼)`(NULL 제외 행 수)의 차이를
  직접 비교한다.
- `AVG(score)`(NULL 제외 평균)와 `AVG(COALESCE(score, 0))`(NULL을 0으로
  치환한 평균)이 서로 다른 값이라는 것을 정확한 수치로 확인한다.
- `SUM`/`MIN`/`MAX`도 `COUNT`/`AVG`와 마찬가지로 **NULL을 집계 대상에서
  제외**하고 계산한다는 공통 원칙을 확인한다.
- 집계 대상 그룹의 값이 전부 NULL이거나, 대상 행 자체가 0개일 때
  `SUM`/`AVG`/`MIN`/`MAX`는 NULL을 반환하지만 `COUNT`는 0을 반환한다는
  차이를 확인한다.
- SQL Server 고유의 함정 — 정수(`INT`) 컬럼을 `CAST` 없이 `AVG`하면 결과
  타입도 `INT`로 고정되어 소수부가 잘린다는 것을 직접 확인한다.

## 2. 핵심 원리

- **집계함수의 공통 원칙: NULL은 무시하고 계산한다.** `COUNT(컬럼)`,
  `SUM`, `AVG`, `MIN`, `MAX` 모두 NULL 값을 애초에 계산 대상에서 제외한다
  — "NULL을 0으로 취급해서 계산"하는 것이 아니라 "그 값이 없는 셈 치고"
  계산한다는 뜻이다. 유일한 예외는 `COUNT(*)`인데, 이것은 컬럼 값을 보는
  게 아니라 행 자체의 존재 여부만 세기 때문에 NULL과 무관하게 모든 행을
  센다.
- **`AVG(컬럼)` ≠ `AVG(COALESCE(컬럼, 0))`.** 전자는 "NULL이 아닌 값들만의
  평균"이고 후자는 "NULL을 0으로 본 전체 값의 평균"이다. NULL 비율이 높을
  수록 두 값의 차이가 커진다 — 이 폴더의 `score` 컬럼(12개 중 2개 NULL)
  기준으로 74.8과 62.33...만큼 차이가 난다.
- **집계 대상이 아예 없거나(0행) 전부 NULL이면**: `COUNT(*)`/`COUNT(컬럼)`은
  **0**을 반환하지만, `SUM`/`AVG`/`MIN`/`MAX`는 **NULL**을 반환한다. "0행을
  집계하면 SUM은 0이 될 것"이라는 직관은 틀렸다 — 더할 값 자체가 하나도
  없으므로 결과는 "알 수 없음(NULL)"이 되는 것이 SQL의 논리다.
- **SQL Server 고유 함정 — `AVG(INT)`의 반환 타입.** SQL Server는
  `AVG`(그리고 `SUM`)의 반환 데이터 타입을 입력 컬럼의 타입 카테고리를
  따라 결정한다(공식 문서 근거). `score`가 `INT`로 선언되어 있으면
  `AVG(score)`의 반환 타입도 `INT`로 고정되어, 계산 과정에서 생긴 소수부가
  **반올림이 아니라 절삭(truncate)**된다. 정확한 소수 평균을 얻으려면
  `AVG(CAST(score AS DECIMAL(10,2)))`처럼 명시적으로 소수 타입으로 변환한
  뒤 평균을 내야 한다. Oracle의 `NUMBER`는 정수/소수 구분이 없어 이 문제가
  아예 발생하지 않는다.

## 3. 공통 입력 데이터

`00-NULL의미와3값논리`와 완전히 같은 `null_lab_customer`/`null_lab_dept`/
`null_lab_excluded_codes`를 재사용한다(전체 DDL/INSERT는
[`oracle.sql`](./oracle.sql), [`sqlserver.sql`](./sqlserver.sql) 참고). 이
폴더의 핵심 컬럼은 `score`다.

`score` 값(customer_id 1~12 순): `85, 92, NULL, 77, 60, 0, 88, 95, NULL, 70,
82, 99` — NULL은 customer_id 3, 9이고, customer_id=6은 실제 숫자 **0**(NULL
아님)이라는 점이 `MIN(score)`의 결과에 직접 영향을 준다. `dept_code`
(customer_id 4, 10이 NULL, 나머지는 D01/D02/D03/D99)로 `GROUP BY`했을 때의
그룹별 집계도 함께 다룬다(자세한 배치는
[`../README.md`](../README.md)의 "공통 테스트 데이터" 표 참고).

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — 공통 데이터셋 생성 후 4단계.

1. `COUNT(*)` vs `COUNT(score)` — 12 vs 10
2. `AVG(score)` vs `AVG(COALESCE(score, 0))` — 74.8 vs 62.333...
3. `SUM`/`MIN`/`MAX(score)` 전체·부서별(`GROUP BY dept_code`) 확인
4. `WHERE score IS NULL GROUP BY dept_code`(그룹 전체가 NULL)와 `WHERE 1=0`
   (빈 결과 집합)에서 `SUM`/`AVG`/`MIN`/`MAX`가 NULL이 되고 `COUNT`만 0이
   됨을 확인

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — 로직은 Oracle과 동일하되 STEP 2, 3에서
`score`가 `INT`로 선언된 것 때문에 `AVG(score)`를 `CAST` 없이 그대로 쓰면
소수부가 절삭된다는 차이가 추가된다. 정렬에도 Oracle의 `NULLS LAST`가 없어
`CASE WHEN dept_code IS NULL THEN 1 ELSE 0 END`으로 대신했다(`09` 폴더에서
상세히 다룸).

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고. `AVG(score)` = 74.8,
`AVG(COALESCE(score,0))` = 62.333...(정확한 계산 근거 포함).

## 7. 결과 차이의 이유

- `COUNT`/`SUM`/`AVG`/`MIN`/`MAX`가 NULL을 무시한다는 원칙은 표준 SQL
  공통 규칙이라 Oracle과 SQL Server의 계산 로직 자체는 같다.
- SQL Server의 `AVG(INT)` 절삭은 Oracle과의 계산 로직 차이가 아니라, 두
  DBMS의 **숫자 타입 시스템 차이**(SQL Server는 정수/소수 타입이 엄격히
  분리, Oracle의 `NUMBER`는 통합)에서 비롯된 결과 타입 결정 규칙의 차이다
  — 02, 03 폴더에서 이미 확인한 "Oracle NUMBER vs SQL Server INT" 차이가
  집계함수에서도 똑같이 재현된 것이다.
- 빈 결과 집합/전체 NULL 그룹에서 `COUNT`만 0이고 나머지가 NULL인 이유는,
  `COUNT`는 "행이 존재하는지"를 세는 것이라 대상이 없으면 자연스럽게 0이
  되지만, `SUM`/`AVG`/`MIN`/`MAX`는 "값들 사이의 연산 결과"이므로 더하거나
  비교할 값 자체가 하나도 없으면 그 결과를 "알 수 없다(NULL)"로 처리하는
  것이 논리적으로 일관되기 때문이다.

## 8. SQLD 함정

- **"COUNT(*)와 COUNT(컬럼)은 결국 같은 값이다"라는 착각** — 컬럼에 NULL이
  하나라도 있으면 두 값은 달라진다. SQLD는 이 차이를 이용해 "몇 명이
  실제로 점수를 입력했는가"와 "전체 고객 수는 몇 명인가"를 구분하는 문제를
  자주 낸다.
- **"AVG(COALESCE(score,0))이 원래 AVG(score)와 같은 값일 것"이라는 착각** —
  NULL을 0으로 채우고 평균을 내면 분모(개수)가 늘어나므로 평균값 자체가
  작아진다. "결측치를 0으로 채우는 것"과 "결측치를 무시하는 것"은 통계적으로
  전혀 다른 결정이라는 것을 명심해야 한다.
- **SQL Server에서 `AVG(정수컬럼)`을 그대로 리포트에 쓰고 "소수점이 왜
  없지?"라고 당황하는 함정** — 에러가 나지 않기 때문에 더 위험하다.
  정수 컬럼을 평균 낼 때는 반드시 `CAST`/`CONVERT`로 소수 타입 변환을
  먼저 해야 한다.
- **"집계 대상 행이 하나도 없으면 SUM은 0이 나올 것"이라는 착각** — 실제로는
  NULL이 나온다. 이 값을 그대로 다른 계산(`COALESCE`로 방어하지 않은 채)에
  또 쓰면 NULL이 연쇄적으로 전파된다(03 폴더의 NULL 산술 전파와 연결).
- **`MIN(score)=0`을 보고 "score가 NULL인 행이 있다"고 착각** — 0은 엄연히
  실제 값이며 NULL과 다르다. 이 폴더의 데이터셋이 일부러 실제 0(customer_id
  =6)과 NULL(customer_id 3, 9)을 함께 배치한 이유가 바로 이 구분을
  훈련하기 위함이다.

## 9. 빅분기 결측치 처리와의 연결

- `COUNT(*)` vs `COUNT(score)`의 차이는 pandas의 `len(df)`(전체 행 수) vs
  `df['score'].count()`(결측 제외 개수)의 차이와 정확히 대응된다.
- `AVG(score)` vs `AVG(COALESCE(score,0))`의 차이는 `df['score'].mean()`
  (기본적으로 `NaN`을 제외하고 평균, `skipna=True`가 기본값)과
  `df['score'].fillna(0).mean()`(결측을 0으로 채운 뒤 평균)의 차이와
  정확히 같은 구조다 — 빅분기 실기에서 "결측치를 0으로 대치할지, 그냥
  제외하고 통계를 낼지"를 결정하는 순간이 바로 이 두 계산 중 어느 것을
  쓸지 고르는 순간이다.
- SQL Server의 `AVG(INT)` 절삭 문제는 pandas에서 정수형(`int64`) 컬럼에
  결측치가 하나라도 있으면 자동으로 `float64`로 승격되어 이런 절삭 문제가
  아예 발생하지 않는 것과 대조적이다 — "결측치가 있으면 자동으로 타입이
  안전하게 바뀐다"는 pandas의 편의성이 SQL(특히 SQL Server)에는 그대로
  적용되지 않는다는 것을 보여주는 사례다.
- 그룹별 집계에서 전체가 NULL인 그룹의 `SUM`/`AVG`가 NULL이 되는 것은
  `df.groupby('dept_code')['score'].mean()`에서도 그 그룹의 모든 값이
  `NaN`이면 결과가 `NaN`으로 나오는 것과 원리가 같다 — 이후 12~13 폴더의
  평균/중앙값/kNN 대치 실습에서 "대치할 기준값 자체가 없는 그룹을 어떻게
  처리할지"가 실제 문제로 다시 등장한다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) 참고.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증** — 이 세션에는 두 DBMS를 실행할 환경이
없다(`../README.md`, 저장소 루트 `README.md` §5 참고). `oracle.sql`/
`sqlserver.sql`은 표준 SQL의 집계함수 NULL 처리 규칙과 SQL Server
`AVG(INT)` 절삭 규칙(Microsoft 공식 문서 근거)을 바탕으로 작성한 완전한
스크립트이며, `expected_results.md`에 실린 모든 수치는 직접 손으로 계산해
검산했다(748/10=74.8, 748/12=62.333...). 다만 이 세션에서 실제 DBMS로
실행해 재확인하지는 않았다 — 사용자가 각자의 환경에 그대로 복사해 실행할
수 있다.
