---
type: technique
pilot: true
category: 차원축소
---

# 주성분분석 (PCA)

## 필기 공식

- 공분산행렬 분해: `Σv = λv` (λ: 고유값, v: 고유벡터)
- 설명분산비율(기여율): `λᵢ / Σλⱼ`
- 누적기여율: 앞 k개 성분의 기여율 누적 합 (보통 70~80% 이상을 기준으로 성분 개수 결정)
- Kaiser 기준: 고유값 `λ > 1`인 성분만 채택
- 성분점수(Score): `Z · V` (Z: 표준화된 데이터, V: 고유벡터 행렬)
- **표준화가 선행되어야 하는 이유**: 변수 간 단위·척도가 다르면 분산이 큰 변수가
  주성분을 지배하므로, PCA 전 반드시 평균 0·표준편차 1로 표준화한다.

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | `customer_features`의 7개 수치형 변수를 표준화하여 `pca_input` 테이블 생성 |
| Python (`02_analyze.py`) | `sklearn.decomposition.PCA`로 고유값·고유벡터(적재량)·성분점수 산출, 결과를 `pca_variance`/`pca_loadings`/`pca_scores` 테이블로 저장 |
| SQL (`03_verify.sql`) | 누적기여율 확인, 성분점수 상하위 고객 조회, 원본 행 수와 결과 행 수 일치 검산 |

## DBMS별 SQL 차이

표준편차를 구할 때 DBMS마다 내장 함수가 다르다.

| DBMS | 표준편차 함수 | 비고 |
|---|---|---|
| Oracle | `STDDEV(x)`, `STDDEV_POP(x)` | 창(window) 함수로도 사용 가능: `STDDEV(x) OVER()` |
| SQL Server | `STDEV(x)`, `STDEVP(x)` | `STDEV`는 표본표준편차, `STDEVP`는 모표준편차 |
| SQLite | 내장 함수 없음 | `SQRT(AVG(x*x) - AVG(x)*AVG(x))` 로 모표준편차를 직접 계산해야 함 |

이 실습은 SQLite 기준이므로 `01_prepare.sql`에서 분산 공식 `Var(x) = E[x²] - E[x]²`을
직접 풀어 쓴다. Oracle/SQL Server에서는 `STDDEV`/`STDEV`로 한 줄에 대체할 수 있다.

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 고유값 λ | `pca.explained_variance_` |
| 설명분산비율 | `pca.explained_variance_ratio_` |
| 고유벡터(적재량) | `pca.components_` |
| 성분점수 | `pca.transform(Z)` |
| R 대응 | `prcomp(x, scale.=TRUE)$sdev^2`, `$rotation`, `$x` |
