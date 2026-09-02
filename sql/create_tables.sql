DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(100),
    age INTEGER,
    gender VARCHAR(20),
    state VARCHAR(50),
    customer_segment VARCHAR(50),
    join_date DATE,
    annual_income NUMERIC(12,2)
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    interest_rate NUMERIC(5,2)
);

CREATE TABLE accounts (
    account_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    account_type VARCHAR(50),
    open_date DATE,
    status VARCHAR(30),
    balance NUMERIC(14,2)
);

CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    account_id INTEGER REFERENCES accounts(account_id),
    transaction_date DATE,
    transaction_type VARCHAR(50),
    amount NUMERIC(14,2),
    merchant_category VARCHAR(100),
    channel VARCHAR(50),
    status VARCHAR(30)
);