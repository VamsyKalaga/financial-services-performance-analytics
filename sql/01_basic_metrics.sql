-- ============================================================
-- Financial Services Performance Analytics Platform
-- File: 01_basic_metrics.sql
-- Purpose: Calculate core business performance metrics
-- ============================================================

-- Total number of transactions
SELECT COUNT(*) AS total_transactions
FROM transactions;
-- Total transaction amount
SELECT SUM(amount) AS total_transaction_amount
FROM transactions;
-- Average transaction value
SELECT AVG(amount) AS average_transaction_value
FROM transactions;
-- Minimum and maximum transaction
SELECT MIN(amount) AS minimum_transaction, MAX(amount) AS maximum_transaction
FROM transactions;
-- Transaction status
SELECT status, COUNT(*) AS transaction_count FROM transactions
GROUP BY status ORDER BY transaction_count DESC;

-- Calculate transaction success rate
SELECT
    ROUND(100.0 * SUM(CASE
                        WHEN status = 'Completed' THEN 1
                        ELSE 0
                    END
        ) / COUNT(*),
        2
    ) AS transaction_success_rate
FROM transactions;

-- Calculate failed transaction rate
SELECT
    ROUND(100.0 * SUM(
            CASE
                WHEN status = 'Failed' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS failed_transaction_rate
FROM transactions;

-- Revenue by transaction type
SELECT
    transaction_type,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS average_amount,
    MIN(amount) AS minimum_amount,
    MAX(amount) AS maximum_amount
FROM transactions
GROUP BY transaction_type
ORDER BY total_amount DESC;

-- Revenue by channel
SELECT
    channel,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS average_transaction_value
FROM transactions
GROUP BY channel
ORDER BY total_amount DESC;

-- Revenue by merchant category
SELECT
    merchant_category,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS average_transaction_value
FROM transactions
GROUP BY merchant_category
ORDER BY total_amount DESC;

-- Monthly transaction performance
SELECT
    DATE_TRUNC('month', transaction_date)::date AS month,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount,
    ROUND(AVG(amount), 2) AS average_transaction_value
FROM transactions
GROUP BY 1
ORDER BY 1;