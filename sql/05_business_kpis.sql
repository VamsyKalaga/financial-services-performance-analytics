-- ============================================================
-- Purpose: Calculate core business KPIs
-- ============================================================
-- Total Customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Total Accounts
SELECT COUNT(*) AS total_accounts
FROM accounts;

-- Active Accounts
SELECT
    COUNT(*) AS active_accounts
FROM accounts
WHERE status = 'Active';

-- Total Transactions
SELECT COUNT(*) AS total_transactions
FROM transactions;

-- Completed Transactions
SELECT
    COUNT(*) AS completed_transactions
FROM transactions
WHERE status = 'Completed';

-- Failed Transactions
SELECT
    COUNT(*) AS failed_transactions
FROM transactions
WHERE status = 'Failed';

-- Pending Transactions
SELECT
    COUNT(*) AS pending_transactions
FROM transactions
WHERE status = 'Pending';

-- Total Transaction Amount
SELECT
    ROUND(SUM(amount), 2) AS total_revenue
FROM transactions
WHERE status = 'Completed';

-- Average Transaction Value
SELECT
    ROUND(AVG(amount), 2) AS average_transaction_value
FROM transactions
WHERE status = 'Completed';

-- Transaction Success Rate
SELECT
    ROUND(100.0 *
        SUM(
            CASE
                WHEN status = 'Completed' THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS transaction_success_rate
FROM transactions;

-- Transaction Failure Rate
SELECT
    ROUND(100.0 *
        SUM(
            CASE
                WHEN status = 'Failed' THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS transaction_failure_rate
FROM transactions;

-- Active Customers
SELECT
    COUNT(DISTINCT customer_id) AS active_customers
FROM transactions
WHERE status = 'Completed';

-- Customer Activity Rate
SELECT
    ROUND(
        100.0 *
        COUNT(DISTINCT t.customer_id)
        / COUNT(c.customer_id),
        2
    ) AS customer_activity_rate
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
    AND t.status = 'Completed';

-- Transactions per Active Customer
SELECT
    ROUND(
        COUNT(*)::NUMERIC
        / COUNT(DISTINCT customer_id),
        2
    ) AS transactions_per_active_customer
FROM transactions
WHERE status = 'Completed';

-- Revenue per Active Customer
SELECT
    ROUND(
        SUM(amount)
        / COUNT(DISTINCT customer_id),
        2
    ) AS revenue_per_active_customer
FROM transactions
WHERE status = 'Completed';

-- Revenue by Customer Segment
SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS active_customers,
    COUNT(t.transaction_id) AS transactions,
    ROUND(SUM(t.amount), 2) AS revenue,
    ROUND(AVG(t.amount), 2) AS average_transaction_value
FROM customers c
JOIN transactions t
    ON c.customer_id = t.customer_id
WHERE t.status = 'Completed'
GROUP BY c.customer_segment
ORDER BY revenue DESC;

-- Revenue by State
SELECT
    c.state,
    COUNT(DISTINCT c.customer_id) AS active_customers,
    COUNT(t.transaction_id) AS transactions,
    ROUND(SUM(t.amount), 2) AS revenue
FROM customers c
JOIN transactions t
    ON c.customer_id = t.customer_id
WHERE t.status = 'Completed'
GROUP BY c.state
ORDER BY revenue DESC;

-- Revenue by Channel
SELECT
    channel,
    COUNT(*) AS transactions,
    ROUND(SUM(amount), 2) AS revenue,
    ROUND(AVG(amount), 2) AS average_transaction_value
FROM transactions
WHERE status = 'Completed'
GROUP BY channel
ORDER BY revenue DESC;

-- Revenue by Transaction Type
SELECT
    transaction_type,
    COUNT(*) AS transactions,
    ROUND(SUM(amount), 2) AS revenue,
    ROUND(AVG(amount), 2) AS average_transaction_value
FROM transactions
WHERE status = 'Completed'
GROUP BY transaction_type
ORDER BY revenue DESC;

-- Revenue by Merchant Category
SELECT
    merchant_category,
    COUNT(*) AS transactions,
    ROUND(SUM(amount), 2) AS revenue,
    ROUND(AVG(amount), 2) AS average_transaction_value
FROM transactions
WHERE status = 'Completed'
GROUP BY merchant_category
ORDER BY revenue DESC;

-- Monthly KPI analysis
SELECT
    DATE_TRUNC('month', transaction_date) AS month,
    COUNT(*) AS transactions,
    COUNT(DISTINCT customer_id) AS active_customers,
    ROUND(SUM(amount), 2) AS revenue,
    ROUND(AVG(amount), 2) AS average_transaction_value
FROM transactions
WHERE status = 'Completed'
GROUP BY 1
ORDER BY 1;

-- Month-over-Month Revenue Growth
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', transaction_date) AS month,
        SUM(amount) AS revenue
    FROM transactions
    WHERE status = 'Completed'
    GROUP BY 1
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        LAG(revenue) OVER (
            ORDER BY month
        ),
        2
    ) AS previous_month_revenue,
    ROUND(
        100.0 *
        (
            revenue -
            LAG(revenue) OVER (
                ORDER BY month
            )
        )
        /
        NULLIF(
            LAG(revenue) OVER (
                ORDER BY month
            ),
            0
        ),
        2
    ) AS mom_growth_percent
FROM monthly_revenue
ORDER BY month;


-- KPI summary query
SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,

    (
        SELECT COUNT(DISTINCT customer_id)
        FROM transactions
        WHERE status = 'Completed'
    ) AS active_customers,

    (
        SELECT COUNT(*)
        FROM accounts
    ) AS total_accounts,

    (
        SELECT COUNT(*)
        FROM accounts
        WHERE status = 'Active'
    ) AS active_accounts,

    (
        SELECT COUNT(*)
        FROM transactions
    ) AS total_transactions,

    (
        SELECT COUNT(*)
        FROM transactions
        WHERE status = 'Completed'
    ) AS completed_transactions,

    (
        SELECT COUNT(*)
        FROM transactions
        WHERE status = 'Failed'
    ) AS failed_transactions,

    (
        SELECT ROUND(SUM(amount), 2)
        FROM transactions
        WHERE status = 'Completed'
    ) AS total_revenue,

    (
        SELECT ROUND(AVG(amount), 2)
        FROM transactions
        WHERE status = 'Completed'
    ) AS average_transaction_value;