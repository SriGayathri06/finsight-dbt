{% snapshot scd_customers %}

{{
    config(
        target_schema='snapshots',
        target_database='finsight_db',
        unique_key='customer_id',
        strategy='check',
        check_cols=['email', 'city'],
        invalidate_hard_deletes=True
    )
}}

SELECT
    customer_id,
    full_name,
    email,
    city,
    signup_date
FROM {{ source('raw', 'customers') }}
{% endsnapshot %}