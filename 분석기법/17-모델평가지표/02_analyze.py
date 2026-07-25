"""모델평가지표: logistic_predictions(분류)와 regression_predictions(회귀)로
정밀도/재현율/F1/ROC-AUC, RMSE/MAE/MAPE/R²를 계산한다.
"""

import os
import sys

import numpy as np
import pandas as pd
from sklearn.metrics import (
    accuracy_score,
    f1_score,
    mean_absolute_error,
    mean_absolute_percentage_error,
    mean_squared_error,
    precision_score,
    r2_score,
    recall_score,
    roc_auc_score,
    roc_curve,
)

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402


def main():
    conn = get_conn()

    # ---- 분류 지표 ----
    clf = pd.read_sql("SELECT * FROM logistic_predictions", conn)
    y_true, y_pred, y_prob = clf["actual"], clf["predicted_class"], clf["predicted_prob"]

    fpr, tpr, roc_thresholds = roc_curve(y_true, y_prob)
    roc_points = pd.DataFrame({"fpr": fpr, "tpr": tpr, "threshold": roc_thresholds})

    classification_metrics = pd.DataFrame(
        {
            "metric": ["accuracy", "precision", "recall", "f1", "roc_auc"],
            "value": [
                accuracy_score(y_true, y_pred),
                precision_score(y_true, y_pred, zero_division=0),
                recall_score(y_true, y_pred, zero_division=0),
                f1_score(y_true, y_pred, zero_division=0),
                roc_auc_score(y_true, y_prob),
            ],
        }
    )

    # ---- 회귀 지표 ----
    reg = pd.read_sql("SELECT * FROM regression_predictions", conn)
    rmse = np.sqrt(mean_squared_error(reg["actual"], reg["predicted"]))
    regression_metrics = pd.DataFrame(
        {
            "metric": ["rmse", "mae", "mape", "r2"],
            "value": [
                rmse,
                mean_absolute_error(reg["actual"], reg["predicted"]),
                mean_absolute_percentage_error(reg["actual"], reg["predicted"]),
                r2_score(reg["actual"], reg["predicted"]),
            ],
        }
    )

    classification_metrics.to_sql("classification_metrics_detail", conn, if_exists="replace", index=False)
    roc_points.to_sql("roc_curve_points", conn, if_exists="replace", index=False)
    regression_metrics.to_sql("regression_metrics_detail", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print("분류 지표"); print(classification_metrics.round(4).to_string(index=False))
    print("\n회귀 지표"); print(regression_metrics.round(4).to_string(index=False))


if __name__ == "__main__":
    main()
