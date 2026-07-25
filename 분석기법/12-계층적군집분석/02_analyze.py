"""계층적 군집분석: hier_input(40명 표본)에 Ward 연결법으로 병합하고 k=4로 절단한다."""

import os
import sys

import pandas as pd
from scipy.cluster.hierarchy import fcluster, linkage

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

FEATURES = ["age_z", "income_z", "membership_z", "orders_z", "aov_z", "recency_z", "satisfaction_z"]
FINAL_K = 4


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM hier_input", conn)
    X = df[FEATURES].to_numpy()

    Z = linkage(X, method="ward")
    n = len(df)

    merges = pd.DataFrame(
        Z, columns=["cluster1_idx", "cluster2_idx", "distance", "n_items"]
    )
    merges.insert(0, "step", range(1, len(Z) + 1))

    labels = fcluster(Z, t=FINAL_K, criterion="maxclust")
    assignments = pd.DataFrame({"customer_id": df["customer_id"], "cluster": labels})

    merges.to_sql("hier_merges", conn, if_exists="replace", index=False)
    assignments.to_sql("hier_assignments", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(f"n={n}, merge steps={len(Z)}")
    print(merges.tail(6).round(3).to_string(index=False))
    print()
    print(assignments["cluster"].value_counts().sort_index())


if __name__ == "__main__":
    main()
