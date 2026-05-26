{% snapshot scd_merchants %}

{{
    config(
        target_schema='snapshots',
        target_database='finsight_db',
        unique_key='merchant_id',
        strategy='check',
        check_cols=['category', 'city'],
        invalidate_hard_deletes=True
    )
}}

SELECT
    merchant_id,
    merchant_name,
    category,
    city
FROM {{ source('raw', 'merchants') }}

{% endsnapshot %}