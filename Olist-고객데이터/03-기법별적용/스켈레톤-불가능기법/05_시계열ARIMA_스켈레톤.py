"""[골격 코드 - 현재 실행 불가]

요청: "시계열·ARIMA: 일·주·월별 주문량 또는 매출"
필요 테이블: orders(order_purchase_timestamp), order_items(price) 또는 order_payments(payment_value)

customers 파일에는 시간(날짜/타임스탬프) 컬럼이 단 하나도 없다 - 00-데이터사전/README.md
§2에서 확인했듯 5개 열 전부 식별자 또는 범주형이다. 따라서 이동평균·지수평활·ARIMA류
기법은 이 파일만으로는 어떤 형태로도 대체 불가능하다("완전 불가" 항목).
"""

import os
import sqlite3

DB_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "01-기본탐색",
    "olist.db",
)
REQUIRED_TABLES = ["orders"]


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

    # --- 아래는 orders/order_items가 추가된 뒤 사용할 골격 ---
    # import pandas as pd
    # from statsmodels.tsa.arima.model import ARIMA
    #
    # daily = pd.read_sql(
    #     """
    #     SELECT DATE(o.order_purchase_timestamp) AS order_date,
    #            COUNT(DISTINCT o.order_id) AS n_orders,
    #            SUM(oi.price) AS revenue
    #     FROM orders o
    #     JOIN order_items oi ON oi.order_id = o.order_id
    #     GROUP BY DATE(o.order_purchase_timestamp)
    #     ORDER BY order_date
    #     """,
    #     conn,
    # )
    # model = ARIMA(daily["revenue"], order=(1, 1, 1)).fit()
    # forecast = model.get_forecast(steps=14)
    # print(forecast.predicted_mean)


if __name__ == "__main__":
    main()
