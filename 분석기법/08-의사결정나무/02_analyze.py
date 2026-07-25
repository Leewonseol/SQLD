"""의사결정나무: tree_input에 DecisionTreeClassifier를 학습하고 변수중요도·예측값을 저장한다."""

import os
import sys

import pandas as pd
from sklearn.tree import DecisionTreeClassifier, export_text

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

FEATURES = [
    "satisfaction_score",
    "days_since_last_order",
    "order_count",
    "membership_years",
    "annual_income_10k",
    "avg_order_value",
]


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM tree_input", conn)
    train = df[df["split"] == "train"]
    test = df[df["split"] == "test"]

    model = DecisionTreeClassifier(
        criterion="gini", max_depth=4, min_samples_leaf=20, random_state=42
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
            "max_depth": [model.get_depth()],
            "n_leaves": [model.get_n_leaves()],
            "accuracy": [(pred == test["churned"].values).mean()],
        }
    )

    importances.to_sql("tree_feature_importance", conn, if_exists="replace", index=False)
    predictions.to_sql("tree_predictions", conn, if_exists="replace", index=False)
    metrics.to_sql("tree_metrics", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(importances.round(4).to_string(index=False))
    print()
    print(metrics.to_string(index=False))
    print()
    print(export_text(model, feature_names=FEATURES, max_depth=2))


if __name__ == "__main__":
    main()
