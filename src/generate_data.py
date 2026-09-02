import os
import random
from datetime import datetime, timedelta

import numpy as np
import pandas as pd

random.seed(42)
np.random.seed(42)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_DATA_DIR = os.path.join(BASE_DIR, "data", "raw")
os.makedirs(RAW_DATA_DIR, exist_ok=True)

NUM_CUSTOMERS = 5000
NUM_ACCOUNTS = 7500
NUM_TRANSACTIONS = 100000

# Customers
states = [
    "Ohio",
    "Texas",
    "California",
    "New York",
    "Florida",
    "Illinois",
    "Georgia",
    "Virginia",
    "North Carolina",
    "Michigan"
]
genders = ["Male", "Female", "Other"]
segments = [
    "High Value",
    "Mass Affluent",
    "Standard",
    "Entry"
]
customers = []
start_date = datetime(2021, 1, 1)
for customer_id in range(1, NUM_CUSTOMERS + 1):
    join_date = start_date + timedelta(
        days=random.randint(0, 1800)
    )
    customers.append({
        "customer_id": customer_id,
        "customer_name": f"Customer {customer_id}",
        "age": random.randint(21, 75),
        "gender": random.choice(genders),
        "state": random.choice(states),
        "customer_segment": random.choice(segments),
        "join_date": join_date.date(),
        "annual_income": round(
            random.uniform(30000, 250000), 2
        )
    })
customers_df = pd.DataFrame(customers)

# Products
products = [
    [1, "Checking Account", "Deposit", 0.50],
    [2, "Savings Account", "Deposit", 3.25],
    [3, "Premium Savings", "Deposit", 4.10],
    [4, "Personal Loan", "Lending", 8.50],
    [5, "Auto Loan", "Lending", 7.25],
    [6, "Mortgage", "Lending", 6.75],
    [7, "Credit Card", "Credit", 18.99],
    [8, "Business Account", "Business", 1.50],
    [9, "Investment Account", "Investment", 5.25],
    [10, "Retirement Account", "Investment", 4.75]
]
products_df = pd.DataFrame(
    products,
    columns=[
        "product_id",
        "product_name",
        "product_category",
        "interest_rate"
    ]
)

# Accounts
account_types = [
    "Checking",
    "Savings",
    "Credit Card",
    "Investment"
]
account_statuses = [
    "Active",
    "Active",
    "Active",
    "Closed"
]
accounts = []
for account_id in range(1, NUM_ACCOUNTS + 1):
    customer_id = random.randint(
        1, NUM_CUSTOMERS
    )
    open_date = start_date + timedelta(
        days=random.randint(0, 1800)
    )
    accounts.append({
        "account_id": account_id,
        "customer_id": customer_id,
        "account_type": random.choice(account_types),
        "open_date": open_date.date(),
        "status": random.choice(account_statuses),
        "balance": round(
            random.uniform(500, 150000), 2
        )
    })
accounts_df = pd.DataFrame(accounts)

# Transactions
transaction_types = [
    "Purchase",
    "Deposit",
    "Withdrawal",
    "Transfer",
    "Payment"
]
merchant_categories = [
    "Grocery",
    "Travel",
    "Healthcare",
    "Dining",
    "Entertainment",
    "Utilities",
    "Retail",
    "Education",
    "Transportation"
]
channels = [
    "Online",
    "Mobile",
    "Branch",
    "ATM",
    "Phone"
]
statuses = [
    "Completed",
    "Completed",
    "Completed",
    "Completed",
    "Failed",
    "Pending"
]
transactions = []
transaction_start = datetime(2024, 1, 1)
for transaction_id in range(1, NUM_TRANSACTIONS + 1):
    account = accounts_df.sample(
        n=1
    ).iloc[0]
    transaction_date = transaction_start + timedelta(
        days=random.randint(0, 730)
    )
    transaction_type = random.choice(
        transaction_types
    )
    amount = round(
        np.random.lognormal(mean=4.0, sigma=1.0), 2)
    if random.random() < 0.01:
        amount = round(random.uniform(5000, 50000), 2)
    transactions.append({
        "transaction_id": transaction_id,
        "customer_id": int(account["customer_id"]),
        "account_id": int(account["account_id"]),
        "transaction_date": transaction_date.date(),
        "transaction_type": transaction_type,
        "amount": amount,
        "merchant_category": random.choice(
            merchant_categories
        ),
        "channel": random.choice(channels),
        "status": random.choice(statuses)
    })
transactions_df = pd.DataFrame(transactions)

# Save datasets
customers_df.to_csv(
    os.path.join(
        RAW_DATA_DIR,
        "customers.csv"
    ),
    index=False
)
products_df.to_csv(
    os.path.join(
        RAW_DATA_DIR,
        "products.csv"
    ),
    index=False
)
accounts_df.to_csv(
    os.path.join(
        RAW_DATA_DIR,
        "accounts.csv"
    ),
    index=False
)
transactions_df.to_csv(
    os.path.join(
        RAW_DATA_DIR,
        "transactions.csv"
    ),
    index=False
)
print("Data generation completed.")
print(f"Customers: {len(customers_df):,}")
print(f"Accounts: {len(accounts_df):,}")
print(f"Transactions: {len(transactions_df):,}")
print(f"Products: {len(products_df):,}")