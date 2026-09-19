
-- 1. Overall Executive KPIs
SELECT
    COUNT(DISTINCT t.transaction_id) AS total_transactions,
    COUNT(DISTINCT t.customer_id) AS active_customers,
    COUNT(DISTINCT t.account_id) AS active_accounts,
    SUM(t.amount) AS total_transaction_value,
    AVG(t.amount) AS average_transaction_value,
    MIN(t.transaction_date) AS first_transaction_date,
    MAX(t.transaction_date) AS last_transaction_date
FROM transactions t
WHERE t.status = 'Completed';

-- 2. Customer KPIs
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE customer_segment = 'High Value'
    ) AS high_value_customers,
    COUNT(*) FILTER (
        WHERE customer_segment = 'Medium Value'
    ) AS medium_value_customers,
    COUNT(*) FILTER (
        WHERE customer_segment = 'Low Value'
    ) AS low_value_customers
FROM customers;

-- 3. Account KPIs
SELECT
    COUNT(*) AS total_accounts,
    COUNT(*) FILTER (
        WHERE status = 'Active'
    ) AS active_accounts,
    COUNT(*) FILTER (
        WHERE status = 'Inactive'
    ) AS inactive_accounts,
    SUM(balance) AS total_account_balance,
    AVG(balance) AS average_account_balance
FROM accounts;

-- 4. Transaction Performance by Month
SELECT
    DATE_TRUNC('month', transaction_date)::date AS month,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS active_customers,
    SUM(amount) AS total_transaction_value,
    AVG(amount) AS average_transaction_value
FROM transactions
WHERE status = 'Completed'
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY month;

-- 5. Transaction Performance by Channel
SELECT
    channel,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS active_customers,
    SUM(amount) AS total_transaction_value,
    AVG(amount) AS average_transaction_value
FROM transactions
WHERE status = 'Completed'
GROUP BY channel
ORDER BY total_transaction_value DESC;

-- 6. Transaction Performance by Transaction Type
SELECT
    transaction_type,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS active_customers,
    SUM(amount) AS total_transaction_value,
    AVG(amount) AS average_transaction_value
FROM transactions
WHERE status = 'Completed'
GROUP BY transaction_type
ORDER BY total_transaction_value DESC;

-- 7. Transaction Performance by Merchant Category
SELECT
    merchant_category,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS active_customers,
    SUM(amount) AS total_transaction_value,
    AVG(amount) AS average_transaction_value
FROM transactions
WHERE status = 'Completed'
GROUP BY merchant_category
ORDER BY total_transaction_value DESC;

-- 8. Potential Anomaly KPI
WITH transaction_stats AS (
    SELECT
        percentile_cont(0.25)
            WITHIN GROUP (ORDER BY amount) AS q1,
        percentile_cont(0.75)
            WITHIN GROUP (ORDER BY amount) AS q3
    FROM transactions
    WHERE status = 'Completed'
),

bounds AS (
    SELECT
        q1,
        q3,
        q1 - 1.5 * (q3 - q1) AS lower_bound,
        q3 + 1.5 * (q3 - q1) AS upper_bound
    FROM transaction_stats
)

SELECT
    COUNT(*) AS total_completed_transactions,
    COUNT(*) FILTER (
        WHERE t.amount > b.upper_bound
           OR t.amount < b.lower_bound
    ) AS potential_anomalies,
    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE t.amount > b.upper_bound
               OR t.amount < b.lower_bound
        )
        / COUNT(*),
        2
    ) AS potential_anomaly_rate_percent
FROM transactions t
CROSS JOIN bounds b
WHERE t.status = 'Completed';

-- 9. Executive KPI Summary View
CREATE OR REPLACE VIEW executive_dashboard_kpis AS

WITH completed_transactions AS (
    SELECT *
    FROM transactions
    WHERE status = 'Completed'
),

transaction_stats AS (
    SELECT
        percentile_cont(0.25)
            WITHIN GROUP (ORDER BY amount) AS q1,
        percentile_cont(0.75)
            WITHIN GROUP (ORDER BY amount) AS q3
    FROM completed_transactions
),

bounds AS (
    SELECT
        q1,
        q3,
        q1 - 1.5 * (q3 - q1) AS lower_bound,
        q3 + 1.5 * (q3 - q1) AS upper_bound
    FROM transaction_stats
),

transaction_kpis AS (
    SELECT
        COUNT(*) AS total_transactions,
        COUNT(DISTINCT customer_id) AS active_customers,
        COUNT(DISTINCT account_id) AS active_accounts,
        SUM(amount) AS total_transaction_value,
        AVG(amount) AS average_transaction_value
    FROM completed_transactions
),

anomaly_kpis AS (
    SELECT
        COUNT(*) FILTER (
            WHERE t.amount > b.upper_bound
               OR t.amount < b.lower_bound
        ) AS potential_anomalies
    FROM completed_transactions t
    CROSS JOIN bounds b
)

SELECT
    tk.total_transactions,
    tk.active_customers,
    tk.active_accounts,
    tk.total_transaction_value,
    tk.average_transaction_value,
    ak.potential_anomalies,
    ROUND(
        100.0 * ak.potential_anomalies
        / NULLIF(tk.total_transactions, 0),
        2
    ) AS potential_anomaly_rate_percent
FROM transaction_kpis tk
CROSS JOIN anomaly_kpis ak;