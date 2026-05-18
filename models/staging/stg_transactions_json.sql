with source as (

    select * from {{ source('raw', 'transactions_json') }}

),

flattened as (

    select
        transaction_id,
        raw_data:transaction_id::varchar        as api_transaction_id,
        raw_data:customer:id::varchar           as customer_id,
        raw_data:customer:name::varchar         as customer_name,
        raw_data:merchant:id::varchar           as merchant_id,
        raw_data:merchant:name::varchar         as merchant_name,
        raw_data:merchant:category::varchar     as category,
        raw_data:amount::decimal(10,2)          as amount,
        raw_data:currency::varchar              as currency,
        upper(raw_data:status::varchar)         as status,
        raw_data:metadata:device::varchar       as device,
        raw_data:metadata:location::varchar     as location,
        raw_data:transaction_date::date         as transaction_date,
        current_timestamp()                     as _loaded_at

    from source

),

final as (

    select *
    from flattened
    where customer_id is not null
      and amount is not null
      and amount > 0

)

select * from final