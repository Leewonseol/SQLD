"""지수평활: monthly_sales에 SES와 Holt(추세)를 적합하고 6개월을 예측한다.
SQL이 계산한 3개월 이동평균을 pandas.rolling()으로도 재계산해 서로 일치하는지 검산한다.
"""

import os
import sys

import numpy as np
import pandas as pd
from statsmodels.tsa.holtwinters import Holt, SimpleExpSmoothing

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

FORECAST_STEPS = 6


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM ts_features ORDER BY month_id", conn)
    y = df["sales"]

    # SQL의 이동평균과 pandas rolling 이동평균이 일치하는지 검산
    ma3_pandas = y.rolling(3).mean()
    mismatch = (df["ma3"].dropna() - ma3_pandas.dropna()).abs().max()
    assert mismatch < 1e-6, f"SQL MA3와 pandas rolling(3) 불일치: max diff={mismatch}"
    print(f"SQL 이동평균 vs pandas rolling(3) 최대 오차: {mismatch:.2e} (일치 확인)")

    ses = SimpleExpSmoothing(y, initialization_method="estimated").fit(smoothing_level=0.3)
    holt = Holt(y, initialization_method="estimated").fit()

    fitted = pd.DataFrame(
        {
            "month_id": df["month_id"],
            "sales": y,
            "ses_fitted": ses.fittedvalues,
            "holt_fitted": holt.fittedvalues,
        }
    )

    last_month = int(df["month_id"].max())
    ses_fc = ses.forecast(FORECAST_STEPS)
    holt_fc = holt.forecast(FORECAST_STEPS)
    forecast = pd.DataFrame(
        {
            "month_id": np.arange(last_month + 1, last_month + 1 + FORECAST_STEPS),
            "ses_forecast": ses_fc.values,
            "holt_forecast": holt_fc.values,
        }
    )

    fitted.to_sql("ts_exp_smoothing_fitted", conn, if_exists="replace", index=False)
    forecast.to_sql("ts_forecast", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(forecast.round(1).to_string(index=False))


if __name__ == "__main__":
    main()
