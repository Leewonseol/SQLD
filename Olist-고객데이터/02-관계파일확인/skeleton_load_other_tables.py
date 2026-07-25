"""[골격 코드 - 현재 실행 불가]

이 저장소에는 아래 파일들이 존재하지 않는다(02-관계파일확인/README.md 참고).
Olist 데이터셋(예: Kaggle "Brazilian E-Commerce Public Dataset by Olist")의 나머지 CSV를
저장소 루트에 추가한 뒤, 아래 파일명을 실제 파일명으로, 각 컬럼을 실제 헤더로 맞춰 사용하라.
지금 이대로 실행하면 FileNotFoundError가 발생한다 - 이는 의도된 동작이다.
"""

import os
import sqlite3

import pandas as pd

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(HERE))
DB_PATH = os.path.join(HERE, "olist_full.db")

# 실제 파일이 추가되면 파일명을 확인하고 맞출 것 (아래는 Kaggle 배포판의 통상적인 파일명 예시)
EXPECTED_FILES = {
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}


def main():
    missing = [f for f in EXPECTED_FILES.values() if not os.path.exists(os.path.join(REPO_ROOT, f))]
    if missing:
        raise FileNotFoundError(
            "다음 파일이 저장소에 없어 로드할 수 없습니다(예상 파일명 기준, 실제와 다를 수 있음): "
            + ", ".join(missing)
        )

    conn = sqlite3.connect(DB_PATH)
    for table, filename in EXPECTED_FILES.items():
        df = pd.read_csv(os.path.join(REPO_ROOT, filename), dtype=str, keep_default_na=False)
        df.to_sql(table, conn, if_exists="replace", index=False)
        print(f"{table}: {len(df)}행 적재")
    conn.commit()
    conn.close()


if __name__ == "__main__":
    main()
