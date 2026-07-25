"""[골격 코드 - 현재 실행 불가]

요청: "연관규칙: 동일 주문 내 상품 범주 동시 구매"
필요 테이블: order_items(order_id, product_id), products(product_id, product_category_name)

이 저장소의 customers 파일에는 주문·상품 정보가 전혀 없어 대체 불가능하다
(고객 파일만으로는 이 기법을 어떤 형태로도 흉내낼 수 없음 - 03-기법별적용/README.md
"완전 불가" 항목).
"""

import os
import sqlite3

DB_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "01-기본탐색",
    "olist.db",
)
REQUIRED_TABLES = ["order_items", "products"]


def check_required_tables(conn):
    existing = {
        r[0] for r in conn.execute("SELECT name FROM sqlite_master WHERE type='table'")
    }
    missing = [t for t in REQUIRED_TABLES if t not in existing]
    if missing:
        raise RuntimeError(f"다음 테이블이 없어 이 스켈레톤을 실행할 수 없습니다: {missing}")


def main():
    conn = sqlite3.connect(DB_PATH)
    check_required_tables(conn)  # 지금은 여기서 항상 RuntimeError 발생

    # --- 아래는 테이블이 추가된 뒤 사용할 골격 ---
    # import pandas as pd
    # from mlxtend.frequent_patterns import apriori, association_rules
    #
    # basket = pd.read_sql(
    #     """
    #     SELECT DISTINCT oi.order_id, p.product_category_name AS category
    #     FROM order_items oi
    #     JOIN products p ON p.product_id = oi.product_id
    #     """,
    #     conn,
    # )
    # onehot = basket.assign(v=1).pivot_table(
    #     index="order_id", columns="category", values="v", fill_value=0
    # ).astype(bool)
    # freq = apriori(onehot, min_support=0.01, use_colnames=True)
    # rules = association_rules(freq, metric="lift", min_threshold=1.0)
    # print(rules.sort_values("lift", ascending=False).head(10))


if __name__ == "__main__":
    main()
