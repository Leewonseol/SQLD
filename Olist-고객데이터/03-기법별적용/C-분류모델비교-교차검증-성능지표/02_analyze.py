"""분류모델 비교: clf_input의 customer_fold(5-fold)를 그대로 사용해
RandomForest·SVM·KNN을 각각 학습·평가한다.
"""

import os
import sqlite3

import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score, roc_auc_score
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import LinearSVC

DB_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "01-기본탐색",
    "olist.db",
)
FEATURES = ["state_SP", "state_RJ", "state_MG", "state_RS", "state_PR", "state_SC"]

MODELS = {
    "RandomForest": lambda: RandomForestClassifier(
        n_estimators=200, min_samples_leaf=20, class_weight="balanced", random_state=42
    ),
    # 입력이 6개 이진 더미변수뿐이라 RBF 커널의 비선형 변환이 의미가 없고(경계가 이미 선형),
    # libsvm 기반 SVC(kernel="rbf")는 학습건수 7만+에서 사실상 끝나지 않는다.
    # LinearSVC(liblinear)로 선형 결정경계를 학습한다 - 이 입력에서는 RBF와 결과가 사실상 같다.
    "SVM(Linear)": lambda: LinearSVC(class_weight="balanced", random_state=42, max_iter=5000),
    "KNN": lambda: KNeighborsClassifier(n_neighbors=15),
}


def main():
    conn = sqlite3.connect(DB_PATH)
    df = pd.read_sql("SELECT * FROM clf_input", conn)

    fold_rows = []
    pred_rows = []
    for model_name, build_model in MODELS.items():
        for fold in sorted(df["fold"].unique()):
            train = df[df["fold"] != fold]
            test = df[df["fold"] == fold]

            model = build_model()
            model.fit(train[FEATURES], train["is_repeat_customer"])
            pred = model.predict(test[FEATURES])
            # roc_auc_score는 확률(predict_proba)뿐 아니라 순위만 맞으면 되는 점수(decision_function)도
            # 받아들인다. SVM은 확률 보정을 켜지 않고 decision_function으로 대체한다.
            if hasattr(model, "predict_proba"):
                score = model.predict_proba(test[FEATURES])[:, 1]
            else:
                score = model.decision_function(test[FEATURES])
            try:
                auc = roc_auc_score(test["is_repeat_customer"], score)
            except ValueError:
                auc = float("nan")

            fold_rows.append(
                {
                    "model": model_name,
                    "fold": fold,
                    "n_test": len(test),
                    "accuracy": accuracy_score(test["is_repeat_customer"], pred),
                    "precision": precision_score(test["is_repeat_customer"], pred, zero_division=0),
                    "recall": recall_score(test["is_repeat_customer"], pred, zero_division=0),
                    "f1": f1_score(test["is_repeat_customer"], pred, zero_division=0),
                    "roc_auc": auc,
                }
            )
            if fold == 1:
                pred_rows.append(
                    pd.DataFrame(
                        {
                            "model": model_name,
                            "customer_unique_id": test["customer_unique_id"].values,
                            "actual": test["is_repeat_customer"].values,
                            "predicted": pred,
                        }
                    )
                )

    fold_results = pd.DataFrame(fold_rows)
    summary = (
        fold_results.groupby("model")[["accuracy", "precision", "recall", "f1", "roc_auc"]]
        .mean()
        .reset_index()
    )
    predictions_fold1 = pd.concat(pred_rows, ignore_index=True)

    fold_results.to_sql("clf_fold_results", conn, if_exists="replace", index=False)
    summary.to_sql("clf_summary", conn, if_exists="replace", index=False)
    predictions_fold1.to_sql("clf_predictions_fold1", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(summary.round(4).to_string(index=False))


if __name__ == "__main__":
    main()
