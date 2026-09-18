-- ============================================================
-- Purpose: Customer RFM analysis
-- ============================================================

-- Establish the analysis date
SELECT
    MAX(transaction_date) AS analysis_date
FROM transactions
WHERE status = 'Completed';

-- Calculate RFM metrics
WITH analysis_date AS (

    SELECT
        MAX(transaction_date) AS max_date

    FROM transactions

    WHERE status = 'Completed'
),

rfm AS (

    SELECT

        t.customer_id,

        (
            SELECT max_date
            FROM analysis_date
        )
        -
        MAX(t.transaction_date)
        AS recency_days,

        COUNT(t.transaction_id)
        AS frequency,

        SUM(t.amount)
        AS monetary

    FROM transactions t

    WHERE t.status = 'Completed'

    GROUP BY t.customer_id
)

SELECT
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary

FROM rfm

ORDER BY monetary DESC;

-- Create RFM scores
WITH analysis_date AS (

    SELECT
        MAX(transaction_date) AS max_date
    FROM transactions
    WHERE status = 'Completed'
),

rfm AS (

    SELECT
        t.customer_id,

        (
            SELECT max_date
            FROM analysis_date
        )
        -
        MAX(t.transaction_date)
        AS recency_days,

        COUNT(t.transaction_id) AS frequency,

        SUM(t.amount) AS monetary

    FROM transactions t

    WHERE t.status = 'Completed'

    GROUP BY t.customer_id
),

rfm_scores AS (

    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary
        ) AS monetary_score

    FROM rfm
)

SELECT *
FROM rfm_scores
ORDER BY monetary DESC;

-- Create RFM customer segments
WITH analysis_date AS (

    SELECT
        MAX(transaction_date) AS max_date
    FROM transactions
    WHERE status = 'Completed'
),

rfm AS (

    SELECT
        t.customer_id,

        (
            SELECT max_date
            FROM analysis_date
        )
        -
        MAX(t.transaction_date)
        AS recency_days,

        COUNT(t.transaction_id) AS frequency,

        SUM(t.amount) AS monetary

    FROM transactions t

    WHERE t.status = 'Completed'

    GROUP BY t.customer_id
),

rfm_scores AS (

    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary
        ) AS monetary_score

    FROM rfm
)

SELECT
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,

    recency_score,
    frequency_score,
    monetary_score,

    CASE

        WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
            THEN 'High Value Active'

        WHEN recency_score >= 4
             AND frequency_score >= 3
            THEN 'Active Customers'

        WHEN recency_score <= 2
             AND frequency_score >= 3
            THEN 'At Risk'

        WHEN recency_score <= 2
             AND frequency_score <= 2
            THEN 'Low Engagement'

        ELSE 'Developing'

    END AS rfm_segment

FROM rfm_scores

ORDER BY monetary DESC;

-- Create an RFM view
DROP VIEW IF EXISTS customer_rfm;

CREATE VIEW customer_rfm AS

WITH analysis_date AS (

    SELECT
        MAX(transaction_date) AS max_date

    FROM transactions

    WHERE status = 'Completed'
),

rfm AS (

    SELECT

        t.customer_id,

        (
            SELECT max_date
            FROM analysis_date
        )
        -
        MAX(t.transaction_date)
        AS recency_days,

        COUNT(t.transaction_id) AS frequency,

        SUM(t.amount) AS monetary

    FROM transactions t

    WHERE t.status = 'Completed'

    GROUP BY t.customer_id
),

rfm_scores AS (

    SELECT

        customer_id,
        recency_days,
        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary
        ) AS monetary_score

    FROM rfm
)

SELECT

    customer_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,

    recency_score,
    frequency_score,
    monetary_score,

    CASE

        WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
            THEN 'High Value Active'

        WHEN recency_score >= 4
             AND frequency_score >= 3
            THEN 'Active Customers'

        WHEN recency_score <= 2
             AND frequency_score >= 3
            THEN 'At Risk'

        WHEN recency_score <= 2
             AND frequency_score <= 2
            THEN 'Low Engagement'

        ELSE 'Developing'

    END AS rfm_segment

FROM rfm_scores;

-- Analyze RFM segments
SELECT
    rfm_segment,

    COUNT(*) AS customers,

    ROUND(
        AVG(recency_days),
        2
    ) AS avg_recency_days,

    ROUND(
        AVG(frequency),
        2
    ) AS avg_frequency,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary_value

FROM customer_rfm

GROUP BY rfm_segment

ORDER BY avg_monetary_value DESC;

-- Calculate segment revenue
SELECT
    rfm_segment,

    COUNT(*) AS customers,

    ROUND(
        SUM(monetary),
        2
    ) AS total_revenue,

    ROUND(
        100.0 *
        SUM(monetary)
        /
        SUM(SUM(monetary)) OVER (),
        2
    ) AS revenue_contribution_percent

FROM customer_rfm

GROUP BY rfm_segment

ORDER BY total_revenue DESC;

-- Find customers in the "At Risk" segment
SELECT
    r.customer_id,
    c.customer_name,
    c.customer_segment,
    c.state,
    r.recency_days,
    r.frequency,
    r.monetary,
    r.rfm_segment

FROM customer_rfm r

JOIN customers c
    ON r.customer_id = c.customer_id

WHERE r.rfm_segment = 'At Risk'

ORDER BY r.monetary DESC

LIMIT 25;

