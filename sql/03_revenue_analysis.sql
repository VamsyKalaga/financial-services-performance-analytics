-- ============================================================
-- Financial Services Performance Analytics Platform
-- File: 03_revenue_analysis.sql
-- Purpose: Analyze revenue and financial performance trends
-- ============================================================

-- Monthly revenue
SELECT
    DATE_TRUNC('month', transaction_date) AS month,
    ROUND(SUM(amount), 2) AS revenue
FROM transactions
WHERE status = 'Completed'
GROUP BY 1
ORDER BY 1;

-- Revenue by state
SELECT
    c.state,
    ROUND(SUM(t.amount), 2) AS revenue,
    COUNT(t.transaction_id) AS transaction_count,
    COUNT(DISTINCT c.customer_id) AS active_customers
FROM customers c
JOIN transactions t
    ON c.customer_id = t.customer_id
WHERE t.status = 'Completed'
GROUP BY c.state
ORDER BY revenue DESC;

-- Revenue by customer segment
SELECT
    c.customer_segment,
    ROUND(SUM(t.amount), 2) AS revenue,
    COUNT(t.transaction_id) AS transaction_count,
    COUNT(DISTINCT c.customer_id) AS active_customers
FROM customers c
JOIN transactions t
    ON c.customer_id = t.customer_id
WHERE t.status = 'Completed'
GROUP BY c.customer_segment
ORDER BY revenue DESC;

-- Revenue by channel
SELECT
    t.channel,
    ROUND(SUM(t.amount), 2) AS revenue,
    COUNT(t.transaction_id) AS transaction_count,
    ROUND(AVG(t.amount), 2) AS average_transaction_value
FROM transactions t
WHERE t.status = 'Completed'
GROUP BY t.channel
ORDER BY revenue DESC;

-- Revenue by merchant category
SELECT
    merchant_category,
    ROUND(SUM(amount), 2) AS revenue,
    COUNT(*) AS transaction_count,
    ROUND(AVG(amount), 2) AS average_transaction_value
FROM transactions
WHERE status = 'Completed'
GROUP BY merchant_category
ORDER BY revenue DESC;