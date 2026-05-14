with source as (

    select * from {{ source('raw', 'merchants') }}

),

final as (

    select
        merchant_id,
        initcap(trim(merchant_name))               as merchant_name,
        initcap(trim(category))                    as category,
        initcap(trim(city))                        as city,
        current_timestamp()                        as _loaded_at

    from source
    where merchant_id is not null

)

select * from final