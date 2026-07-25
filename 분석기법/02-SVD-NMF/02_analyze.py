"""SVD·NMF 학습: svd_input_matrix(고객 x 카테고리 wide 행렬)를 k=3 잠재축으로 분해한다.
분해 결과(특이값/인자행렬)와 셀 단위 재구성 오차를 DB 테이블로 저장한다.
"""

import os
import sys

import numpy as np
import pandas as pd
from sklearn.decomposition import NMF

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402

K = 3


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM svd_input_matrix", conn)
    categories = [c for c in df.columns if c != "customer_id"]
    A = df[categories].to_numpy(dtype=float)

    # ---- SVD ----
    U, S, Vt = np.linalg.svd(A, full_matrices=False)
    Uk, Sk, Vtk = U[:, :K], S[:K], Vt[:K, :]
    A_hat_svd = Uk @ np.diag(Sk) @ Vtk

    sv_ratio = (S**2) / (S**2).sum()
    svd_singular_values = pd.DataFrame(
        {
            "component": [f"S{i+1}" for i in range(len(S))],
            "singular_value": S,
            "explained_variance_ratio": sv_ratio,
        }
    )

    svd_customer_factors = pd.DataFrame(
        Uk * Sk, columns=[f"comp{i+1}" for i in range(K)]
    )
    svd_customer_factors.insert(0, "customer_id", df["customer_id"])

    svd_category_factors = pd.DataFrame(
        Vtk.T, columns=[f"comp{i+1}" for i in range(K)]
    )
    svd_category_factors.insert(0, "category", categories)

    # ---- NMF ----
    nmf = NMF(n_components=K, init="nndsvda", random_state=42, max_iter=1000)
    W = nmf.fit_transform(A)
    H = nmf.components_
    A_hat_nmf = W @ H

    nmf_customer_factors = pd.DataFrame(W, columns=[f"comp{i+1}" for i in range(K)])
    nmf_customer_factors.insert(0, "customer_id", df["customer_id"])

    nmf_category_factors = pd.DataFrame(H.T, columns=[f"comp{i+1}" for i in range(K)])
    nmf_category_factors.insert(0, "category", categories)

    # ---- 재구성 오차 (셀 단위, 롱포맷) ----
    def melt_error(A_hat, method):
        rows = []
        for i, cid in enumerate(df["customer_id"]):
            for j, cat in enumerate(categories):
                orig = A[i, j]
                pred = A_hat[i, j]
                rows.append((method, cid, cat, orig, pred, abs(orig - pred)))
        return pd.DataFrame(
            rows,
            columns=["method", "customer_id", "category", "original_amount", "reconstructed_amount", "abs_error"],
        )

    error_df = pd.concat(
        [melt_error(A_hat_svd, "SVD"), melt_error(A_hat_nmf, "NMF")], ignore_index=True
    )

    summary = (
        error_df.groupby("method")
        .apply(lambda g: pd.Series({"rmse": np.sqrt((g["abs_error"] ** 2).mean())}))
        .reset_index()
    )
    summary["k"] = K

    svd_singular_values.to_sql("svd_singular_values", conn, if_exists="replace", index=False)
    svd_customer_factors.to_sql("svd_customer_factors", conn, if_exists="replace", index=False)
    svd_category_factors.to_sql("svd_category_factors", conn, if_exists="replace", index=False)
    nmf_customer_factors.to_sql("nmf_customer_factors", conn, if_exists="replace", index=False)
    nmf_category_factors.to_sql("nmf_category_factors", conn, if_exists="replace", index=False)
    error_df.to_sql("factorization_reconstruction_error", conn, if_exists="replace", index=False)
    summary.to_sql("factorization_summary", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(svd_singular_values.round(3).to_string(index=False))
    print()
    print(summary.round(4).to_string(index=False))


if __name__ == "__main__":
    main()
