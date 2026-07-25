"""MDS: SQL이 만든 region_distance(지역 간 거리행렬)를 2차원 좌표로 압축한다."""

import os
import sys

import pandas as pd
from sklearn.manifold import MDS

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402


def main():
    conn = get_conn()
    long_df = pd.read_sql("SELECT * FROM region_distance", conn)
    dist_matrix = long_df.pivot(index="state1", columns="state2", values="distance")
    dist_matrix = dist_matrix.loc[sorted(dist_matrix.index), sorted(dist_matrix.columns)]
    states = dist_matrix.index.tolist()

    mds = MDS(
        n_components=2,
        dissimilarity="precomputed",
        random_state=42,
        n_init=10,
        normalized_stress=True,  # README 공식(Stress = sqrt(sum(d-dhat)^2 / sum(d^2)))과 일치시킴
    )
    coords = mds.fit_transform(dist_matrix.to_numpy())

    coords_df = pd.DataFrame(coords, columns=["x", "y"])
    coords_df.insert(0, "state", states)

    stress_df = pd.DataFrame(
        {"stress": [mds.stress_], "n_regions": [len(states)], "n_components": [2]}
    )

    coords_df.to_sql("mds_coords", conn, if_exists="replace", index=False)
    stress_df.to_sql("mds_stress", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(coords_df.round(3).to_string(index=False))
    print(f"\nstress = {mds.stress_:.3f}")


if __name__ == "__main__":
    main()
