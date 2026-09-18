-- ============================================
-- TREND ANALYSIS
-- ============================================

-- Monthly performance
SELECT
    DATE_TRUNC('month', transaction_date) AS month,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_transaction_value,
    ROUND(AVG(amount), 2) AS average_transaction_value,
    COUNT(DISTINCT customer_id) AS active_customers
FROM transactions
WHERE status = 'Completed'
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY month;

-- Create a monthly performance CTE
WITH monthly_performance AS (
    SELECT
        DATE_TRUNC('month', transaction_date) AS month,
        COUNT(transaction_id) AS total_transactions,
        ROUND(SUM(amount), 2) AS total_transaction_value,
        ROUND(AVG(amount), 2) AS average_transaction_value,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM transactions
    WHERE status = 'Completed'
    GROUP BY DATE_TRUNC('month', transaction_date)
)

SELECT *
FROM monthly_performance
ORDER BY month;

-- Calculate Month-over-Month growth
WITH monthly_performance AS (
    SELECT
        DATE_TRUNC('month', transaction_date) AS month,
        COUNT(transaction_id) AS total_transactions,
        SUM(amount) AS total_transaction_value,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM transactions
    WHERE status = 'Completed'
    GROUP BY DATE_TRUNC('month', transaction_date)
),

monthly_growth AS (
    SELECT
        month,
        total_transactions,
        total_transaction_value,
        active_customers,

        LAG(total_transaction_value)
            OVER (ORDER BY month) AS previous_month_value

    FROM monthly_performance
)

SELECT
    month,
    total_transactions,
    ROUND(total_transaction_value, 2) AS total_transaction_value,
    active_customers,
    ROUND(previous_month_value, 2) AS previous_month_value,

    ROUND(
        100.0 *
        (total_transaction_value - previous_month_value)
        / NULLIF(previous_month_value, 0),
        2
    ) AS mom_growth_percent

FROM monthly_growth
ORDER BY month;

-- Calculate YoY growth
WITH monthly_performance AS (
    SELECT
        DATE_TRUNC('month', transaction_date) AS month,
        COUNT(transaction_id) AS total_transactions,
        SUM(amount) AS total_transaction_value,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM transactions
    WHERE status = 'Completed'
    GROUP BY DATE_TRUNC('month', transaction_date)
),

year_over_year AS (
    SELECT
        month,
        total_transactions,
        total_transaction_value,
        active_customers,

        LAG(total_transaction_value, 12)
            OVER (ORDER BY month) AS previous_year_value

    FROM monthly_performance
)

SELECT
    month,
    total_transactions,
    ROUND(total_transaction_value, 2) AS total_transaction_value,
    active_customers,
    ROUND(previous_year_value, 2) AS previous_year_value,

    ROUND(
        100.0 *
        (total_transaction_value - previous_year_value)
        / NULLIF(previous_year_value, 0),
        2
    ) AS yoy_growth_percent

FROM year_over_year
ORDER BY month;

-- Calculate 3-month rolling transaction value
WITH monthly_performance AS (
    SELECT
        DATE_TRUNC('month', transaction_date) AS month,
        SUM(amount) AS total_transaction_value
    FROM transactions
    WHERE status = 'Completed'
    GROUP BY DATE_TRUNC('month', transaction_date)
)

SELECT
    month,
    ROUND(total_transaction_value, 2) AS total_transaction_value,

    ROUND(
        AVG(total_transaction_value)
        OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_3_month_average

FROM monthly_performance
ORDER BY month;

-- Build the final monthly performance view
DROP VIEW IF EXISTS monthly_performance;

CREATE VIEW monthly_performance AS

WITH monthly_data AS (
    SELECT
        DATE_TRUNC('month', transaction_date) AS month,
        COUNT(transaction_id) AS total_transactions,
        SUM(amount) AS total_transaction_value,
        AVG(amount) AS average_transaction_value,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM transactions
    WHERE status = 'Completed'
    GROUP BY DATE_TRUNC('month', transaction_date)
),

trend_data AS (
    SELECT
        month,
        total_transactions,
        total_transaction_value,
        average_transaction_value,
        active_customers,

        LAG(total_transaction_value)
            OVER (ORDER BY month) AS previous_month_value,

        LAG(total_transaction_value, 12)
            OVER (ORDER BY month) AS previous_year_value,

        AVG(total_transaction_value)
            OVER (
                ORDER BY month
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ) AS rolling_3_month_average

    FROM monthly_data
)

SELECT
    month,
    total_transactions,

    ROUND(total_transaction_value, 2)
        AS total_transaction_value,

    ROUND(average_transaction_value, 2)
        AS average_transaction_value,

    active_customers,

    ROUND(previous_month_value, 2)
        AS previous_month_value,

    ROUND(previous_year_value, 2)
        AS previous_year_value,

    ROUND(rolling_3_month_average, 2)
        AS rolling_3_month_average,

    ROUND(
        100.0 *
        (total_transaction_value - previous_month_value)
        / NULLIF(previous_month_value, 0),
        2
    ) AS mom_growth_percent,

    ROUND(
        100.0 *
        (total_transaction_value - previous_year_value)
        / NULLIF(previous_year_value, 0),
        2
    ) AS yoy_growth_percent

FROM trend_data
ORDER BY month;

-- strongest and weakest months
SELECT
    month,
    total_transaction_value as Highest_transaction_value_months
FROM monthly_performance
ORDER BY total_transaction_value DESC
LIMIT 5;

SELECT
    month,
    total_transaction_value as Lowest_transaction_value_months
FROM monthly_performance
ORDER BY total_transaction_value
LIMIT 5;

SELECT
    month,
    mom_growth_percent as Highest_mom_growth_percent_months
FROM monthly_performance
WHERE mom_growth_percent IS NOT NULL
ORDER BY mom_growth_percent DESC
LIMIT 5;

SELECT
    month,
    mom_growth_percent as Lowest_mom_growth_percent_months
FROM monthly_performance
WHERE mom_growth_percent IS NOT NULL
ORDER BY mom_growth_percent
LIMIT 5;