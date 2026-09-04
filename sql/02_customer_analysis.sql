-- ============================================================
-- Financial Services Performance Analytics Platform
-- File: 02_customer_analysis.sql
-- Purpose: Analyze customer activity and value
-- ============================================================

-- Customer count
SELECT COUNT(*) AS total_customers
FROM customers;

-- Customers by state
SELECT state, COUNT(*) AS customer_count
FROM customers GROUP BY state ORDER BY customer_count DESC;

-- Customers by segment
SELECT customer_segment, COUNT(*) AS customer_count
FROM customers GROUP BY customer_segment ORDER BY customer_count DESC;

-- Average income by segment
SELECT customer_segment, COUNT(*) AS customer_count, ROUND(AVG(annual_income), 2) AS average_income
FROM customers GROUP BY customer_segment ORDER BY average_income DESC;

-- Customer transaction activity
-- SELECT c.customer_id, c.customer_segment, COUNT(t.transaction_id) AS transaction_count, SUM(t.amount) AS total_transaction_amount FROM customers c LEFT JOIN transactions t ON c.customer_id = t.customer_id
-- GROUP BY
--     c.customer_id,
--     c.customer_segment
-- ORDER BY total_transaction_amount DESC NULLS LAST;

SELECT c.customer_id, c.customer_segment, COUNT(t.transaction_id) AS transaction_count, SUM(t.amount) AS total_transaction_amount
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.customer_segment
ORDER BY total_transaction_amount DESC NULLS LAST
LIMIT 15;

-- Top 20 customers
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    COUNT(t.transaction_id) AS transaction_count,
    ROUND(SUM(t.amount), 2) AS total_transaction_amount
FROM customers c
JOIN transactions t
    ON c.customer_id = t.customer_id
WHERE t.status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name,
    c.customer_segment
ORDER BY total_transaction_amount DESC
LIMIT 20;

-- Customer analysis by segment
SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(t.transaction_id) AS transactions,
    ROUND(SUM(t.amount), 2) AS total_amount,
    ROUND(AVG(t.amount), 2) AS average_transaction,
    ROUND(MIN(t.amount), 2) AS min_transaction,
    ROUND(MAX(t.amount), 2) AS max_transaction
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
GROUP BY c.customer_segment
ORDER BY total_amount DESC;