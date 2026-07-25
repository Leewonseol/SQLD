"""교차검증: cv_folds가 정한 5개 fold를 그대로 사용해 DecisionTreeClassifier를 5번 학습·평가한다."""

import os
import sys

import pandas as pd
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score
from sklearn.tree import DecisionTreeClassifier

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

FEATURES = ["satisfaction_score", "days_since_last_order", "order_count", "membership_years", "annual_income_10k"]


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM cv_folds", conn)

    rows = []
    for fold in sorted(df["fold"].unique()):
        train = df[df["fold"] != fold]
        test = df[df["fold"] == fold]

        model = DecisionTreeClassifier(max_depth=4, min_samples_leaf=20, random_state=42)
        model.fit(train[FEATURES], train["churned"])
        pred = model.predict(test[FEATURES])

        rows.append(
            {
                "fold": fold,
                "n_test": len(test),
                "accuracy": accuracy_score(test["churned"], pred),
                "precision": precision_score(test["churned"], pred, zero_division=0),
                "recall": recall_score(test["churned"], pred, zero_division=0),
                "f1": f1_score(test["churned"], pred, zero_division=0),
            }
        )

    fold_results = pd.DataFrame(rows)
    summary = pd.DataFrame(
        {
            "metric": ["accuracy", "precision", "recall", "f1"],
            "mean": [fold_results[m].mean() for m in ["accuracy", "precision", "recall", "f1"]],
            "std": [fold_results[m].std() for m in ["accuracy", "precision", "recall", "f1"]],
        }
    )

    fold_results.to_sql("cv_fold_results", conn, if_exists="replace", index=False)
    summary.to_sql("cv_summary", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(fold_results.round(4).to_string(index=False))
    print()
    print(summary.round(4).to_string(index=False))


if __name__ == "__main__":
    main()
