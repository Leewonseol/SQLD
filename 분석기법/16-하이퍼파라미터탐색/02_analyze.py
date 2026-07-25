"""하이퍼파라미터 탐색: hp_grid의 각 조합을 hp_folds의 5-fold 교차검증으로 평가한다(수동 그리드서치)."""

import os
import sys

import numpy as np
import pandas as pd
from sklearn.metrics import accuracy_score
from sklearn.tree import DecisionTreeClassifier

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

FEATURES = ["satisfaction_score", "days_since_last_order", "order_count", "membership_years", "annual_income_10k"]


def main():
    conn = get_conn()
    grid = pd.read_sql("SELECT * FROM hp_grid", conn)
    df = pd.read_sql("SELECT * FROM hp_folds", conn)

    results = []
    for _, combo in grid.iterrows():
        fold_scores = []
        for fold in sorted(df["fold"].unique()):
            train = df[df["fold"] != fold]
            test = df[df["fold"] == fold]
            model = DecisionTreeClassifier(
                max_depth=int(combo["max_depth"]),
                min_samples_leaf=int(combo["min_samples_leaf"]),
                random_state=42,
            )
            model.fit(train[FEATURES], train["churned"])
            pred = model.predict(test[FEATURES])
            fold_scores.append(accuracy_score(test["churned"], pred))
        results.append(
            {
                "combo_id": int(combo["combo_id"]),
                "max_depth": int(combo["max_depth"]),
                "min_samples_leaf": int(combo["min_samples_leaf"]),
                "mean_accuracy": float(np.mean(fold_scores)),
                "std_accuracy": float(np.std(fold_scores, ddof=1)),
            }
        )

    results_df = pd.DataFrame(results).sort_values("mean_accuracy", ascending=False)
    results_df.to_sql("hp_search_results", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(results_df.round(4).to_string(index=False))
    best = results_df.iloc[0]
    print(f"\n최적 조합: max_depth={int(best.max_depth)}, min_samples_leaf={int(best.min_samples_leaf)}, "
          f"mean_accuracy={best.mean_accuracy:.4f}")


if __name__ == "__main__":
    main()
