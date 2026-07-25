"""연관규칙: basket_onehot(원-핫 거래행렬)에 Apriori를 적용해 지지도·신뢰도·향상도를 계산한다."""

import os
import sys

import pandas as pd
from mlxtend.frequent_patterns import apriori, association_rules

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_data"))
from dbutil import get_conn  # noqa: E402


def main():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM basket_onehot", conn)
    items = df.drop(columns=["transaction_id"]).astype(bool)

    freq_itemsets = apriori(items, min_support=0.03, use_colnames=True)
    rules = association_rules(freq_itemsets, metric="lift", min_threshold=1.0, num_itemsets=len(items))
    rules = rules.sort_values("lift", ascending=False)

    rules_out = rules.copy()
    rules_out["antecedents"] = rules_out["antecedents"].apply(lambda s: ",".join(sorted(s)))
    rules_out["consequents"] = rules_out["consequents"].apply(lambda s: ",".join(sorted(s)))
    rules_out = rules_out[["antecedents", "consequents", "support", "confidence", "lift"]]

    # 단일 품목 -> 단일 품목 규칙만 따로 저장 (실기에서 흔히 다루는 "고전적" 2품목 규칙)
    is_single = rules_out["antecedents"].apply(lambda s: "," not in s) & rules_out[
        "consequents"
    ].apply(lambda s: "," not in s)
    simple_rules = rules_out[is_single].sort_values("lift", ascending=False)

    rules_out.to_sql("association_rules_result", conn, if_exists="replace", index=False)
    simple_rules.to_sql("association_rules_simple", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

    print("단일 품목 규칙 (상위 5개)")
    print(simple_rules.round(4).head(5).to_string(index=False))
    print("\n다품목 포함 전체 규칙 중 lift 상위 5개")
    print(rules_out.round(4).head(5).to_string(index=False))


if __name__ == "__main__":
    main()
