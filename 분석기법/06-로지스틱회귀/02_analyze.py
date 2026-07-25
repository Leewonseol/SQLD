"""로지스틱회귀: logistic_input에 Logit을 적합하고 계수·오즈비·예측확률을 저장한다."""

import os
import sys

import numpy as np
import pandas as pd
import statsmodels.api as sm

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

PREDICTORS = ["days_since_last_order", "satisfaction_score", "order_count", "membership_years"]
TARGET = "churned"


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM logistic_input", conn)

    X = sm.add_constant(df[PREDICTORS])
    y = df[TARGET]
    model = sm.Logit(y, X).fit(disp=0)

    coef = pd.DataFrame(
        {
            "variable": model.params.index,
            "coef": model.params.values,
            "odds_ratio": np.exp(model.params.values),
            "std_err": model.bse.values,
            "z_value": model.tvalues.values,
            "p_value": model.pvalues.values,
        }
    )

    prob = model.predict(X)
    predictions = pd.DataFrame(
        {
            "customer_id": df["customer_id"],
            "actual": y,
            "predicted_prob": prob,
            "predicted_class": (prob >= 0.5).astype(int),
        }
    )

    metrics = pd.DataFrame(
        {
            "pseudo_r_squared": [model.prsquared],
            "log_likelihood": [model.llf],
            "n": [len(df)],
        }
    )

    coef.to_sql("logistic_coefficients", conn, if_exists="replace", index=False)
    predictions.to_sql("logistic_predictions", conn, if_exists="replace", index=False)
    metrics.to_sql("logistic_metrics", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(coef.round(4).to_string(index=False))


if __name__ == "__main__":
    main()
