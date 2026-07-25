"""랜덤포레스트: rf_input에 RandomForestClassifier(OOB 포함)를 학습한다."""

import os
import sys

import pandas as pd
from sklearn.ensemble import RandomForestClassifier

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

FEATURES = [
    "satisfaction_score",
    "days_since_last_order",
    "order_count",
    "membership_years",
    "annual_income_10k",
    "avg_order_value",
    "age",
]


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM rf_input", conn)
    train = df[df["split"] == "train"]
    test = df[df["split"] == "test"]

    model = RandomForestClassifier(
        n_estimators=300,
        max_features="sqrt",
        oob_score=True,
        bootstrap=True,
        random_state=42,
        min_samples_leaf=5,
    )
    model.fit(train[FEATURES], train["churned"])
    pred = model.predict(test[FEATURES])

    importances = pd.DataFrame(
        {"feature": FEATURES, "importance": model.feature_importances_}
    ).sort_values("importance", ascending=False)

    predictions = pd.DataFrame(
        {
            "customer_id": test["customer_id"].values,
            "actual": test["churned"].values,
            "predicted": pred,
        }
    )

    metrics = pd.DataFrame(
        {
            "n_estimators": [model.n_estimators],
            "oob_score": [model.oob_score_],
            "test_accuracy": [(pred == test["churned"].values).mean()],
        }
    )

    importances.to_sql("rf_feature_importance", conn, if_exists="replace", index=False)
    predictions.to_sql("rf_predictions", conn, if_exists="replace", index=False)
    metrics.to_sql("rf_metrics", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(importances.round(4).to_string(index=False))
    print()
    print(metrics.to_string(index=False))


if __name__ == "__main__":
    main()
