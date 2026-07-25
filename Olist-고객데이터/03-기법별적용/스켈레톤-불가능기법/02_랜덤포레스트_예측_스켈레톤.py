"""[골격 코드 - 현재 실행 불가]

요청: "랜덤 포레스트: 배송 지연 또는 저평점 예측"
필요 테이블: orders(order_purchase_timestamp, order_estimated_delivery_date,
             order_delivered_customer_date), order_reviews(order_id, review_score)

이 저장소에는 두 테이블이 없어 즉시 raise한다. 추가되면 아래 주석을 해제하고
실제 컬럼명에 맞춰 수정할 것.
"""

import os
import sqlite3

DB_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "01-기본탐색",
    "olist.db",
)
REQUIRED_TABLES = ["orders", "order_reviews"]


def check_required_tables(conn):
    existing = {
        r[0] for r in conn.execute("SELECT name FROM sqlite_master WHERE type='table'")
    }
    missing = [t for t in REQUIRED_TABLES if t not in existing]
    if missing:
        raise RuntimeError(
            f"다음 테이블이 없어 이 스켈레톤을 실행할 수 없습니다: {missing}. "
            "02-관계파일확인/README.md를 참고해 원본 Olist 파일을 추가하세요."
        )


def main():
    conn = sqlite3.connect(DB_PATH)
    check_required_tables(conn)  # 지금은 여기서 항상 RuntimeError 발생

    # --- 아래는 테이블이 추가된 뒤 사용할 골격 ---
    # import pandas as pd
    # from sklearn.ensemble import RandomForestClassifier
    # from sklearn.model_selection import train_test_split
    #
    # df = pd.read_sql(
    #     """
    #     SELECT
    #         o.order_id,
    #         JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_purchase_timestamp) AS delivery_days,
    #         JULIANDAY(o.order_delivered_customer_date) > JULIANDAY(o.order_estimated_delivery_date) AS is_late,
    #         r.review_score,
    #         CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END AS is_low_rating
    #     FROM orders o
    #     JOIN order_reviews r ON r.order_id = o.order_id
    #     WHERE o.order_delivered_customer_date IS NOT NULL
    #     """,
    #     conn,
    # )
    # X = df[["delivery_days"]]  # 실제로는 order_items/payments 등에서 파생한 특성을 더 추가
    # y = df["is_low_rating"]
    # X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    # model = RandomForestClassifier(random_state=42).fit(X_train, y_train)
    # pred = model.predict(X_test)
    # ...


if __name__ == "__main__":
    main()
