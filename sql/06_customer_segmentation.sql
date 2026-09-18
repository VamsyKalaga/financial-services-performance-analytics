-- ============================================================
-- Purpose: Analyze customer behavior and financial value
-- ============================================================

-- Build customer transaction summary
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.state,
    c.age,
    c.annual_income,

    COUNT(t.transaction_id) AS total_transactions,

    ROUND(
        COALESCE(SUM(t.amount), 0),
        2
    ) AS total_transaction_amount,

    ROUND(
        COALESCE(AVG(t.amount), 0),
        2
    ) AS average_transaction_value,

    MIN(t.transaction_date) AS first_transaction_date,

    MAX(t.transaction_date) AS last_transaction_date

FROM customers c

LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
    AND t.status = 'Completed'

GROUP BY
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.state,
    c.age,
    c.annual_income

ORDER BY total_transaction_amount DESC;

-- customer analytics view
DROP VIEW IF EXISTS customer_transaction_summary;

CREATE VIEW customer_transaction_summary AS

SELECT
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.state,
    c.age,
    c.annual_income,

    COUNT(t.transaction_id) AS total_transactions,

    ROUND(
        COALESCE(SUM(t.amount), 0),
        2
    ) AS total_transaction_amount,

    ROUND(
        COALESCE(AVG(t.amount), 0),
        2
    ) AS average_transaction_value,

    MIN(t.transaction_date) AS first_transaction_date,

    MAX(t.transaction_date) AS last_transaction_date

FROM customers c

LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
    AND t.status = 'Completed'

GROUP BY
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.state,
    c.age,
    c.annual_income;

-- inactive customers
SELECT
    COUNT(*) AS inactive_customers
FROM customer_transaction_summary
WHERE total_transactions = 0;

-- highly active customers
SELECT
    customer_id,
    customer_name,
    customer_segment,
    total_transactions,
    total_transaction_amount
FROM customer_transaction_summary
WHERE total_transactions > 20
ORDER BY total_transactions DESC;

-- Analyze customer value
SELECT
    customer_segment,

    COUNT(*) AS customers,

    ROUND(
        AVG(total_transaction_amount),
        2
    ) AS avg_customer_value,

    ROUND(
        AVG(total_transactions),
        2
    ) AS avg_transactions,

    ROUND(
        AVG(average_transaction_value),
        2
    ) AS avg_transaction_value

FROM customer_transaction_summary

GROUP BY customer_segment

ORDER BY avg_customer_value DESC;

-- Customer revenue contribution
WITH segment_revenue AS (

    SELECT
        customer_segment,
        SUM(total_transaction_amount) AS revenue

    FROM customer_transaction_summary

    GROUP BY customer_segment
)

SELECT
    customer_segment,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        100.0 * revenue / SUM(revenue) OVER (),
        2
    ) AS revenue_contribution_percent

FROM segment_revenue

ORDER BY revenue DESC;

-- Income vs transaction activity
SELECT
    customer_segment,

    ROUND(
        AVG(annual_income),
        2
    ) AS average_income,

    ROUND(
        AVG(total_transaction_amount),
        2
    ) AS average_transaction_amount,

    ROUND(
        AVG(total_transactions),
        2
    ) AS average_transactions

FROM customer_transaction_summary

GROUP BY customer_segment

ORDER BY average_income DESC;

-- Customer activity buckets
SELECT
    customer_id,
    customer_name,
    total_transactions,
    total_transaction_amount,

    CASE
        WHEN total_transactions = 0
            THEN 'Inactive'

        WHEN total_transactions BETWEEN 1 AND 5
            THEN 'Low Activity'

        WHEN total_transactions BETWEEN 6 AND 15
            THEN 'Medium Activity'

        WHEN total_transactions > 15
            THEN 'High Activity'

        ELSE 'Unknown'
    END AS activity_segment

FROM customer_transaction_summary
ORDER BY total_transactions DESC;

-- Create an activity segmentation view
DROP VIEW IF EXISTS customer_activity_segments;

CREATE VIEW customer_activity_segments AS

SELECT
    customer_id,
    customer_name,
    customer_segment,
    state,
    age,
    annual_income,
    total_transactions,
    total_transaction_amount,
    average_transaction_value,
    first_transaction_date,
    last_transaction_date,

    CASE
        WHEN total_transactions = 0
            THEN 'Inactive'

        WHEN total_transactions BETWEEN 1 AND 5
            THEN 'Low Activity'

        WHEN total_transactions BETWEEN 6 AND 15
            THEN 'Medium Activity'

        WHEN total_transactions > 15
            THEN 'High Activity'

        ELSE 'Unknown'
    END AS activity_segment

FROM customer_transaction_summary;

-- Analyze activity segments
SELECT
    activity_segment,
    COUNT(*) AS customers,
    ROUND(
        AVG(total_transaction_amount),
        2
    ) AS average_customer_value,
    ROUND(
        AVG(total_transactions),
        2
    ) AS average_transactions
FROM customer_activity_segments
GROUP BY activity_segment
ORDER BY average_customer_value DESC;

