"""로지스틱회귀: logit_input(state 더미)으로 is_repeat_customer를 예측한다."""

import os
import sqlite3

import numpy as np
import pandas as pd
import statsmodels.api as sm

DB_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "01-기본탐색",
    "olist.db",
)
PREDICTORS = ["state_SP", "state_RJ", "state_MG", "state_RS", "state_PR", "state_SC"]


def main():
    conn = sqlite3.connect(DB_PATH)
    df = pd.read_sql("SELECT * FROM logit_input", conn)

    X = sm.add_constant(df[PREDICTORS])
    y = df["is_repeat_customer"]
    model = sm.Logit(y, X).fit(disp=0)

    coef = pd.DataFrame(
        {
            "variable": model.params.index,
            "coef": model.params.values,
            "odds_ratio": np.exp(model.params.values),
            "p_value": model.pvalues.values,
        }
    )

    coef.to_sql("logit_coefficients", conn, if_exists="replace", index=False)
    metrics = pd.DataFrame({"pseudo_r_squared": [model.prsquared], "n": [len(df)]})
    metrics.to_sql("logit_metrics", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(coef.round(4).to_string(index=False))
    print(f"\nMcFadden pseudo R^2 = {model.prsquared:.5f} (매우 낮음 - 예상된 결과, README 참고)")


if __name__ == "__main__":
    main()
