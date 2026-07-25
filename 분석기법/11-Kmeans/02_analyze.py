"""K-means: kmeans_input을 표준화된 특성으로 k=2..8 엘보우 곡선을 그리고, k=4로 최종 학습한다."""

import os
import sys

import pandas as pd
from sklearn.cluster import KMeans

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

FEATURES = ["age_z", "income_z", "membership_z", "orders_z", "aov_z", "recency_z", "satisfaction_z"]
FINAL_K = 4


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM kmeans_input", conn)
    X = df[FEATURES].to_numpy()

    elbow_rows = []
    for k in range(2, 9):
        km = KMeans(n_clusters=k, n_init=10, random_state=42)
        km.fit(X)
        elbow_rows.append({"k": k, "inertia": km.inertia_})
    elbow = pd.DataFrame(elbow_rows)

    final_model = KMeans(n_clusters=FINAL_K, n_init=10, random_state=42)
    labels = final_model.fit_predict(X)

    assignments = pd.DataFrame(
        {"customer_id": df["customer_id"], "cluster": labels}
    )

    centers = pd.DataFrame(final_model.cluster_centers_, columns=FEATURES)
    centers.insert(0, "cluster", range(FINAL_K))

    elbow.to_sql("kmeans_elbow", conn, if_exists="replace", index=False)
    assignments.to_sql("kmeans_assignments", conn, if_exists="replace", index=False)
    centers.to_sql("kmeans_centers_z", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(elbow.to_string(index=False))
    print()
    print(assignments["cluster"].value_counts().sort_index())


if __name__ == "__main__":
    main()
