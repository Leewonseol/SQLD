"""AR/MA/ARMA/ARIMA: monthly_sales에 네 가지 order로 ARIMA를 적합해 AIC로 비교하고,
최종 선택 모형(ARIMA(1,1,1))으로 6개월을 예측한다.
"""

import os
import sys
import warnings

import numpy as np
import pandas as pd
from statsmodels.tsa.arima.model import ARIMA

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

warnings.filterwarnings("ignore")

ORDERS = {
    "AR(1)": (1, 0, 0),
    "MA(1)": (0, 0, 1),
    "ARMA(1,1)": (1, 0, 1),
    "ARIMA(1,1,1)": (1, 1, 1),
}
FORECAST_STEPS = 6
FINAL_MODEL = "ARIMA(1,1,1)"


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM arima_features ORDER BY month_id", conn)
    y = df["sales"]

    comparison_rows = []
    fitted_models = {}
    for name, order in ORDERS.items():
        model = ARIMA(y, order=order).fit()
        fitted_models[name] = model
        d = order[1]
        resid = model.resid[d:]  # 차분 차수(d)만큼의 초기 잔차는 초기화 인공물이므로 제외
        rmse = float(np.sqrt((resid**2).mean()))
        comparison_rows.append({"model": name, "model_order": str(order), "aic": model.aic, "in_sample_rmse": rmse})

    comparison = pd.DataFrame(comparison_rows).sort_values("aic")

    final_model = fitted_models[FINAL_MODEL]
    last_month = int(df["month_id"].max())
    fc = final_model.get_forecast(steps=FORECAST_STEPS)
    ci = fc.conf_int(alpha=0.05)
    forecast = pd.DataFrame(
        {
            "month_id": np.arange(last_month + 1, last_month + 1 + FORECAST_STEPS),
            "forecast": fc.predicted_mean.values,
            "ci_lower": ci.iloc[:, 0].values,
            "ci_upper": ci.iloc[:, 1].values,
        }
    )

    final_d = ORDERS[FINAL_MODEL][1]
    residuals = pd.DataFrame(
        {
            "month_id": df["month_id"].iloc[final_d:],
            "residual": final_model.resid.values[final_d:],
        }
    )

    comparison.to_sql("arima_model_comparison", conn, if_exists="replace", index=False)
    forecast.to_sql("arima_forecast", conn, if_exists="replace", index=False)
    residuals.to_sql("arima_residuals", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(comparison.round(3).to_string(index=False))
    print()
    print(forecast.round(1).to_string(index=False))


if __name__ == "__main__":
    main()
