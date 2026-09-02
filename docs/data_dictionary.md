# Data Dictionary

## Customers

| Column | Description | Data Type |
|---|---|---|
| customer_id | Unique customer identifier | Integer |
| customer_name | Customer name | String |
| age | Customer age | Integer |
| gender | Customer gender | String |
| state | Customer state | String |
| customer_segment | Customer value segment | String |
| join_date | Customer onboarding date | Date |
| annual_income | Estimated annual income | Numeric |

## Accounts

| Column | Description | Data Type |
|---|---|---|
| account_id | Unique account identifier | Integer |
| customer_id | Customer associated with account | Integer |
| account_type | Type of financial account | String |
| open_date | Account opening date | Date |
| status | Account status | String |
| balance | Current account balance | Numeric |

## Transactions

| Column | Description | Data Type |
|---|---|---|
| transaction_id | Unique transaction identifier | Integer |
| customer_id | Customer associated with transaction | Integer |
| account_id | Account associated with transaction | Integer |
| transaction_date | Date of transaction | Date |
| transaction_type | Type of transaction | String |
| amount | Transaction amount | Numeric |
| merchant_category | Merchant category | String |
| channel | Transaction channel | String |
| status | Transaction status | String |

## Products

| Column | Description | Data Type |
|---|---|---|
| product_id | Unique product identifier | Integer |
| product_name | Financial product name | String |
| product_category | Product category | String |
| interest_rate | Product interest rate | Numeric |