"""가설검정: hyp_input으로 (1) 주별 n_orders 일원배치 분산분석, (2) 주x재구매 카이제곱 검정."""

import os
import sqlite3

import pandas as pd
from scipy import stats

DB_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "01-기본탐색",
    "olist.db",
)


def main():
    conn = sqlite3.connect(DB_PATH)
    df = pd.read_sql("SELECT * FROM hyp_input", conn)

    groups = [g["n_orders"].to_numpy() for _, g in df.groupby("state_group")]
    f_stat, f_p = stats.f_oneway(*groups)

    table = pd.crosstab(df["state_group"], df["is_repeat_customer"])
    chi2_stat, chi2_p, dof, expected = stats.chi2_contingency(table, correction=False)

    results = pd.DataFrame(
        {
            "test": ["anova_n_orders_by_state", "chi_square_state_x_repeat"],
            "statistic": [f_stat, chi2_stat],
            "p_value": [f_p, chi2_p],
            "reject_h0_at_0.05": [f_p < 0.05, chi2_p < 0.05],
        }
    )

    results.to_sql("hyp_test_results", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(results.round(6).to_string(index=False))


if __name__ == "__main__":
    main()
