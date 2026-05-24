{{
    config(
        materialized='incremental',
        unique_key='transaction_id',
        on_schema_change='sync_all_columns'
    )
}}

with source as (

    select * from {{ source('raw', 'transactions') }}

    {% if is_incremental() and not var('force_replace', false) %}
        -- System clock watermark: single MAX over a COALESCE handles both columns safely in Snowflake
        where loaded_at > (
            select
                coalesce(
                    max(coalesce(_raw_loaded_at, _loaded_at)),
                    '1900-01-01'::timestamp
                )
            from {{ this }}
        )

    {% elif is_incremental() and var('force_replace', false) %}
        -- Surgical overwrite for corruption fixes
        where transaction_date
            between '{{ var("start_date") }}'
            and '{{ var("end_date") }}'

    {% endif %}

),

deduplicated as (

    select *
    from source
    qualify row_number() over (
        partition by transaction_id
        order by loaded_at desc
    ) = 1

),

final as (

    select
        transaction_id,
        customer_id,
        merchant_id,
        amount,
        transaction_date,
        upper(transaction_type)                     as transaction_type,
        upper(status)                               as status,
        coalesce(payment_method, 'unknown')         as payment_method,
        coalesce(transaction_channel, 'unknown')    as transaction_channel,
        -- Audit metadata columns
        loaded_at                                   as _raw_loaded_at,
        current_timestamp()                         as _loaded_at
    from deduplicated
    where customer_id is not null
      and merchant_id is not null

)

select * from final