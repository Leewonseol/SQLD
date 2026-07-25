"""변수 변환: customer_clean(SQL 정제 완료)에 표준화·정규화·로그변환·구간화·원-핫 인코딩을 적용한다."""

import os
import sys

import numpy as np
import pandas as pd
from sklearn.preprocessing import KBinsDiscretizer, MinMaxScaler, StandardScaler

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402


def skewness(x):
    x = np.asarray(x, dtype=float)
    return float(np.mean((x - x.mean()) ** 3) / x.std() ** 3)


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM customer_clean", conn)

    income = df[["income_clean"]].to_numpy()
    df["income_zscore"] = StandardScaler().fit_transform(income)
    df["income_minmax"] = MinMaxScaler().fit_transform(income)
    df["income_log"] = np.log1p(df["income_clean"])

    kbins = KBinsDiscretizer(n_bins=4, encode="ordinal", strategy="quantile")
    df["age_bin"] = kbins.fit_transform(df[["age_clean"]]).astype(int)

    gender_dummies = pd.get_dummies(df["gender_clean"], prefix="gender").astype(int)
    df = pd.concat([df, gender_dummies], axis=1)

    skew_summary = pd.DataFrame(
        {
            "variable": ["income_clean(원본)", "income_log(로그변환 후)"],
            "skewness": [skewness(df["income_clean"]), skewness(df["income_log"])],
        }
    )

    out_cols = [
        "customer_id",
        "income_clean",
        "income_zscore",
        "income_minmax",
        "income_log",
        "age_clean",
        "age_bin",
        "gender_clean",
    ] + list(gender_dummies.columns)
    transformed = df[out_cols]

    transformed.to_sql("customer_transformed", conn, if_exists="replace", index=False)
    skew_summary.to_sql("preprocessing_skewness", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print(skew_summary.round(4).to_string(index=False))
    print()
    print(transformed.head(5).round(3).to_string(index=False))


if __name__ == "__main__":
    main()
