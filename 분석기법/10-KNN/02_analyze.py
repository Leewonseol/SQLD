"""KNN: knn_input에 여러 k값으로 KNeighborsClassifier를 학습·평가한다."""

import os
import sys

import pandas as pd
from sklearn.metrics import accuracy_score
from sklearn.neighbors import KNeighborsClassifier

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

FEATURES = ["satisfaction_z", "recency_z", "orders_z", "membership_z", "income_z"]
K_CANDIDATES = [3, 5, 7, 9, 11]


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM knn_input", conn)
    train = df[df["split"] == "train"]
    test = df[df["split"] == "test"]

    rows = []
    best_pred = None
    best_acc = -1
    best_k = None
    for k in K_CANDIDATES:
        model = KNeighborsClassifier(n_neighbors=k, metric="euclidean")
        model.fit(train[FEATURES], train["churned"])
        pred = model.predict(test[FEATURES])
        acc = accuracy_score(test["churned"], pred)
        rows.append({"k": k, "accuracy": acc})
        if acc > best_acc:
            best_acc, best_k, best_pred = acc, k, pred

    comparison = pd.DataFrame(rows)
    predictions = pd.DataFrame(
        {
            "customer_id": test["customer_id"].values,
            "actual": test["churned"].values,
            "predicted": best_pred,
            "best_k": best_k,
        }
    )

    comparison.to_sql("knn_k_comparison", conn, if_exists="replace", index=False)
    predictions.to_sql("knn_predictions", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(comparison.to_string(index=False))
    print(f"\nbest k = {best_k} (accuracy={best_acc:.4f})")


if __name__ == "__main__":
    main()
