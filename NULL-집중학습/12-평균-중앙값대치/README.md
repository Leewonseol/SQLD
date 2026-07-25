# 12. 평균·중앙값 대치

## 1. 학습 목표

- 결측값(NULL)을 전체 평균(mean) 또는 중앙값(median)으로 대치하는 SQL을
  Oracle/SQL Server 양쪽에서 작성할 수 있다.
- Oracle `MEDIAN()` 집계함수와 SQL Server `PERCENTILE_CONT(0.5) WITHIN
  GROUP(...) OVER()`의 문법 차이를 실습한다.
- 평균은 극단값(outlier)에 민감하고 중앙값은 상대적으로 안정적이라는
  통계 원칙을 실제 데이터로 확인한다.
- `13-kNN결측값대체`에서 kNN 대치와 성능(RMSE)을 비교할 기준값을 만든다.

## 2. 핵심 원리

- 집계함수(`AVG`, `MEDIAN`/`PERCENTILE_CONT`)는 계산 시 NULL을 자동으로
  제외한다(`04-NULL과집계함수` 참고) — 하지만 이는 "NULL을 채워준다"는
  뜻이 아니라 "NULL을 무시하고 나머지로 계산한다"는 뜻이다. 실제로 결측을
  채우려면 계산된 대표값을 `NVL`/`ISNULL`/`COALESCE`로 명시적으로 넣어야
  한다(`02-NULL치환함수` 연결).
- 평균은 모든 값을 더해 개수로 나누므로 극단값 하나가 전체를 크게 흔든다.
  중앙값은 순위 중간값이라 극단값의 영향을 거의 받지 않는다 — 이 폴더의
  데이터셋은 `C012`(target=95000)라는 의도적인 극단값을 포함해서 이 차이를
  수치로 보여준다.

## 3. 공통 입력 데이터 — `impute_practice_raw` (재사용, 새 데이터 아님)

이 폴더는 **새 데이터셋을 만들지 않는다.** [`분석기법/22-KNN결측값대체`](<../../분석기법/22-KNN결측값대체/README.md>)
가 정의한 `impute_practice_raw`(합성 20행)를 **그대로 재사용**한다 — 같은
테이블, 같은 값이어야 `13-kNN결측값대체`의 kNN 대치 결과와 RMSE를 공정하게
비교할 수 있기 때문이다.

- 도너 풀(15행): `target_missing_value`가 관측된 행. C009는 `target=0`이지만
  이는 정상값이지 결측이 아니다(구분 필수 — 8절 함정 참고).
- 대체 대상(5행, C016~C020): `target_missing_value`가 NULL. `true_value_for_check`
  컬럼에 검증용 정답값이 따로 있다(대치 계산에는 절대 쓰지 않는다).
- `C012`(scenario_type=`extreme_value`)는 `target=95000`으로 나머지 값들
  (수십~수백 단위)과 자릿수가 다른 의도적 극단값이다.

**Olist 원자료에는 실제 결측이 없다** — 이 테이블은 Olist와 무관한 별도의
작은 합성 데이터다(`분석기법/22-KNN결측값대체/README.md` "데이터셋 설계"
참고).

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — STEP 1(결측 식별, 0값과 구분) → STEP 2
(`MEDIAN()`으로 전체 평균/중앙값) → STEP 3(극단값 포함/제외 비교) →
STEP 4(`NVL`/`COALESCE` 즉석 대치) → STEP 5(최종 결과 테이블) → STEP 6(RMSE).

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — 로직은 Oracle과 동일하되 STEP 2에서
`MEDIAN()`이 없어 `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ...) OVER ()`
로 대신한다(`SELECT DISTINCT ... OVER()` 패턴으로 여러 행 대신 단일 행
결과를 만든다). STEP 4는 `ISNULL`을 쓴다(단, `ISNULL`은 반환형이 첫 인수
고정이라 `02-NULL치환함수`가 다루는 함정이 여기도 적용될 수 있다).

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고. `impute_practice_raw`는
이미 `분석기법/22-KNN결측값대체`에서 **SQLite로 실제 실행·검증된** 데이터이므로
`overall_mean=6415.8`, `overall_median=96` 등 이 폴더의 수치는 그 검증
결과를 그대로 인용한다.

## 7. 결과 차이의 이유

이 폴더의 계산 결과(평균·중앙값 값 자체)는 Oracle과 SQL Server가 완전히
같다 — 통계 계산은 표준 산술이라 DBMS별로 다를 이유가 없다. 차이는 오직
문법(`MEDIAN()` vs `PERCENTILE_CONT() OVER()`, `NVL` vs `ISNULL`)뿐이다.

## 8. SQLD 함정

- **0을 결측으로 오인** — `C009`처럼 값이 0인 행을 `COALESCE(col, 0)`으로
  다시 채우면 "이미 0인 값"과 "원래 결측이었는데 0으로 채운 값"이 구분 안
  되는 문제가 생긴다. 대치 전에 반드시 `IS NULL`로 진짜 결측만 골라야 한다.
- **평균이 항상 "안전한 기본값"이라는 착각** — `C012` 극단값 하나 때문에
  전체 평균이 6415.8까지 치솟는다. 실제 대체 대상 값들(정답 기준 17~133)과
  비교하면 평균 대치가 얼마나 부정확한 결과를 낳는지 STEP 6 RMSE로 확인된다.
- **`PERCENTILE_CONT`를 일반 집계함수처럼 GROUP BY와 섞어 쓰려다 문법
  오류** — `WITHIN GROUP (ORDER BY ...)`는 order-sensitive 집계 전용 문법이며
  `OVER()`가 필요하다(윈도우 함수로 동작).

## 9. 빅분기 결측치 처리와의 연결

빅데이터분석기사 실기에서 결측치 처리의 가장 기본 전략이 평균/중앙값 대치
(`SimpleImputer(strategy='mean'/'median')`)다. 이 폴더의 SQL 계산은 그
Python 함수가 내부적으로 하는 일을 SQL로 직접 재현한 것이다 — `df.fillna(df.mean())`
↔ STEP 4의 `NVL(col, overall_mean)`, `df.fillna(df.median())` ↔
`COALESCE(col, overall_median)`. "언제 평균 대신 중앙값을 써야 하는가"
(분포가 치우쳐 있거나 극단값이 있을 때)를 STEP 3의 결과로 직접 판단할 수
있다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) 참고.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증** — 이 세션에는 두 DBMS 실행 환경이 없다.
다만 이 폴더가 재사용하는 `impute_practice_raw`와 그 평균/중앙값 계산
로직은 `분석기법/22-KNN결측값대체/optional/01_prepare_sqlite.sql` +
`03_verify_sqlite.sql`로 **이 저장소에서 실제 실행·검증됐다**(SQLite).
Oracle/SQL Server 버전은 같은 로직을 문법만 옮긴 것이라 수치 자체는 그
검증을 근거로 하지만, `MEDIAN()`/`PERCENTILE_CONT()` 문법 자체의 실제
동작은 각 환경에서 재확인이 필요하다.
