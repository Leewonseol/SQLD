"""SQL로 계산한 순위 인코딩·편중도(HHI)를 Python으로 교차검증하고,
SQL만으로는 다소 번거로운 지니계수(Gini)를 추가로 계산한다.
"""

import os
import sqlite3

import numpy as np
import pandas as pd

DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "olist.db")


def gini(counts):
    x = np.sort(np.asarray(counts, dtype=float))
    n = len(x)
    cum = np.cumsum(x)
    return float((n + 1 - 2 * np.sum(cum) / cum[-1]) / n)


def main():
    conn = sqlite3.connect(DB_PATH)

    raw = pd.read_sql("SELECT customer_state FROM customers_raw", conn)
    state_counts = raw["customer_state"].value_counts()

    # 1) SQL의 state_label_encoding(DENSE_RANK 기반)과 pandas로 독립 재계산한 순위가 일치하는지 확인
    py_rank = state_counts.rank(ascending=False, method="dense").astype(int)
    sql_rank = pd.read_sql("SELECT customer_state, state_label_code FROM state_label_encoding", conn)
    sql_rank = sql_rank.set_index("customer_state")["state_label_code"]
    mismatch = (py_rank.sort_index() != sql_rank.sort_index()).sum()
    print(f"SQL DENSE_RANK vs pandas rank 불일치 건수: {mismatch} (0이어야 함)")

    # 2) HHI를 pandas로 재계산해 SQL 결과와 대조
    shares = state_counts / state_counts.sum()
    hhi_py = float((shares**2).sum())
    hhi_sql = conn.execute(
        "SELECT hhi FROM (SELECT ROUND(SUM((1.0*n_customers/total)*(1.0*n_customers/total)),4) AS hhi "
        "FROM (SELECT customer_state, n_customers, (SELECT COUNT(*) FROM customers_raw) AS total "
        "FROM (SELECT customer_state, COUNT(*) AS n_customers FROM customers_raw GROUP BY customer_state)))"
    ).fetchone()[0]
    print(f"HHI: python={hhi_py:.4f}, sql={hhi_sql:.4f}")

    # 3) 지니계수 (SQL 창함수만으로도 가능하지만 여기서는 numpy로 계산)
    gini_states = gini(state_counts.values)
    print(f"주(state)별 고객분포 지니계수: {gini_states:.4f} (0=완전균등, 1=완전편중)")

    conn.close()


if __name__ == "__main__":
    main()
