"""SVM: svm_input(표준화 특성 + train/test 분할)에 RBF 커널 SVC를 학습한다."""

import os
import sys

import pandas as pd
from sklearn.svm import SVC

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

FEATURES = ["satisfaction_z", "recency_z", "orders_z", "membership_z", "income_z"]


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM svm_input", conn)
    train = df[df["split"] == "train"]
    test = df[df["split"] == "test"]

    model = SVC(kernel="rbf", C=1.0, gamma="scale", random_state=42)
    model.fit(train[FEATURES], train["churned"])

    pred = model.predict(test[FEATURES])
    # decision_function: 초평면까지의 부호 있는 거리. 양수면 churned=1 쪽으로 분류.
    decision_score = model.decision_function(test[FEATURES])

    predictions = pd.DataFrame(
        {
            "customer_id": test["customer_id"].values,
            "actual": test["churned"].values,
            "predicted": pred,
            "decision_score": decision_score,
        }
    )

    metrics = pd.DataFrame(
        {
            "n_support_vectors": [int(model.support_vectors_.shape[0])],
            "n_support_class0": [int(model.n_support_[0])],
            "n_support_class1": [int(model.n_support_[1])],
            "n_train": [len(train)],
            "n_test": [len(test)],
            "accuracy": [(pred == test["churned"].values).mean()],
        }
    )

    predictions.to_sql("svm_predictions", conn, if_exists="replace", index=False)
    metrics.to_sql("svm_metrics", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(metrics.to_string(index=False))


if __name__ == "__main__":
    main()
