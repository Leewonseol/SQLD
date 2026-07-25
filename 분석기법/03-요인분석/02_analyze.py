"""요인분석: fa_input(표준화된 설문 6문항)에서 2개 잠재요인을 추출한다."""

import os
import sys

import pandas as pd
from sklearn.decomposition import FactorAnalysis

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

ITEMS = ["q1_z", "q2_z", "q3_z", "q4_z", "q5_z", "q6_z"]
ITEM_LABELS = {
    "q1_z": "q1_quality",
    "q2_z": "q2_price",
    "q3_z": "q3_delivery",
    "q4_z": "q4_service",
    "q5_z": "q5_repurchase",
    "q6_z": "q6_recommend",
}
N_FACTORS = 2


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM fa_input", conn)
    X = df[ITEMS].to_numpy()

    fa = FactorAnalysis(n_components=N_FACTORS, random_state=42)
    scores = fa.fit_transform(X)

    loadings_rows = []
    for j, item in enumerate(ITEMS):
        for k in range(N_FACTORS):
            loadings_rows.append((ITEM_LABELS[item], f"Factor{k+1}", float(fa.components_[k, j])))
    loadings = pd.DataFrame(loadings_rows, columns=["item", "factor", "loading"])

    scores_df = pd.DataFrame(scores, columns=[f"Factor{k+1}" for k in range(N_FACTORS)])
    scores_df.insert(0, "customer_id", df["customer_id"])

    noise = pd.DataFrame(
        {"item": [ITEM_LABELS[i] for i in ITEMS], "noise_variance": fa.noise_variance_}
    )

    loadings.to_sql("fa_loadings", conn, if_exists="replace", index=False)
    scores_df.to_sql("fa_scores", conn, if_exists="replace", index=False)
    noise.to_sql("fa_noise_variance", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(loadings.pivot(index="item", columns="factor", values="loading").round(3))


if __name__ == "__main__":
    main()
