---
type: technique
pilot: true
category: 결측값-처리-kNN대체
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
grounding_paper: "잠재프로파일 결측값에 대한 논문.pdf (저장소 루트)"
---

# kNN 결측값 대체 — Oracle · SQL Server NULL 문법 통합 실습

이 모듈은 저장소 루트의 `잠재프로파일 결측값에 대한 논문.pdf`
(잠재프로파일 분석에서 결측값 처리를 위한 최근접이웃 대체법의 활용)를 근거로,
**"kNN 결측값 대체"라는 하나의 실제 분석 문제**를 통해 Oracle과 SQL Server의
NULL 함수·빈 문자열·자료형·집계·윈도우 함수 차이를 체험하고, 빅분기 필기의
결측치·거리·표준화 계산과 실기의 Python kNN 대체 코드를 SQL로 연결해 검산하는
것을 목표로 한다.

## `10-KNN`과의 구분 (혼동 금지)

| | [`10-KNN`](../10-KNN/README.md) | 이 모듈(`22-KNN결측값대체`) |
|---|---|---|
| 무엇을 예측하는가 | 이탈 여부(`churned`, 범주형 라벨) | 결측된 연속형 값(`target_missing_value`) |
| 알고리즘 역할 | 지도학습 분류기 | 결측값 대체(전처리) 기법 |
| sklearn 클래스 | `KNeighborsClassifier` | `KNNImputer` (+ SQL/Python 직접 구현) |
| k 선택 방식 | k=3,5,7,9,11 그리드로 정확도 비교 | 논문 규칙 k=round(sqrt(도너 풀 크기)) 고정 |
| 입력 데이터 | `_data/bigdata_exam.db`의 `customer_features` 등 | 이 모듈 전용 합성 테이블 `impute_practice_raw` |

두 폴더 모두 "가장 가까운 이웃"이라는 같은 개념을 쓰지만 **용도가 다르다** —
`10-KNN`은 삭제하거나 이 모듈로 대체하지 않았다.

## 근거 논문 요약과 이 모듈의 구현 범위

논문은 잠재프로파일분석(LPA)에서 결측값을 처리하는 두 방법 — **kNN 대체법**과
**FIML(완전정보최대우도법)** — 을 시뮬레이션으로 비교한다. 조건은 결측 메커니즘
(MCAR/MAR), 결측 비율(10%/30%), 표본크기(200/500/1000), 잠재집단 간 분리
정도(subgroup-distance) 등으로 나뉘고, 평가 기준은 잠재집단 수 판정(BIC/BLRT),
분류 정확도(Entropy), 프로파일 값 복원 정확도(RMSE)다. kNN 대체는 유클리드
거리 `d_ij = sqrt(Σ(X_io - X_jo)^2)`(공통으로 관측된 변수만 사용)로 최근접
이웃을 찾고, k = round(sqrt(관측치 수))(Jonsson & Wohlin, 2004) 규칙으로 이웃
수를 정한 뒤 이웃의 평균/중앙값으로 대체하는 방식이다.

**논문의 결론은 "kNN이 FIML보다 항상 낫다"가 아니다** — 조건에 따라 결과가
달라졌고, 대부분의 조건에서 두 방법의 성능은 비슷한 수준이었다. 이 결론을
왜곡하지 않기 위해, 이 모듈은:

- **구현하는 것**: 논문이 제시한 kNN 대체 알고리즘 자체(거리 계산 → k=round(sqrt(n))
  이웃 선택 → 평균 대체) 를 SQL(Oracle/SQL Server)과 Python 양쪽에서 완전히
  구현하고, 정확도(RMSE)를 실제 정답값과 대조한다.
- **구현하지 않는 것**: LPA(잠재프로파일분석) 자체, FIML, BIC/BLRT에 의한
  잠재집단 수 판정, Entropy — 이런 모델 적합 절차를 SQL로 억지 구현하지
  않는다. 이 README에서 논문의 평가 기준으로만 언급하고, 실제 계산은 하지
  않는다.
- **1차 구현 범위**: 작은 합성 데이터셋(20행) 하나로 kNN 대체 파이프라인의
  정확성을 확인하는 것까지가 이번 구현의 끝이다. MCAR/MAR 10%/30%,
  표본크기 200/500/1000, k값 변화, 대규모 반복 시뮬레이션은 아래
  "1차 구현에서 보류한 확장"에 남겨두고 지금 실행하지 않는다.

## 데이터셋 설계 — `impute_practice_raw` (합성, 20행)

**Olist 원자료(`olist_customers_dataset.csv`)에는 실제 결측이 없다**
(`Olist-고객데이터/00-데이터사전/profile.py`로 이미 확인됨). 이 테이블은
Olist 데이터에서 만든 것이 아니라, kNN 대체와 Oracle/SQL Server NULL 문법
차이를 보여주기 위해 새로 만든 **별도의 작은 합성 데이터**다.

| 컬럼 | 의미 | 결측 관련 역할 |
|---|---|---|
| `recency` | 최근 구매 후 경과일 | C017에서만 NULL(다중 결측 시나리오) |
| `frequency` | 구매 횟수 | C009에서 0(정상값, 결측 아님) |
| `monetary` | 누적 구매액(천원) | C012에서 극단값(98000) |
| `delivery_days` | 평균 배송일 | C017에서만 NULL |
| `review_score` | 리뷰 평점(1~5) | 항상 관측됨 |
| `target_missing_value` | 대체 대상(다음달 예상 지출, 천원) | C016~C020에서 NULL(대체 대상) |
| `coupon_code_raw` | 문자열 테스트 컬럼 | NULL / `''` / `' '` 세 값을 각각 담음 |
| `true_value_for_check` | 검증 전용 정답값 | 대체 계산에는 절대 쓰지 않음 |
| `scenario_type` | 이 행의 데이터 품질 시나리오 라벨 | 아래 표 |

| 시나리오 | 행 | 설명 |
|---|---|---|
| `complete` | C001~C004, C007~C008, C010~C011, C013~C015 (11행) | 모든 값이 정상, 도너 풀의 대부분 |
| `empty_string` | C005 | `coupon_code_raw = ''` |
| `whitespace_string` | C006 | `coupon_code_raw = ' '`(공백 1글자) |
| `zero_value` | C009 | `frequency=0, monetary=0, target=0` — 정상적인 0(결측 아님) |
| `extreme_value` | C012 | `monetary=98000, target=95000` — 극단값, 도너 풀에 포함 |
| `single_null` | C016, C020 | `target_missing_value`만 NULL |
| `multi_null` | C017 | `recency`, `delivery_days`, `target_missing_value` 모두 NULL |
| `distance_tie` | C018 | 4번째 근접이웃 자리에서 동률(C008/C010/C014)이 나도록 설계 |
| `near_extreme` | C019 | 극단값 도너(C012)와 실제로 가까운 행 — "이웃이 사실상 1개뿐"인 경우 |

도너 풀(target 관측, 15행)과 대체 대상(target NULL, 5행: C016~C020)으로
나뉜다. `C010`과 `C014`는 recency/frequency/monetary/delivery_days/
review_score 값이 의도적으로 완전히 같다(target만 100/96으로 다름) — C018을
기준으로 근접이웃 순위 4~6등이 동률이 되도록 설계했다.

## 10단계 kNN 대체 SQL 파이프라인 (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`)

| 단계 | 내용 |
|---|---|
| 1 | NULL/빈 문자열/공백 식별 (`null_identification`) |
| 2 | NULL 처리 함수 비교 — Oracle: `NVL`/`NVL2`/`COALESCE`/`NULLIF`, SQL Server: `ISNULL`/`COALESCE`/`NULLIF` |
| 3~4 | 전체 평균/중앙값 대체 베이스라인 (`impute_baseline_stats`) — Oracle `MEDIAN()`, SQL Server `PERCENTILE_CONT` |
| 5 | 도너 풀(`donor_pool`) / 대체 대상 풀(`impute_target_pool`) 분리 |
| 6 | 쌍별(pairwise) 거리 계산(`pairwise_distance`, `pairwise_distance_final`) — 공통 관측 변수만 사용, 변수 개수로 정규화 |
| 7 | k = round(sqrt(도너 풀 크기)) 계산(`knn_k_value`) |
| 8 | `ROW_NUMBER()`/`RANK()` 윈도우 함수로 근접이웃 순위 매기기(`ranked_neighbors`) |
| 9 | k개 이웃 평균으로 대체값 계산 — 동률 처리 두 방식 비교(`knn_imputed_strict`, `knn_imputed_with_ties`) |
| 10 | 최종 결과 테이블(`impute_practice_result`) — 원본/평균대체/중앙값대체/kNN대체(2방식)/정답값 |

### 거리 계산의 결측 처리 (edge case)

- 도너 풀은 설계상 5개 변수 모두 결측이 없다. 대체 대상 쪽에서 NULL인 변수만
  그 쌍의 거리 계산에서 제외한다(C017의 `recency`, `delivery_days`).
- **변수 개수 정규화**: 논문 원식은 `d = sqrt(Σ(X_io-X_jo)^2)`(제곱합 그대로)
  이지만, 이 값은 비교에 쓰인 변수 개수가 쌍마다 다르면(C017은 3개, 나머지는
  5개) 개수가 적은 쪽이 인위적으로 더 "가까워" 보이는 문제가 생길 수 있다.
  그래서 이 구현은 `dist_normalized = sqrt(제곱합 / 사용된 변수 개수)`
  (평균제곱거리의 제곱근)를 실제 순위 기준으로 쓰고, 원식 그대로의 `dist_raw`도
  같이 남겨 두 값의 차이를 비교할 수 있게 했다.
- **동률(tie) 처리**: C018 기준 C008/C010/C014가 정규화 거리 기준으로 완전히
  동률이다(실행 결과 참고). `knn_imputed_strict`는 `ROW_NUMBER() OVER(ORDER BY
  거리, customer_id)`로 정확히 k=4명만 결정적으로 선택하고, `knn_imputed_with_ties`는
  `RANK()`로 동률을 모두 포함해(이 경우 6명) 평균을 낸다 — 두 값이 다르다는
  것 자체가 "동률을 어떻게 처리할지는 구현 선택"이라는 점을 보여준다.

## Oracle · SQL Server 비교 — 이 모듈에서 실제로 드러난 차이

| 항목 | Oracle | SQL Server | 결과가 실제로 달라지는가 |
|---|---|---|---|
| 빈 문자열과 NULL | `''`는 저장되는 순간 NULL이 된다 — `IS NULL`→TRUE | `''`와 NULL은 별개 값 — `IS NULL`→FALSE | **다르다**. C005(`''`)가 Oracle에서는 C003(NULL)과 구분 불가능해진다 |
| NULL 대체 함수 | `NVL(expr, 대체값)`, `NVL2(expr, not_null시, null시)` | `NVL`/`NVL2` 없음 — `ISNULL(expr, 대체값)`만 있고, 반환 타입이 첫 인수 기준으로 고정됨(COALESCE는 인수 타입을 넓혀 맞춤) | 함수 목록 자체가 다르다(단순 동의어 취급 금지) |
| `NULLIF(x, '')`의 의미 | `''`가 이미 NULL이라 `x = NULL`은 항상 UNKNOWN → 사실상 아무 의미가 없어짐 | `''`가 진짜 빈 문자열이라 원래 의도대로 "빈 문자열이면 NULL로" 동작함 | **다르다** — 같은 문법이 한쪽에서만 의미를 가짐 |
| 문자열 길이 | `LENGTH(' ')` = 1(공백 그대로 포함) | `LEN(' ')` = 0(뒤쪽 공백을 잘라내고 셈) / `DATALENGTH(' ')` = 1(실제 바이트) | **다르다** — SQL Server는 길이 함수를 잘못 고르면 공백 문자열을 빈 값으로 오인할 수 있음 |
| 중앙값 | `MEDIAN(expr)` 집계함수 내장 | `MEDIAN` 없음 — `PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY expr) OVER()`로 대체 | 문법은 다르지만 값은 같다 |
| 행 제한 | `FETCH FIRST n ROWS ONLY` | `SELECT TOP n` | 문법만 다르고 결과는 같다 |
| 테이블 생성 | `CREATE TABLE ... AS SELECT` | `SELECT ... INTO` | 문법만 다르고 결과는 같다 |
| 재실행을 위한 DROP | `DROP TABLE x;`(존재 안 하면 첫 실행 시 에러 — 이 저장소 다른 모듈과 동일 관례) | `IF OBJECT_ID('x','U') IS NOT NULL DROP TABLE x;` | 관례 차이(저장소 공통 패턴) |
| 문자열 연결 | `\|\|` | `+` (또는 `CONCAT()`) | 문법 차이, `\|\|`는 SQL Server에서 아예 문법 오류 |

## 실행 결과 (SQLite로 이 저장소에서 실제 실행·검증됨)

Oracle/SQL Server는 이 세션에서 실행할 수 없으므로(`../../README.md` §5
참고), 위 파이프라인과 완전히 같은 로직을 `optional/01_prepare_sqlite.sql` +
`optional/03_verify_sqlite.sql`로 **실제 실행**했다. 아래 수치는 그 실행
결과이며, Oracle/SQL Server 버전은 같은 로직을 문법만 옮긴 것이므로 값 자체는
같아야 한다(실제 Oracle/SQL Server 검증은 여전히 필요).

k = round(sqrt(15)) = **4**

| customer_id | 시나리오 | 정답값 | 전체평균 대체 | 전체중앙값 대체 | kNN 대체(strict, k=4) | kNN 대체(동률포함) |
|---|---|---|---|---|---|---|
| C016 | single_null | 132 | 6415.8 | 96 | **121.25** | 116.2 |
| C017 | multi_null | 56 | 6415.8 | 96 | **59.0** | 59.0 |
| C018 | distance_tie | 133 | 6415.8 | 96 | **136.25** | 123.5 |
| C019 | near_extreme | 94000 | 6415.8 | 96 | **23876.25** | 23876.25 |
| C020 | single_null | 17 | 6415.8 | 96 | **22.0** | 22.0 |

**RMSE 비교** (5행 전체): kNN(strict) 31360.29, kNN(동률포함) 31360.30, 전체평균
대체 39576.11, 전체중앙값 대체 41995.17 — kNN이 세 베이스라인보다 낫지만,
이 숫자는 C019 한 행의 압도적인 오차(-70123.75)에 크게 좌우된다.

**C019(near_extreme)를 제외한 RMSE**: kNN(strict) **6.33**, 전체평균 대체
**6331.5** — 이웃이 실제로 가까운 "일반적인" 조건에서는 kNN이 압도적으로
낫다.

**정직하게 짚어야 할 한계 (C019)**: C012(극단값, target=95000)가 유일하게
진짜 가까운 이웃인 C019에서는, 고정 k=4 때문에 실제로는 전혀 가깝지 않은
나머지 3개 이웃(거리 약 97300~97380, C012와의 거리 약 500에 비해 200배
가까이 멂)이 강제로 평균에 섞여 대체값이 23876.25로 정답(94000)에서 크게
벗어난다. **이것이 이 논문이 강조하는, "kNN이 조건에 따라 성능이 갈린다"는
결론과 정확히 같은 종류의 현상이다** — 이웃이 근본적으로 부족한 특이
관측치에서는 고정 k가 오히려 왜곡을 만들 수 있다. "kNN이 항상 더 낫다"고
일반화하지 않는다.

**문자열 컬럼 검증**(SQLite, NULL과 `''`를 구분하는 엔진): `null_count=1`
(C003), `empty_string_count=1`(C005), `whitespace_count=1`(C006) — 셋 다
서로 다른 행을 가리킨다. Oracle 버전에서는 `null_count`와
`empty_string_count`가 **같은 대상**(C003과 C005 모두 NULL)을 가리키게
된다는 점이 문법 파일의 핵심 주석으로 남아 있다(실제 Oracle 실행으로 재확인
필요).

Python(`02_analyze.py`, 실제 실행됨)에서 numpy로 SQL과 동일한 로직을 그대로
재구현한 결과는 SQL 결과와 **소수점 오차 없이 완전히 일치**했다
(`sql_vs_python_explicit_diff = 0`, 5행 모두). `sklearn.impute.KNNImputer`
(라이브러리 호출)도 이번 실행에서는 우연히 같은 값을 냈지만, 동률 처리
방식이 SQL의 `customer_id` 타이브레이크와 원리적으로 다르므로 항상 일치를
보장하지 않는다 — 그래서 "라이브러리 호출 결과가 맞았으니 SQL 검산은
생략해도 된다"고 일반화하지 않고, 매 실행마다 SQL 결과와 대조한다.

## 실행

```bash
# Oracle / SQL Server: 01_prepare_*.sql, 03_verify_*.sql을 각 환경에 복사해 실행
# (이 저장소에서 실행 불가 — 실제 검증 필요)
python3 02_analyze.py

# 보조(SQLite, 이 저장소에서 실제 실행·검증됨):
python3 ../_data/run_sql.py optional/01_prepare_sqlite.sql
python3 02_analyze.py
python3 ../_data/run_sql.py optional/03_verify_sqlite.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python/SQL) 대응 |
|---|---|
| 유클리드 거리 `d=sqrt(Σ(x_i-y_i)^2)` | SQL STEP 6 (`pairwise_distance`), `knn_impute_explicit()`의 numpy 구현 |
| k 결정(Jonsson & Wohlin, k=sqrt(n)) | SQL STEP 7 (`knn_k_value`), `round(np.sqrt(donor_pool_count))` |
| 결측값 평균/중앙값 대체 | SQL STEP 3~4, `sklearn.impute.SimpleImputer` |
| kNN 결측값 대체 | SQL STEP 6~10, `sklearn.impute.KNNImputer` + 명시적 numpy 구현 |
| NULL 함수(NVL/ISNULL/COALESCE/NULLIF) | `01_prepare_oracle.sql` / `01_prepare_sqlserver.sql` STEP 2 |
| R 대응 | `VIM::kNN()`, `DMwR2::knnImputation()` |

## 1차 구현에서 보류한 확장

사용자 지시에 따라 아래는 지금 실행하지 않는다(작은 규모의 단일 데이터셋
검증을 먼저 끝내는 것이 우선):

- MCAR/MAR 결측 메커니즘별 비교(이 모듈은 결측을 임의로 지정했을 뿐, MCAR/MAR을
  시뮬레이션하지 않았다)
- 결측 비율 10%/30% 비교
- 표본크기 200/500/1000 비교
- k값을 sqrt(n) 외에 다르게 바꿔가며 비교
- 전체 평균 대체와 kNN 대체를 대규모 반복(논문처럼 수백~수천 회 시뮬레이션)으로
  비교
- LPA/FIML/BIC/BLRT/Entropy를 실제로 계산하는 절차

## 관련 파일

- [`source_map.md`](./source_map.md) — 논문의 각 개념이 이 모듈의 어느 파일에 대응하는지
- [`../10-KNN/README.md`](../10-KNN/README.md) — kNN **분류**(혼동 금지)
- [`../../Concepts/DBMS 문법 차이(Oracle-SQLServer).md`](../../Concepts/DBMS%20문법%20차이(Oracle-SQLServer).md) — 저장소 공통 Oracle/SQL Server 비교 기준
