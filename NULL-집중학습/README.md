# NULL 집중학습

SQLD(SQL개발자)에서 가장 많이 함정으로 출제되는 주제인 **NULL**을 Oracle·SQL Server
두 DBMS 기준으로 처음부터 끝까지 체계적으로 학습하는 독립 모듈이다.

기존 `분석기법/`, `필기계산문제-멀티DBMS/`, `Olist-고객데이터/`에도 NULL 관련 SQL이
여러 곳에 흩어져 있었지만(예: `필기계산문제-멀티DBMS/문제07-DBMS문법차이`,
`분석기법/22-KNN결측값대체`), NULL의 의미·3값 논리부터 결측값 통계 대치까지를
순서대로 밟아가는 독립된 학습 경로는 없었다. 이 모듈이 그 빈 자리를 채운다.
**기존 모듈은 하나도 삭제·재편하지 않았다** — 이 모듈은 순수 추가다.

## 이 모듈의 목표

1. SQLD에서 출제되는 NULL의 의미와 3값 논리(TRUE/FALSE/UNKNOWN)를 체계적으로 학습한다.
2. Oracle과 SQL Server의 NULL 함수 및 결과 차이를 직접 비교한다.
3. 빅데이터분석기사의 결측치 처리와 기술통계 계산으로 연결한다.
4. 마지막에는 평균·중앙값·kNN 결측값 대치를 종합 실습한다.

## 구조

```
NULL-집중학습/
├─ README.md                        -- 이 파일
├─ 00-NULL의미와3값논리/             -- NULL의 정의, TRUE/FALSE/UNKNOWN 3값 논리
├─ 01-NULL판정/                      -- IS NULL, =NULL 함정, 빈 문자열/공백 판정
├─ 02-NULL치환함수/                  -- NVL/NVL2/ISNULL/COALESCE/NULLIF/CASE + 자료형·길이
├─ 03-NULL과산술연산/                -- NULL 산술, 문자열 결합, NULLIF로 0 나누기 방지
├─ 04-NULL과집계함수/                -- COUNT(*)/COUNT(col), AVG/SUM/MIN/MAX의 NULL 처리
├─ 05-NULL과문자열/                  -- ||/CONCAT, +/CONCAT, LENGTH/LEN/DATALENGTH
├─ 06-NULL과WHERE-CASE/              -- WHERE·CASE WHEN에서 UNKNOWN 처리
├─ 07-NULL과JOIN/                    -- JOIN 키 NULL, UNION/INTERSECT/MINUS/EXCEPT
├─ 08-NOT-IN과NOT-EXISTS/            -- NOT IN + NULL 함정, NOT EXISTS와의 차이
├─ 09-NULL정렬과윈도우함수/           -- NULL 정렬 순서, ROW_NUMBER/RANK/DENSE_RANK
├─ 10-NULL과형변환/                  -- CAST/CONVERT, TO_CHAR/TO_DATE와 NULL
├─ 11-NULL과제약조건/                -- CHECK/UNIQUE/PK/FK와 NULL
├─ 12-평균-중앙값대치/                -- impute_practice_raw 재사용, 평균·중앙값 대치
├─ 13-kNN결측값대체/                 -- impute_practice_raw 재사용, kNN 대치
└─ 14-종합문제/                      -- 00~13을 종합하는 최종 실습
```

각 주제 폴더(`00`~`11`)는 공통 파일 6종을 갖는다.

| 파일 | 내용 |
|---|---|
| `README.md` | 아래 12절 고정 형식 |
| `oracle.sql` | Oracle에서 그대로 실행 가능한 완전한 SQL(DDL+DML+조회) |
| `sqlserver.sql` | SQL Server에서 그대로 실행 가능한 완전한 SQL |
| `expected_results.md` | 각 쿼리의 예상 결과와 Oracle/SQL Server 차이 표 |
| `quiz.sql` | SQLD 스타일 연습문제(주석으로 문제, 빈 SQL 또는 객관식) |
| `answer.sql` | 연습문제 정답과 해설 |

`12-평균-중앙값대치`, `13-kNN결측값대체`는 `분석기법/22-KNN결측값대체`의
`impute_practice_raw` 테이블(합성 20행)을 **그대로 재사용**한다 — 새로 만든
테이블이 아니다. `14-종합문제`도 같은 6개 파일 구조를 따르되, 새 SQL을
추가하는 대신 `null_lab_customer`(00~11)와 `impute_practice_raw`(12~13)
두 데이터셋을 모두 활용해 00~13 전체를 종합하는 문제로 구성했다.

### README 고정 12절 형식

1. 학습 목표
2. 핵심 원리
3. 공통 입력 데이터
4. Oracle SQL
5. SQL Server SQL
6. 예상 결과
7. 결과 차이의 이유
8. SQLD 함정
9. 빅분기 결측치 처리와의 연결
10. 연습문제
11. 정답 해설
12. 실제 실행 검증 여부

## 공통 테스트 데이터 — `null_lab_customer` / `null_lab_dept` / `null_lab_excluded_codes`

`00`~`11` 폴더는 모두 같은 3개 테이블을 각자의 `oracle.sql`/`sqlserver.sql` 맨 앞에
동일하게 재생성한다(저장소의 다른 모듈처럼 폴더마다 완전히 자기완결적인 스크립트를
유지하기 위해 공유 파일로 분리하지 않고 각 파일에 복사했다). 세 테이블 모두
**Olist 원자료와 무관한, 이 학습 모듈 전용의 작은 합성(synthetic) 데이터**다.

`null_lab_customer` (12행) — 아래 항목을 모두 담는다.

| 항목 | 위치 |
|---|---|
| 실제 NULL | `nickname`(2,8행), `score`(3,9행), `age`(5행), `purchase_amt`(5,11행), `dept_code`(4,10행), `join_date`(3,11행), `discount_qty`(7행) |
| 빈 문자열 `''` | `nickname` 3행(Oracle에서는 저장 시 NULL로 바뀜) |
| 공백 한 칸 `' '` | `nickname` 4행 |
| 숫자 0 | `age` 4행, `score` 6행, `order_qty` 6행, `purchase_amt` 4행, `discount_qty` 2행(분모 0) |
| 문자열 `'0'` | `membership_code` 5행 |
| 일반 문자열 | 대부분의 `customer_name`/`nickname` |
| 분모 0 | `discount_qty` 2행(0) — 7행은 NULL이라 0과 다른 결과(에러 vs NULL)를 비교 |
| 집계 대상 숫자 NULL | `score` 3,9행 |
| JOIN 키 NULL | `dept_code` 4,10행(NULL), 8행(`'D99'`, `null_lab_dept`에 없는 코드 — 불일치) |
| 자료형이 다른 대체 후보 | `age`(NUMBER/INT) vs `membership_code`(VARCHAR) vs `join_date`(DATE) — 02 폴더에서 COALESCE/NVL에 섞어 씀 |

`null_lab_dept` (3행, `D01`/`D02`/`D03`) — `null_lab_customer.dept_code`의 정상
참조 대상. 4·10행(NULL)과 8행(`D99`)은 일부러 대응 부서가 없다.

`null_lab_excluded_codes` (3행, `'D02'`, `'D03'`, `NULL`) — `NOT IN` 서브쿼리
결과에 NULL이 섞이는 고전적 함정(`08-NOT-IN과NOT-EXISTS`)을 위한 전용 테이블.

전체 DDL/INSERT 원문은 `00-NULL의미와3값논리/oracle.sql` · `00-NULL의미와3값논리/sqlserver.sql`을
기준으로 한다(가장 먼저 이 데이터를 쓰는 폴더). 이후 폴더는 필요한 컬럼만 쓰더라도
테이블 전체를 동일하게 재생성해 스크립트 하나만 복사해도 바로 실행되게 했다.

## Oracle·SQL Server 실행 검증 상태

이 저장소의 세션에는 Oracle·SQL Server 실행 환경이 없다(`../README.md` §5 참고).
`00`~`11`의 `oracle.sql`/`sqlserver.sql`은 **문법·의미 기준으로 작성한 미검증
스크립트**이며, 실제로 실행하지 않은 것을 실행했다고 보고하지 않는다. 각 폴더
README의 "12. 실제 실행 검증 여부"에 이 사실을 명시한다. `12-평균-중앙값대치`,
`13-kNN결측값대체`가 재사용하는 `impute_practice_raw` 파이프라인은
`분석기법/22-KNN결측값대체`에서 **SQLite로 실제 실행·검증된 로직**을 Oracle/SQL
Server 문법으로 옮긴 것이므로 수치 자체는 그 검증을 근거로 한다.

DuckDB·MariaDB·SQLite 코드는 이 모듈에서 새로 만들지 않는다. 보조로 참고할 때는
`분석기법/22-KNN결측값대체/optional/`, `필기계산문제-멀티DBMS/문제07.../run_compare.py`
등 기존 파일을 링크로만 연결한다.

## 관련 모듈

- [`Concepts/NULL.md`](../Concepts/NULL.md), [`Concepts/DBMS 문법 차이(Oracle-SQLServer).md`](<../Concepts/DBMS 문법 차이(Oracle-SQLServer).md>) — 저장소 공통 NULL/DBMS 비교 개념 노트
- [`필기계산문제-멀티DBMS/문제07-DBMS문법차이-문자열날짜LIMIT`](<../필기계산문제-멀티DBMS/문제07-DBMS문법차이-문자열날짜LIMIT/README.md>) — 계산형 문제에서의 NULL·문자열·날짜 문법 차이
- [`분석기법/22-KNN결측값대체`](<../분석기법/22-KNN결측값대체/README.md>) — `impute_practice_raw`의 원본 모듈, kNN 대체 10단계 전체 파이프라인
- [`Olist-고객데이터/01-기본탐색`](<../Olist-고객데이터/01-기본탐색>)의 `08_null_behavior_demo_*.sql` — 실데이터 문맥에서의 NULL 시연(Olist 원자료 자체에는 결측 없음)
