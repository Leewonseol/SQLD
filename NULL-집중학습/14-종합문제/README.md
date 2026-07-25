# 14. 종합문제

## 1. 학습 목표

- `00`~`13` 전체에서 배운 NULL 관련 규칙(3값 논리, 판정, 치환함수, 산술·
  문자열, 집계, WHERE/CASE, JOIN, NOT IN/NOT EXISTS, 정렬·윈도우함수,
  형변환, 제약조건, 평균·중앙값·kNN 대치)을 하나의 문제 세트로 종합 점검한다.
- 두 공통 데이터셋(`null_lab_customer` 계열, `impute_practice_raw`)을 모두
  다루며 SQLD 실전 시험처럼 여러 개념이 한 문제에 섞여 나오는 상황에 대비한다.

## 2. 핵심 원리

이 폴더는 새로운 개념을 소개하지 않는다. 대신 `00`~`13`에서 확립된
원칙들을 한 문제 세트 안에서 조합해 "어떤 상황에 어떤 규칙을 적용해야
하는가"를 판단하는 훈련에 집중한다. 각 문제는 특정 폴더 하나에 대응되도록
설계했다 — 막히면 해당 폴더의 README로 돌아가 복습하라.

## 3. 공통 입력 데이터

`00`~`11`이 쓰는 `null_lab_customer`/`null_lab_dept`/`null_lab_excluded_codes`
**와** `12`~`13`이 쓰는 `impute_practice_raw`를 **모두** 이 폴더의
`oracle.sql`/`sqlserver.sql`에 그대로 복사해 재구성한다. 새로 만든 데이터는
없다 — 두 데이터셋 모두 앞선 폴더들과 완전히 동일하다.

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — 4개 테이블(`null_lab_customer`, `null_lab_dept`,
`null_lab_excluded_codes`, `impute_practice_raw`)을 모두 재생성하고, 마지막에
행 수·NULL 개수를 요약하는 점검 쿼리로 두 데이터셋이 정상 준비됐는지
확인한다. 실제 종합문제는 [`quiz.sql`](./quiz.sql)에 있다.

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — Oracle과 동일한 구성. `null_lab_customer`의
`null_nickname_count`가 Oracle(3행, `''`가 NULL로 바뀐 3번 행 포함)과
SQL Server(2행)에서 다르게 나온다는 것이 이 종합 점검 쿼리에서도 다시
확인된다(`01-NULL판정`과 동일한 결과).

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고.

## 7. 결과 차이의 이유

각 문제가 참조하는 개별 폴더(`00`~`13`)의 "7. 결과 차이의 이유" 절과 동일한
이유가 그대로 적용된다 — 이 폴더에서 새로 생기는 차이는 없다.

## 8. SQLD 함정

`00`~`13`에서 다룬 함정들이 한 문제 세트에 섞여 나올 때 가장 흔한 실수는
**"이 문제가 어떤 규칙에 해당하는지 착각하는 것"**이다. 예를 들어 NOT IN
문제(08)를 NOT EXISTS 문제로 착각하고 답하거나, CHECK 제약조건(11)의
UNKNOWN 통과 규칙을 WHERE(06)의 UNKNOWN 배제 규칙과 반대로 기억하는 식이다.
`quiz.sql`을 풀 때 답이 확실하지 않으면 반드시 해당 폴더 README의 "2. 핵심
원리"를 다시 확인하라.

## 9. 빅분기 결측치 처리와의 연결

`12`(평균·중앙값 대치)와 `13`(kNN 대치)를 함께 놓고 보면, 빅분기 실기에서
결측치 처리 전략을 고를 때 "왜 이 방법을 선택했는가"를 데이터 기반으로
설명해야 한다는 것을 알 수 있다 — RMSE 비교(Q13)가 그 판단 근거의 예시다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) — 14문항, `00`~`13` 각 폴더에 하나씩 대응.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증** — 이 세션에는 두 DBMS 실행 환경이 없다.
`impute_practice_raw` 관련 문제(Q13)의 수치는 `분석기법/22-KNN결측값대체`
에서 SQLite로 실제 실행·검증된 결과를 인용한다. 나머지 문제(`null_lab_customer`
관련)는 이 모듈의 `00`~`11` 폴더와 동일하게 문법·3값 논리 규칙 기준으로
작성한 미검증 스크립트다.
