-- ============================================================
-- Purpose: Create executive KPI view
-- ============================================================

DROP VIEW IF EXISTS executive_kpis;

CREATE VIEW executive_kpis AS
SELECT
    (SELECT COUNT(*)
     FROM customers) AS total_customers,

    (SELECT COUNT(DISTINCT customer_id)
     FROM transactions
     WHERE status = 'Completed') AS active_customers,

    (SELECT COUNT(*)
     FROM accounts) AS total_accounts,

    (SELECT COUNT(*)
     FROM accounts
     WHERE status = 'Active') AS active_accounts,

    (SELECT COUNT(*)
     FROM transactions) AS total_transactions,

    (SELECT COUNT(*)
     FROM transactions
     WHERE status = 'Completed') AS completed_transactions,

    (SELECT COUNT(*)
     FROM transactions
     WHERE status = 'Failed') AS failed_transactions,

    (SELECT COUNT(*)
     FROM transactions
     WHERE status = 'Pending') AS pending_transactions,

    (SELECT ROUND(SUM(amount), 2)
     FROM transactions
     WHERE status = 'Completed') AS total_revenue,

    (SELECT ROUND(AVG(amount), 2)
     FROM transactions
     WHERE status = 'Completed') AS average_transaction_value,

    (
        SELECT ROUND(
            100.0 *
            COUNT(DISTINCT customer_id)
            /
            NULLIF(
                (SELECT COUNT(*) FROM customers),
                0
            ),
            2
        )
        FROM transactions
        WHERE status = 'Completed'
    ) AS customer_activity_rate,

    (
        SELECT ROUND(
            100.0 *
            COUNT(*)
            FILTER (WHERE status = 'Completed')
            /
            NULLIF(COUNT(*), 0),
            2
        )
        FROM transactions
    ) AS transaction_success_rate,

    (
        SELECT ROUND(
            100.0 *
            COUNT(*)
            FILTER (WHERE status = 'Failed')
            /
            NULLIF(COUNT(*), 0),
            2
        )
        FROM transactions
    ) AS transaction_failure_rate;