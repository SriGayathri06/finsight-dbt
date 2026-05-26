{{ config(materialized='table') }}

WITH transactions AS (
    SELECT
        transaction_id,
        customer_id,
        merchant_id,
        amount,
        transaction_date,
        transaction_type,
        status
    FROM {{ ref('stg_transactions') }}
    WHERE status = 'COMPLETED'
),

customer_at_txn_time AS (
    SELECT
        t.transaction_id,
        t.customer_id,
        t.amount,
        t.transaction_date,
        t.transaction_type,
        c.city                AS customer_city_at_txn_time,
        c.dbt_valid_from      AS customer_version_from,
        c.dbt_valid_to        AS customer_version_to
    FROM transactions t
    LEFT JOIN {{ ref('scd_customers') }} c
        ON t.customer_id = c.customer_id
        AND (
            -- normal point-in-time join for future transactions
            (
                t.transaction_date >= c.dbt_valid_from
                AND (t.transaction_date < c.dbt_valid_to OR c.dbt_valid_to IS NULL)
            )
            -- fallback: for historical transactions that predate the snapshot,
            -- use the earliest known version of the customer
            OR (
                t.transaction_date < c.dbt_valid_from
                AND c.dbt_valid_from = (
                    SELECT MIN(dbt_valid_from)
                    FROM {{ ref('scd_customers') }}
                    WHERE customer_id = t.customer_id
                )
            )
        )
)

SELECT
    transaction_id,
    customer_id,
    amount,
    transaction_date,
    transaction_type,
    customer_city_at_txn_time,
    customer_version_from,
    customer_version_to,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM customer_at_txn_time