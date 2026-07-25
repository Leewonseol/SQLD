"""
분석기법 실습 공통 데이터베이스 생성 스크립트
================================================
olist_customers_dataset.csv 에서 실제 고객 1,000명을 표본 추출하고,
그 위에 재현 가능한(seed=42) 합성 특성·타깃·시계열·거래 데이터를 얹어
분석기법/_data/bigdata_exam.db (SQLite) 를 만든다.

이 DB는 이후 모든 기법 폴더(01-PCA ... 20-데이터전처리와변수변환)의
공통 입력이다. 각 기법의 01_prepare.sql 이 이 DB 위에서 SELECT/VIEW/CREATE TABLE로
분석 입력을 준비하고, 02_analyze.py 가 Python으로 모델을 적합한 뒤 결과를
같은 DB에 저장하며, 03_verify.sql 이 그 결과를 SQL로 검산한다.

실행:
    python3 분석기법/_data/build_db.py
"""

import os
import sqlite3

import numpy as np
import pandas as pd

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(HERE))
CSV_PATH = os.path.join(REPO_ROOT, "olist_customers_dataset.csv")
DB_PATH = os.path.join(HERE, "bigdata_exam.db")
SCHEMA_PATH = os.path.join(HERE, "schema.sql")

N_CUSTOMERS = 1000
SEED = 42


def load_customers():
    df = pd.read_csv(CSV_PATH)
    df = df.sample(n=N_CUSTOMERS, random_state=SEED).reset_index(drop=True)
    customers = df.rename(
        columns={
            "customer_zip_code_prefix": "zip_code_prefix",
            "customer_city": "city",
            "customer_state": "state",
        }
    )[["customer_id", "customer_unique_id", "zip_code_prefix", "city", "state"]]
    customers["zip_code_prefix"] = customers["zip_code_prefix"].astype(str)
    return customers


def build_customer_features(customers, rng):
    n = len(customers)
    age = rng.integers(18, 71, size=n)
    membership_years = np.round(rng.uniform(0, 10, size=n), 2)
    annual_income_10k = np.clip(
        1800 + 25 * (age - 18) + 300 * membership_years + rng.normal(0, 400, size=n),
        800,
        None,
    )
    annual_income_10k = np.round(annual_income_10k, 1)

    order_count = rng.poisson(lam=np.clip(annual_income_10k / 1500, 1, None))
    order_count = np.clip(order_count, 0, None)

    avg_order_value = np.clip(
        3 + annual_income_10k / 400 + rng.normal(0, 3, size=n), 1, None
    )
    avg_order_value = np.round(avg_order_value, 1)

    days_since_last_order = np.clip(
        rng.exponential(scale=60, size=n) - 5 * membership_years, 0, 400
    ).astype(int)

    satisfaction_raw = (
        3
        + 0.35 * (avg_order_value - avg_order_value.mean()) / avg_order_value.std()
        - 0.30 * (days_since_last_order - days_since_last_order.mean())
        / days_since_last_order.std()
        + rng.normal(0, 0.6, size=n)
    )
    satisfaction_score = np.clip(np.round(satisfaction_raw, 2), 1, 5)

    feats = pd.DataFrame(
        {
            "customer_id": customers["customer_id"],
            "age": age,
            "annual_income_10k": annual_income_10k,
            "membership_years": membership_years,
            "order_count": order_count,
            "avg_order_value": avg_order_value,
            "days_since_last_order": days_since_last_order,
            "satisfaction_score": satisfaction_score,
        }
    )
    return feats


def build_customer_labels(feats, rng):
    n = len(feats)
    z = feats["annual_income_10k"].to_numpy()
    z = (z - z.mean()) / z.std()
    next_month_spend = (
        5
        + 1.8 * feats["avg_order_value"]
        + 0.9 * feats["order_count"]
        + 0.6 * feats["membership_years"]
        + 0.4 * z
        + rng.normal(0, 3, size=n)
    )
    next_month_spend = np.round(np.clip(next_month_spend, 0, None), 1)

    logit = (
        -2.0
        + 0.02 * feats["days_since_last_order"]
        - 0.55 * feats["satisfaction_score"]
        - 0.05 * feats["order_count"]
        - 0.05 * feats["membership_years"]
    )
    prob = 1 / (1 + np.exp(-logit))
    churned = rng.binomial(1, prob)

    return pd.DataFrame(
        {
            "customer_id": feats["customer_id"],
            "next_month_spend": next_month_spend,
            "churned": churned,
        }
    )


def build_category_spend(customers, rng):
    categories = ["전자제품", "의류", "도서", "식품", "가구", "뷰티", "스포츠", "완구"]
    n = len(customers)
    k = 3  # 잠재 취향 축 개수
    cust_latent = rng.gamma(shape=1.5, scale=1.0, size=(n, k))
    cat_latent = rng.gamma(shape=1.5, scale=1.0, size=(k, len(categories)))
    base = cust_latent @ cat_latent
    noise = rng.gamma(shape=2.0, scale=0.5, size=base.shape)
    amount = np.round(np.clip(base * 8 + noise, 0, None), 1)

    rows = []
    for i, cid in enumerate(customers["customer_id"]):
        for j, cat in enumerate(categories):
            if amount[i, j] > 1.0:  # 구매 이력이 없는 조합은 행을 만들지 않음(희소행렬)
                rows.append((cid, cat, float(amount[i, j])))
    return pd.DataFrame(rows, columns=["customer_id", "category", "amount"])


def build_survey(customers, rng):
    n = len(customers)
    quality_factor = rng.normal(0, 1, size=n)
    service_factor = rng.normal(0, 1, size=n)

    def item(loading_q, loading_s, noise_sd=0.5):
        raw = 3 + loading_q * quality_factor + loading_s * service_factor + rng.normal(
            0, noise_sd, size=n
        )
        return np.clip(np.round(raw), 1, 5)

    return pd.DataFrame(
        {
            "customer_id": customers["customer_id"],
            "q1_quality": item(0.9, 0.1),
            "q2_price": item(0.7, 0.0),
            "q3_delivery": item(0.1, 0.9),
            "q4_service": item(0.0, 0.8),
            "q5_repurchase": item(0.6, 0.5),
            "q6_recommend": item(0.5, 0.6),
        }
    )


def build_monthly_sales(rng):
    n = 48
    t = np.arange(n)
    trend = 800 + 6.5 * t
    seasonal = 60 * np.sin(2 * np.pi * t / 12) + 25 * np.sin(2 * np.pi * t / 6)
    noise = rng.normal(0, 20, size=n)
    sales = np.round(trend + seasonal + noise, 1)
    dates = pd.date_range("2022-01-01", periods=n, freq="MS").strftime("%Y-%m-%d")
    return pd.DataFrame({"month_id": np.arange(1, n + 1), "month_date": dates, "sales": sales})


def build_basket(rng):
    # 클래식 장바구니 세트에 상관관계를 심어 연관규칙이 의미 있게 나오도록 구성
    item_pool = ["기저귀", "맥주", "빵", "우유", "계란", "커피", "설탕", "과자", "라면", "생수"]
    n_tx = 600
    rows = []
    for tx in range(1, n_tx + 1):
        items = set()
        # 상관 세트 1: 기저귀-맥주
        if rng.random() < 0.25:
            items.update(["기저귀", "맥주"])
        # 상관 세트 2: 빵-우유-계란
        if rng.random() < 0.35:
            items.update(["빵", "우유"])
            if rng.random() < 0.6:
                items.add("계란")
        # 상관 세트 3: 커피-설탕
        if rng.random() < 0.30:
            items.update(["커피", "설탕"])
        # 나머지는 임의로 0~2개 추가
        extra_n = rng.integers(0, 3)
        extra = rng.choice(item_pool, size=extra_n, replace=False)
        items.update(extra.tolist())
        if not items:
            items.add(rng.choice(item_pool))
        for it in items:
            rows.append((tx, it))
    return pd.DataFrame(rows, columns=["transaction_id", "item"])


def build_hypothesis_tables(rng):
    # 지점별 만족도 (일원배치 분산분석)
    branch_rows = []
    means = {"A": 3.4, "B": 3.7, "C": 3.9}
    for b, m in means.items():
        scores = np.clip(rng.normal(m, 0.5, size=60), 1, 5)
        for s in scores:
            branch_rows.append((b, round(float(s), 2)))
    branch_scores = pd.DataFrame(branch_rows, columns=["branch", "score"])

    # 프로모션 전/후 (대응표본 t검정)
    n = 200
    before = np.clip(rng.normal(3.2, 0.6, size=n), 1, 5)
    after = np.clip(before + rng.normal(0.35, 0.5, size=n), 1, 5)
    paired = pd.DataFrame(
        {
            "customer_id": [f"P{idx:04d}" for idx in range(n)],
            "before_score": np.round(before, 2),
            "after_score": np.round(after, 2),
        }
    )

    # A/B 테스트 전환 여부 (카이제곱 독립성 검정)
    n_ab = 800
    variant = rng.choice(["A", "B"], size=n_ab)
    p = np.where(variant == "A", 0.10, 0.145)
    converted = rng.binomial(1, p)
    ab_test = pd.DataFrame(
        {
            "customer_id": [f"AB{idx:04d}" for idx in range(n_ab)],
            "variant": variant,
            "converted": converted,
        }
    )
    return branch_scores, paired, ab_test


def build_raw_intake(feats, rng):
    n = len(feats)
    income = feats["annual_income_10k"].to_numpy().astype(float).copy()
    age = feats["age"].to_numpy().astype(float).copy()

    miss_idx = rng.choice(n, size=int(n * 0.06), replace=False)
    income[miss_idx] = np.nan
    miss_idx2 = rng.choice(n, size=int(n * 0.04), replace=False)
    age[miss_idx2] = np.nan

    out_idx = rng.choice(n, size=int(n * 0.02), replace=False)
    income[out_idx] = income[out_idx] * 12  # 소득 이상치

    out_idx2 = rng.choice(n, size=int(n * 0.015), replace=False)
    age[out_idx2] = 150  # 나이 이상치

    gender_variants = ["M", "F", "male", "Female", "m", "f", None]
    gender = rng.choice(gender_variants, size=n)

    dates = pd.date_range("2019-01-01", periods=n, freq="D").strftime("%Y-%m-%d").to_numpy()
    rng.shuffle(dates)
    bad_fmt_idx = rng.choice(n, size=int(n * 0.05), replace=False)
    dates = dates.astype(object)
    for i in bad_fmt_idx:
        d = pd.Timestamp(dates[i])
        dates[i] = d.strftime("%Y/%m/%d")

    return pd.DataFrame(
        {
            "customer_id": feats["customer_id"],
            "income_raw": income,
            "age_raw": age,
            "gender_raw": gender,
            "signup_date_raw": dates,
        }
    )


def main():
    rng = np.random.default_rng(SEED)

    customers = load_customers()
    feats = build_customer_features(customers, rng)
    labels = build_customer_labels(feats, rng)
    cat_spend = build_category_spend(customers, rng)
    survey = build_survey(customers, rng)
    monthly_sales = build_monthly_sales(rng)
    basket = build_basket(rng)
    branch_scores, paired, ab_test = build_hypothesis_tables(rng)
    raw_intake = build_raw_intake(feats, rng)

    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
    conn = sqlite3.connect(DB_PATH)
    try:
        customers.to_sql("customers", conn, index=False)
        feats.to_sql("customer_features", conn, index=False)
        labels.to_sql("customer_labels", conn, index=False)
        cat_spend.to_sql("customer_category_spend", conn, index=False)
        survey.to_sql("customer_survey", conn, index=False)
        monthly_sales.to_sql("monthly_sales", conn, index=False)
        basket.to_sql("basket_transactions", conn, index=False)
        branch_scores.to_sql("branch_scores", conn, index=False)
        paired.to_sql("paired_scores", conn, index=False)
        ab_test.to_sql("ab_test", conn, index=False)
        raw_intake.to_sql("raw_customer_intake", conn, index=False)
        conn.commit()

        print("생성된 테이블 및 행 수:")
        for t in [
            "customers",
            "customer_features",
            "customer_labels",
            "customer_category_spend",
            "customer_survey",
            "monthly_sales",
            "basket_transactions",
            "branch_scores",
            "paired_scores",
            "ab_test",
            "raw_customer_intake",
        ]:
            cnt = conn.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
            print(f"  {t}: {cnt} rows")
    finally:
        conn.close()
    print(f"\nDB 생성 완료 -> {DB_PATH}")


if __name__ == "__main__":
    main()
