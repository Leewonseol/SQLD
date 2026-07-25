"""PCA 학습: 01_prepare.sql이 만든 pca_input(표준화 데이터)에 sklearn.PCA를 적합한다.
결과(고유값/설명분산비율, 적재량, 성분점수)를 DB 테이블로 저장한다.
실행 전 01_prepare.sql을 먼저 적용해야 한다.
"""

import os
import sys

import pandas as pd
from sklearn.decomposition import PCA

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

FEATURES = [
    "age_z",
    "income_z",
    "membership_z",
    "orders_z",
    "aov_z",
    "recency_z",
    "satisfaction_z",
]


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM pca_input", conn)

    X = df[FEATURES].to_numpy()
    pca = PCA(n_components=len(FEATURES))
    scores = pca.fit_transform(X)

    variance = pd.DataFrame(
        {
            "component": [f"PC{i+1}" for i in range(len(FEATURES))],
            "eigenvalue": pca.explained_variance_,
            "explained_variance_ratio": pca.explained_variance_ratio_,
            "cumulative_ratio": pca.explained_variance_ratio_.cumsum(),
        }
    )

    loadings_rows = []
    for i in range(len(FEATURES)):
        for j, feat in enumerate(FEATURES):
            loadings_rows.append((f"PC{i+1}", feat, float(pca.components_[i, j])))
    loadings = pd.DataFrame(loadings_rows, columns=["component", "feature", "loading"])

    scores_df = pd.DataFrame(scores, columns=[f"PC{i+1}" for i in range(len(FEATURES))])
    scores_df.insert(0, "customer_id", df["customer_id"])

    variance.to_sql("pca_variance", conn, if_exists="replace", index=False)
    loadings.to_sql("pca_loadings", conn, if_exists="replace", index=False)
    scores_df.to_sql("pca_scores", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(variance.round(4).to_string(index=False))
    print(f"\nPC1+PC2 누적기여율: {variance['cumulative_ratio'].iloc[1]:.2%}")


if __name__ == "__main__":
    main()
