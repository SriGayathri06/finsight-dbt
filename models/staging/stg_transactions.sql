with source as (

    select * from {{ source('raw', 'transactions') }}

),

deduplicated as (

    select *
    from source
    qualify row_number() over (
        partition by transaction_id
        order by transaction_date desc
    ) = 1

),

final as (

    select
        transaction_id,
        customer_id,
        merchant_id,
        amount,
        transaction_date,
        upper(transaction_type)                    as transaction_type,
        upper(status)                              as status,
        current_timestamp()                        as _loaded_at

    from deduplicated
    where customer_id is not null
      and merchant_id is not null

)

select * from final