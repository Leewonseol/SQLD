# 근거 논문 개념 ↔ 이 모듈 파일 대응표

근거: `잠재프로파일 결측값에 대한 논문.pdf`(저장소 루트) —
"잠재프로파일 분석에서 결측값 처리를 위한 최근접이웃 대체법의 활용"

| 논문 개념 | 이 모듈에서의 대응 | 실제 구현했는가 |
|---|---|---|
| kNN 결측값 대체 | `01_prepare_oracle.sql` / `01_prepare_sqlserver.sql` / `optional/01_prepare_sqlite.sql` STEP 6~10, `02_analyze.py`의 `knn_impute_explicit()` | 구현·실행(SQLite)·검증됨 |
| 유클리드 거리 `d_ij = sqrt(Σ(X_io-X_jo)^2)` | STEP 6 `pairwise_distance`(`dist_raw`), 정규화판 `dist_normalized` | 구현·실행·검증됨 |
| 공통으로 관측된 변수만 사용(pairwise 결측 제외) | STEP 6의 `CASE WHEN t.recency IS NOT NULL ...` 등, C017(multi_null)에서 실증 | 구현·실행·검증됨 |
| k = round(sqrt(관측치 수)) (Jonsson & Wohlin, 2004) | STEP 7 `knn_k_value` — 이 데이터셋에서 k=round(sqrt(15))=4 | 구현·실행·검증됨 |
| 이웃 평균/중앙값 대체 | STEP 9 `knn_imputed_strict`/`knn_imputed_with_ties`(평균만 구현, 중앙값 대체는 STEP 3~4의 전체 중앙값 베이스라인으로만 별도 구현) | 평균 대체 구현·실행·검증됨 |
| FIML(완전정보최대우도법) | README "근거 논문 요약" 절에서만 서술 | **구현하지 않음**(SQL로 억지 구현 금지 지시에 따름) |
| 잠재프로파일분석(LPA) 자체 | README 서술만 | **구현하지 않음** |
| BIC/BLRT(잠재집단 수 판정) | README 서술만 | **구현하지 않음** |
| Entropy(분류 정확도) | README 서술만 | **구현하지 않음** |
| RMSE(프로파일 값 복원 정확도) | `03_verify_oracle.sql` / `03_verify_sqlserver.sql` / `optional/03_verify_sqlite.sql`의 4)/4-1) 쿼리 — `true_value_for_check`와 대조 | 구현·실행·검증됨(단, 논문의 시뮬레이션 RMSE가 아니라 이 모듈 자체 합성 데이터의 RMSE) |
| MCAR/MAR, 결측비율 10%/30%, 표본크기 200/500/1000 | README "1차 구현에서 보류한 확장" | **구현하지 않음**(1차 구현 범위 밖으로 명시적으로 보류) |
| 조건별로 kNN과 FIML의 성능이 갈린다는 결론 | README "정직하게 짚어야 할 한계 (C019)" 절에서, 이 모듈 자체 데이터로 유사한 현상(고정 k의 한계)을 재현 | 논문 결론을 그대로 인용하지 않고, 이 모듈 데이터에서 같은 종류의 현상을 직접 확인 |

## 파일 목록

| 파일 | 역할 | 실행 상태 |
|---|---|---|
| `README.md` | 논문 요약, 데이터셋 설계, Oracle/SQL Server 비교, 실행 결과 | - |
| `01_prepare_oracle.sql` | 합성 데이터 적재 + NULL 식별 + 평균/중앙값 베이스라인 + 10단계 kNN 대체 (Oracle) | 미실행(문법 기준 작성, 실제 Oracle 검증 필요) |
| `01_prepare_sqlserver.sql` | 위와 동일 (SQL Server) | 미실행(문법 기준 작성, 실제 SQL Server 검증 필요) |
| `03_verify_oracle.sql` | 11가지 검증 쿼리 (Oracle) | 미실행(문법 기준 작성, 실제 Oracle 검증 필요) |
| `03_verify_sqlserver.sql` | 위와 동일 (SQL Server) | 미실행(문법 기준 작성, 실제 SQL Server 검증 필요) |
| `02_analyze.py` | SimpleImputer/KNNImputer + 명시적 numpy kNN 구현 + SQL 결과와 대조 | **실행·검증됨**(SQLite DB 대상) |
| `optional/01_prepare_sqlite.sql` | Oracle/SQL Server 버전과 동일 로직의 SQLite 버전 | **실행·검증됨** |
| `optional/03_verify_sqlite.sql` | 위와 동일 검증 쿼리의 SQLite 버전 | **실행·검증됨** |
| `source_map.md` | 이 파일 | - |
