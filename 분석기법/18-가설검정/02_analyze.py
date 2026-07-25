"""가설검정: 대응표본 t검정, 일원배치 분산분석, 카이제곱 독립성 검정을 scipy로 수행한다."""

import os
import sys

import pandas as pd
from scipy import stats

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402


def main():
    conn = get_conn()

    # 1) 대응표본 t검정
    paired = pd.read_sql("SELECT * FROM paired_scores", conn)
    t_stat, t_p = stats.ttest_rel(paired["after_score"], paired["before_score"])

    # 2) 일원배치 분산분석
    branch = pd.read_sql("SELECT * FROM branch_scores", conn)
    groups = [g["score"].to_numpy() for _, g in branch.groupby("branch")]
    f_stat, f_p = stats.f_oneway(*groups)

    # 3) 카이제곱 독립성 검정
    ab = pd.read_sql("SELECT * FROM ab_test", conn)
    table = pd.crosstab(ab["variant"], ab["converted"])
    # correction=False: 필기 공식 그대로의 카이제곱 통계량(Σ(O-E)²/E)과 비교하기 위해
    # 2x2 표에서 기본 적용되는 Yates 연속성 수정을 끈다.
    chi2_stat, chi2_p, dof, expected = stats.chi2_contingency(table, correction=False)

    results = pd.DataFrame(
        {
            "test": ["paired_t_test", "one_way_anova", "chi_square_independence"],
            "statistic": [t_stat, f_stat, chi2_stat],
            "p_value": [t_p, f_p, chi2_p],
            "reject_h0_at_0.05": [t_p < 0.05, f_p < 0.05, chi2_p < 0.05],
        }
    )

    results.to_sql("hypothesis_test_results", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(results.round(5).to_string(index=False))


if __name__ == "__main__":
    main()
