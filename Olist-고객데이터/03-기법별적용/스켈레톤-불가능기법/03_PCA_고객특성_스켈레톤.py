"""[골격 코드 - 현재 실행 불가]

요청: "PCA: 고객별 구매·결제·배송 특성 축소"
필요 테이블: orders, order_items(price, freight_value), order_payments(payment_value,
             payment_installments)

지금 가능한 것은 "고객(customer_unique_id) 단위"가 아니라 "주(state) 단위" 집계
PCA뿐이다 -> ../D-지역프로파일-PCA-Kmeans-보너스/ 참고. 이 스켈레톤은 실제 주문
데이터가 추가됐을 때 "고객별" PCA를 하기 위한 골격이다.
"""

import os
import sqlite3

DB_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "01-기본탐색",
    "olist.db",
)
REQUIRED_TABLES = ["orders", "order_items", "order_payments"]


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
    # from sklearn.decomposition import PCA
    # from sklearn.preprocessing import StandardScaler
    #
    # df = pd.read_sql(
    #     """
    #     SELECT
    #         c.customer_unique_id,
    #         COUNT(DISTINCT o.order_id) AS n_orders,
    #         AVG(oi.price) AS avg_item_price,
    #         AVG(oi.freight_value) AS avg_freight,
    #         AVG(p.payment_installments) AS avg_installments,
    #         AVG(JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_purchase_timestamp)) AS avg_delivery_days
    #     FROM customers c
    #     JOIN orders o ON o.customer_id = c.customer_id
    #     JOIN order_items oi ON oi.order_id = o.order_id
    #     JOIN order_payments p ON p.order_id = o.order_id
    #     GROUP BY c.customer_unique_id
    #     """,
    #     conn,
    # )
    # features = ["n_orders", "avg_item_price", "avg_freight", "avg_installments", "avg_delivery_days"]
    # X = StandardScaler().fit_transform(df[features])
    # pca = PCA(n_components=len(features)).fit(X)
    # print(pca.explained_variance_ratio_)


if __name__ == "__main__":
    main()
