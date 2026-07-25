"""주(state) 프로파일에 PCA와 K-means(k=3)를 적용한다."""

import os
import sqlite3

import pandas as pd
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA

DB_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "01-기본탐색",
    "olist.db",
)
FEATURES = ["n_customers_z", "repeat_rate_z", "avg_n_orders_z", "n_cities_z", "city_hhi_z"]


def main():
    conn = sqlite3.connect(DB_PATH)
    df = pd.read_sql("SELECT * FROM state_profile_z", conn)
    X = df[FEATURES].to_numpy()

    pca = PCA(n_components=len(FEATURES))
    scores = pca.fit_transform(X)
    variance = pd.DataFrame(
        {
            "component": [f"PC{i+1}" for i in range(len(FEATURES))],
            "explained_variance_ratio": pca.explained_variance_ratio_,
            "cumulative_ratio": pca.explained_variance_ratio_.cumsum(),
        }
    )
    scores_df = pd.DataFrame(scores[:, :2], columns=["PC1", "PC2"])
    scores_df.insert(0, "state", df["state"])

    km = KMeans(n_clusters=3, n_init=10, random_state=42)
    labels = km.fit_predict(X)
    clusters = pd.DataFrame({"state": df["state"], "cluster": labels})

    variance.to_sql("state_pca_variance", conn, if_exists="replace", index=False)
    scores_df.to_sql("state_pca_scores", conn, if_exists="replace", index=False)
    clusters.to_sql("state_kmeans_clusters", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(variance.round(4).to_string(index=False))
    print()
    print(clusters.sort_values("cluster").to_string(index=False))


if __name__ == "__main__":
    main()
