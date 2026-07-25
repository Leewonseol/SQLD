# 14. 예상 결과

미검증(12절 참고). `oracle.sql`/`sqlserver.sql` 마지막 종합 점검 쿼리의
예상 결과:

| table_name | row_count | null(관련컬럼) 개수 — Oracle | null(관련컬럼) 개수 — SQL Server |
|---|---|---|---|
| null_lab_customer | 12 | null_nickname_count=3 | null_nickname_count=2 |
| null_lab_dept | 3 | - | - |
| null_lab_excluded_codes | 3 | - | - |
| impute_practice_raw | 20 | target_missing_value NULL=5 | target_missing_value NULL=5 |

`quiz.sql`의 14문항 각각에 대한 정답 근거 수치는 해당 문제가 대응하는
`00`~`13` 폴더의 `expected_results.md`를 그대로 따른다(이 문서에서
중복 기재하지 않는다). 특히:

- Q13(RMSE 비교)은 `12-평균-중앙값대치`(`rmse_mean=39576.11`,
  `rmse_median=41995.17`)와 `13-kNN결측값대체`(`rmse_knn_strict=31360.29`)의
  수치를 그대로 사용한다.

## 12. 실제 실행 검증 여부

미검증. `impute_practice_raw` 관련 수치만 SQLite 실행으로 검증된 값을
인용했고(`분석기법/22-KNN결측값대체`), 나머지는 문법·규칙 기준 예상값이다.
