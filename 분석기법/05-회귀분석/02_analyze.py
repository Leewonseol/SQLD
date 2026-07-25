"""다중회귀: regression_input에 OLS를 적합하고 계수·검정통계량·예측값을 저장한다."""

import os
import sys

import numpy as np
import pandas as pd
import statsmodels.api as sm

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

PREDICTORS = [
    "avg_order_value",
    "order_count",
    "membership_years",
    "annual_income_10k",
    "age",
    "satisfaction_score",
    "days_since_last_order",
    "tier_general",
    "tier_premium",
]
TARGET = "next_month_spend"


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM regression_input", conn)

    X = sm.add_constant(df[PREDICTORS])
    y = df[TARGET]
    model = sm.OLS(y, X).fit()

    coef = pd.DataFrame(
        {
            "variable": model.params.index,
            "coef": model.params.values,
            "std_err": model.bse.values,
            "t_value": model.tvalues.values,
            "p_value": model.pvalues.values,
        }
    )

    pred = model.predict(X)
    predictions = pd.DataFrame(
        {
            "customer_id": df["customer_id"],
            "actual": y,
            "predicted": pred,
            "residual": y - pred,
        }
    )

    metrics = pd.DataFrame(
        {
            "r_squared": [model.rsquared],
            "adj_r_squared": [model.rsquared_adj],
            "rmse": [np.sqrt((predictions["residual"] ** 2).mean())],
            "mae": [predictions["residual"].abs().mean()],
            "n": [len(df)],
        }
    )

    coef.to_sql("regression_coefficients", conn, if_exists="replace", index=False)
    predictions.to_sql("regression_predictions", conn, if_exists="replace", index=False)
    metrics.to_sql("regression_metrics", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(coef.round(4).to_string(index=False))
    print()
    print(metrics.round(4).to_string(index=False))


if __name__ == "__main__":
    main()
