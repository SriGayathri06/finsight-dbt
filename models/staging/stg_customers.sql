with source as (

    select * from {{ source('raw', 'customers') }}

),

final as (

    select
        customer_id,
        initcap(full_name)                         as full_name,
        lower(email)                               as email,
        initcap(city)                              as city,
        signup_date,
        current_timestamp()                        as _loaded_at

    from source
    where customer_id is not null

)

select * from final