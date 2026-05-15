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
        m.merchant_name,
        m.category

    from transactions t
    left join merchants m
        on t.merchant_id = m.merchant_id

),

final as (

    select
        category,
        transaction_month,
        count(transaction_id)                      as transaction_count,
        sum(amount)                                as total_spend,
        avg(amount)                                as avg_transaction_value,
        round(
            sum(amount) * 100.0 /
            sum(sum(amount)) over (partition by transaction_month),
            2
        )                                          as pct_of_monthly_spend

    from joined
    group by
        category,
        transaction_month

)

select * from final