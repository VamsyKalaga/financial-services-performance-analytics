-- 1. Monthly Actual Performance
WITH monthly_actuals AS (

    SELECT
        DATE_TRUNC('month', transaction_date)::date AS month,

        COUNT(*) FILTER (
            WHERE status = 'Completed'
        ) AS actual_transactions,

        SUM(amount) FILTER (
            WHERE status = 'Completed'
        ) AS actual_transaction_value,

        COUNT(DISTINCT customer_id) FILTER (
            WHERE status = 'Completed'
        ) AS actual_active_customers

    FROM transactions

    GROUP BY DATE_TRUNC('month', transaction_date)

),

-- 2. Calculate Historical Baseline

variance_base AS (

    SELECT
        month,

        actual_transactions,
        actual_transaction_value,
        actual_active_customers,

        AVG(actual_transaction_value) OVER (
            ORDER BY month
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) AS expected_transaction_value,

        AVG(actual_transactions) OVER (
            ORDER BY month
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) AS expected_transactions,

        AVG(actual_active_customers) OVER (
            ORDER BY month
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) AS expected_active_customers

    FROM monthly_actuals

)

-- 3. Calculate Variances

SELECT
    month,

    actual_transaction_value,
    expected_transaction_value,

    actual_transaction_value
        - expected_transaction_value
        AS transaction_value_variance,

    ROUND(
        (
            (
                actual_transaction_value
                - expected_transaction_value
            )
            / NULLIF(expected_transaction_value, 0)
        ) * 100,
        2
    ) AS transaction_value_variance_percent,

    actual_transactions,
    expected_transactions,

    actual_transactions
        - expected_transactions
        AS transaction_count_variance,

    ROUND(
        (
            (
                actual_transactions
                - expected_transactions
            )
            / NULLIF(expected_transactions, 0)
        ) * 100,
        2
    ) AS transaction_count_variance_percent,

    actual_active_customers,
    expected_active_customers,

    actual_active_customers
        - expected_active_customers
        AS customer_variance,

    ROUND(
        (
            (
                actual_active_customers
                - expected_active_customers
            )
            / NULLIF(expected_active_customers, 0)
        ) * 100,
        2
    ) AS customer_variance_percent,

    CASE
        WHEN expected_transaction_value IS NULL
            THEN 'Insufficient History'

        WHEN actual_transaction_value
             > expected_transaction_value
            THEN 'Above Baseline'

        WHEN actual_transaction_value
             < expected_transaction_value
            THEN 'Below Baseline'

        ELSE 'At Baseline'
    END AS performance_status

FROM variance_base

ORDER BY month;

-- 4. cleaner validation query
WITH monthly_actuals AS (

    SELECT
        DATE_TRUNC('month', transaction_date)::date AS month,

        COUNT(*) FILTER (
            WHERE status = 'Completed'
        ) AS actual_transactions,

        SUM(amount) FILTER (
            WHERE status = 'Completed'
        ) AS actual_transaction_value,

        COUNT(DISTINCT customer_id) FILTER (
            WHERE status = 'Completed'
        ) AS actual_active_customers

    FROM transactions

    GROUP BY DATE_TRUNC('month', transaction_date)

),

variance_base AS (

    SELECT
        month,
        actual_transactions,
        actual_transaction_value,
        actual_active_customers,

        AVG(actual_transaction_value) OVER (
            ORDER BY month
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) AS expected_transaction_value

    FROM monthly_actuals

)

SELECT
    month,
    ROUND(actual_transaction_value, 2) AS actual_value,
    ROUND(expected_transaction_value, 2) AS expected_value,
    ROUND(
        actual_transaction_value - expected_transaction_value,
        2
    ) AS variance,

    ROUND(
        (
            (actual_transaction_value - expected_transaction_value)
            / NULLIF(expected_transaction_value, 0)
        ) * 100,
        2
    ) AS variance_percent

FROM variance_base

WHERE expected_transaction_value IS NOT NULL

ORDER BY month;

-- 5. Identify the biggest positive variances
WITH monthly_actuals AS (

    SELECT
        DATE_TRUNC('month', transaction_date)::date AS month,
        SUM(amount) FILTER (
            WHERE status = 'Completed'
        ) AS actual_transaction_value

    FROM transactions

    GROUP BY DATE_TRUNC('month', transaction_date)

),

variance_base AS (

    SELECT
        month,
        actual_transaction_value,

        AVG(actual_transaction_value) OVER (
            ORDER BY month
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) AS expected_transaction_value

    FROM monthly_actuals

)

SELECT
    month,
    ROUND(actual_transaction_value, 2) AS actual_value,
    ROUND(expected_transaction_value, 2) AS expected_value,

    ROUND(
        actual_transaction_value - expected_transaction_value,
        2
    ) AS variance,

    ROUND(
        (
            (actual_transaction_value - expected_transaction_value)
            / NULLIF(expected_transaction_value, 0)
        ) * 100,
        2
    ) AS variance_percent

FROM variance_base

WHERE expected_transaction_value IS NOT NULL

ORDER BY variance_percent DESC

LIMIT 5;

-- 6. Identify the biggest negative variances
WITH monthly_actuals AS (

    SELECT
        DATE_TRUNC('month', transaction_date)::date AS month,
        SUM(amount) FILTER (
            WHERE status = 'Completed'
        ) AS actual_transaction_value

    FROM transactions

    GROUP BY DATE_TRUNC('month', transaction_date)

),

variance_base AS (

    SELECT
        month,
        actual_transaction_value,

        AVG(actual_transaction_value) OVER (
            ORDER BY month
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) AS expected_transaction_value

    FROM monthly_actuals

)

SELECT
    month,
    ROUND(actual_transaction_value, 2) AS actual_value,
    ROUND(expected_transaction_value, 2) AS expected_value,

    ROUND(
        actual_transaction_value - expected_transaction_value,
        2
    ) AS variance,

    ROUND(
        (
            (actual_transaction_value - expected_transaction_value)
            / NULLIF(expected_transaction_value, 0)
        ) * 100,
        2
    ) AS variance_percent

FROM variance_base

WHERE expected_transaction_value IS NOT NULL

ORDER BY variance_percent ASC

LIMIT 5;
