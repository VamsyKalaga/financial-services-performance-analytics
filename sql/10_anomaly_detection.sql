
-- 1. Calculate Transaction Amount Quartiles
WITH transaction_stats AS (

    SELECT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY amount) AS q1,

        PERCENTILE_CONT(0.50)
            WITHIN GROUP (ORDER BY amount) AS median_amount,

        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY amount) AS q3
    FROM transactions
    WHERE status = 'Completed'

),

-- 2. Calculate IQR Boundaries
iqr_bounds AS (

    SELECT
        q1,
        median_amount,
        q3,

        q3 - q1 AS iqr,

        q1 - (1.5 * (q3 - q1)) AS lower_bound,

        q3 + (1.5 * (q3 - q1)) AS upper_bound

    FROM transaction_stats

)

-- 3. Identify Transaction Amount Anomalies
SELECT

    t.transaction_id,
    t.customer_id,
    t.account_id,
    t.transaction_date,
    t.transaction_type,
    t.amount,
    t.merchant_category,
    t.channel,
    t.status,

    b.q1,
    b.median_amount,
    b.q3,
    b.iqr,
    b.lower_bound,
    b.upper_bound,

    CASE
        WHEN t.amount > b.upper_bound
            THEN 'High Amount Anomaly'

        WHEN t.amount < b.lower_bound
            THEN 'Low Amount Anomaly'

        ELSE 'Normal'
    END AS anomaly_status

FROM transactions t

CROSS JOIN iqr_bounds b

WHERE t.status = 'Completed'

ORDER BY t.amount DESC;

-- Count the anomalies
SELECT
    anomaly_status,
    COUNT(*) AS transaction_count
FROM (
    WITH transaction_stats AS (

        SELECT
            PERCENTILE_CONT(0.25)
                WITHIN GROUP (ORDER BY amount) AS q1,

            PERCENTILE_CONT(0.50)
                WITHIN GROUP (ORDER BY amount) AS median_amount,

            PERCENTILE_CONT(0.75)
                WITHIN GROUP (ORDER BY amount) AS q3

        FROM transactions

        WHERE status = 'Completed'

    ),

    iqr_bounds AS (

        SELECT
            q1,
            median_amount,
            q3,

            q3 - q1 AS iqr,

            q1 - (1.5 * (q3 - q1)) AS lower_bound,

            q3 + (1.5 * (q3 - q1)) AS upper_bound

        FROM transaction_stats

    )

    SELECT

        CASE
            WHEN t.amount > b.upper_bound
                THEN 'High Amount Anomaly'

            WHEN t.amount < b.lower_bound
                THEN 'Low Amount Anomaly'

            ELSE 'Normal'
        END AS anomaly_status

    FROM transactions t

    CROSS JOIN iqr_bounds b

    WHERE t.status = 'Completed'

) anomaly_results

GROUP BY anomaly_status
ORDER BY transaction_count DESC;

-- Find the highest-value anomalies
WITH transaction_stats AS (

    SELECT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY amount) AS q1,

        PERCENTILE_CONT(0.50)
            WITHIN GROUP (ORDER BY amount) AS median_amount,

        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY amount) AS q3

    FROM transactions

    WHERE status = 'Completed'

),

iqr_bounds AS (

    SELECT
        q1,
        median_amount,
        q3,

        q3 - q1 AS iqr,

        q3 + (1.5 * (q3 - q1)) AS upper_bound

    FROM transaction_stats

)

SELECT
    t.transaction_id,
    t.customer_id,
    t.transaction_date,
    t.amount,
    t.transaction_type,
    t.merchant_category,
    t.channel

FROM transactions t

CROSS JOIN iqr_bounds b

WHERE t.status = 'Completed'
  AND t.amount > b.upper_bound

ORDER BY t.amount DESC

LIMIT 20;

-- Analyze anomalies by channel
WITH transaction_stats AS (

    SELECT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY amount) AS q1,

        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY amount) AS q3

    FROM transactions

    WHERE status = 'Completed'

),

iqr_bounds AS (

    SELECT
        q1,
        q3,
        q3 + (1.5 * (q3 - q1)) AS upper_bound

    FROM transaction_stats

)

SELECT
    t.channel,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE t.amount > b.upper_bound
    ) AS anomaly_transactions,

    ROUND(
        COUNT(*) FILTER (
            WHERE t.amount > b.upper_bound
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS anomaly_rate_percent

FROM transactions t

CROSS JOIN iqr_bounds b

WHERE t.status = 'Completed'

GROUP BY t.channel

ORDER BY anomaly_rate_percent DESC;


-- Analyze anomalies by transaction type
WITH transaction_stats AS (

    SELECT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY amount) AS q1,

        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY amount) AS q3

    FROM transactions

    WHERE status = 'Completed'

),

iqr_bounds AS (

    SELECT
        q1,
        q3,
        q3 + (1.5 * (q3 - q1)) AS upper_bound

    FROM transaction_stats

)

SELECT
    t.transaction_type,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE t.amount > b.upper_bound
    ) AS anomaly_transactions,

    ROUND(
        COUNT(*) FILTER (
            WHERE t.amount > b.upper_bound
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS anomaly_rate_percent

FROM transactions t

CROSS JOIN iqr_bounds b

WHERE t.status = 'Completed'

GROUP BY t.transaction_type

ORDER BY anomaly_rate_percent DESC;

-- Analyze anomalies by merchant category
WITH transaction_stats AS (

    SELECT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY amount) AS q1,

        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY amount) AS q3

    FROM transactions

    WHERE status = 'Completed'

),

iqr_bounds AS (

    SELECT
        q1,
        q3,
        q3 + (1.5 * (q3 - q1)) AS upper_bound

    FROM transaction_stats

)

SELECT
    t.merchant_category,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE t.amount > b.upper_bound
    ) AS anomaly_transactions,

    ROUND(
        COUNT(*) FILTER (
            WHERE t.amount > b.upper_bound
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS anomaly_rate_percent

FROM transactions t

CROSS JOIN iqr_bounds b

WHERE t.status = 'Completed'

GROUP BY t.merchant_category

ORDER BY anomaly_rate_percent DESC;