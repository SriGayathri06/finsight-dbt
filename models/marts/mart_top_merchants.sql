with transactions as (

    select * from {{ ref('stg_transactions') }}

),

merchants as (

    select * from {{ ref('stg_merchants') }}

),

joined as (

    select
        t.transaction_id,
        t.customer_id,
        t.amount,
        t.transaction_date,
        date_trunc('month', t.transaction_date)    as transaction_month,
        m.merchant_id,
        m.merchant_name,
        m.category,
        m.city                                     as merchant_city

    from transactions t
    left join merchants m
        on t.merchant_id = m.merchant_id

),

aggregated as (

    select
        merchant_id,
        merchant_name,
        category,
        merchant_city,
        transaction_month,
        count(transaction_id)                      as transaction_count,
        sum(amount)                                as total_spend,
        avg(amount)                                as avg_transaction_value

    from joined
    group by
        merchant_id,
        merchant_name,
        category,
        merchant_city,
        transaction_month

),

final as (

    select
        merchant_id,
        merchant_name,
        category,
        merchant_city,
        transaction_month,
        transaction_count,
        total_spend,
        avg_transaction_value,
        rank() over (
            partition by transaction_month
            order by total_spend desc
        )                                          as spend_rank

    from aggregated

)

select * from final