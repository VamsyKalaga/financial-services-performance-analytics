-- ============================================================
-- Financial Services Performance Analytics Platform
-- File: 04_transaction_analysis.sql
-- Purpose: Analyze transaction behavior and operational performance
-- ============================================================

-- Transaction volume by day
SELECT
    transaction_date,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS transaction_amount
FROM transactions
GROUP BY transaction_date
ORDER BY transaction_date;

-- Transaction volume by channel and status
SELECT channel, status, COUNT(*) AS transaction_count
FROM transactions
GROUP BY channel, status
ORDER BY channel, transaction_count DESC;

-- Failed transactions by channel
SELECT channel, COUNT(*) AS failed_transactions,
    ROUND(SUM(amount), 2) AS failed_transaction_amount
FROM transactions
WHERE status = 'Failed'
GROUP BY channel
ORDER BY failed_transactions DESC;

-- Large transactions
SELECT transaction_id, customer_id, account_id,
    transaction_date, transaction_type, amount, channel, status
FROM transactions
WHERE amount >= 10000
ORDER BY amount DESC;

-- Daily transaction performance
SELECT transaction_date,  COUNT(*) AS total_transactions,
    COUNT(*) FILTER (
        WHERE status = 'Completed'
    ) AS completed_transactions,
    COUNT(*) FILTER (
        WHERE status = 'Failed'
    ) AS failed_transactions,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY transaction_date
ORDER BY transaction_date;