import os
import pandas as pd
from sqlalchemy import create_engine
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_DATA_DIR = os.path.join(BASE_DIR, "data", "raw")
# PostgreSQL connection
DATABASE_URL = (
    "postgresql+psycopg2://admin:admin@localhost:5432/financial_analytics"
)
engine = create_engine(DATABASE_URL)

files = {
    "customers": "customers.csv",
    "products": "products.csv",
    "accounts": "accounts.csv",
    "transactions": "transactions.csv"
}
for table_name, filename in files.items():
    filepath = os.path.join(
        RAW_DATA_DIR,
        filename
    )
    df = pd.read_csv(filepath)
    df.to_sql(
        table_name,
        engine,
        if_exists="append",
        index=False
    )
    print(
        f"Loaded {len(df):,} rows into {table_name}"
    )
print("Data loading completed.")