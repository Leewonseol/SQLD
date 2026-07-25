"""olist_customers_dataset.csv 프로파일링 스크립트.

이 스크립트가 출력하는 숫자가 곧 같은 폴더 README.md(데이터 사전)의 근거 자료다.
값이 바뀌면(원본 CSV가 갱신되면) 이 스크립트를 다시 실행해 README.md 표를 갱신해야 한다.
"""

import os
import re

import pandas as pd

CSV_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "olist_customers_dataset.csv",
)


def main():
    # dtype=str로 전부 문자열로 읽는다: customer_zip_code_prefix를 숫자로 자동 캐스팅하면
    # 선행 0이 있는 우편번호가 깨질 수 있고, 이 필드는 애초에 식별/지역 코드이지 연속형이 아니다.
    df = pd.read_csv(CSV_PATH, dtype=str, keep_default_na=False)

    print("=" * 60)
    print("1) 스키마 / 행 수")
    print("=" * 60)
    print("columns:", list(df.columns))
    print("dtypes(as read): 전부 문자열로 로드 (zip은 식별코드이므로 의도적으로 str 유지)")
    print("row count:", len(df))

    print("\n" + "=" * 60)
    print("2) 식별자 유일성")
    print("=" * 60)
    print("customer_id 유일값 수:", df["customer_id"].nunique(), "(행수와 동일해야 order-grain PK)")
    print("customer_id 중복 행 수:", df["customer_id"].duplicated().sum())
    print("customer_unique_id 유일값 수:", df["customer_unique_id"].nunique())
    print("전체 행 완전 중복 수:", df.duplicated().sum())

    print("\n" + "=" * 60)
    print("3) customer_unique_id 반복분포 (재구매 구조)")
    print("=" * 60)
    vc = df["customer_unique_id"].value_counts()
    print(vc.value_counts().sort_index().rename("n_customer_unique_id"))
    print("최대 반복 횟수:", vc.max())
    print("2회 이상 등장(재구매로 해석 가능)한 고유고객 수:", (vc > 1).sum())

    print("\n" + "=" * 60)
    print("4) 결측치 / 빈 문자열")
    print("=" * 60)
    for col in df.columns:
        n_null = df[col].isna().sum()
        n_empty = (df[col].astype(str).str.strip() == "").sum()
        print(f"  {col}: null={n_null}, empty_str={n_empty}")

    print("\n" + "=" * 60)
    print("5) customer_zip_code_prefix 형식")
    print("=" * 60)
    print("자리수 분포:\n", df["customer_zip_code_prefix"].str.len().value_counts())
    non_numeric = (~df["customer_zip_code_prefix"].str.fullmatch(r"\d+")).sum()
    print("숫자가 아닌 값 개수:", non_numeric)

    print("\n" + "=" * 60)
    print("6) customer_city 정규화 상태")
    print("=" * 60)
    print("대문자 포함:", df["customer_city"].str.contains(r"[A-Z]").sum())
    print("앞뒤 공백 포함:", (df["customer_city"] != df["customer_city"].str.strip()).sum())
    print("연속 공백 포함:", df["customer_city"].str.contains(r"  ").sum())
    weird = df["customer_city"].apply(lambda s: bool(re.search(r"[^a-z0-9\-' ]", s)))
    print("영소문자/숫자/하이픈/따옴표/공백 이외 문자 포함:", weird.sum())
    print("고유 도시 수:", df["customer_city"].nunique())

    print("\n" + "=" * 60)
    print("7) customer_state")
    print("=" * 60)
    print("고유 state 수:", df["customer_state"].nunique())
    print(df["customer_state"].value_counts())

    print("\n" + "=" * 60)
    print("8) city가 여러 state에 걸쳐 나타나는 경우 (city 단독으로는 키가 될 수 없음)")
    print("=" * 60)
    g = df.groupby("customer_city")["customer_state"].nunique()
    print("2개 이상 state에서 나타나는 city 수:", (g > 1).sum())


if __name__ == "__main__":
    main()
