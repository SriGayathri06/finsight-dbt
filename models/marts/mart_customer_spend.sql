with transactions as (

    select * from {{ ref('stg_transactions') }}

),

customers as (

    select * from {{ ref('stg_customers') }}

),

joined as (

    select
        t.transaction_id,
        t.customer_id,
        c.full_name,
        c.city,
        t.amount,
        t.transaction_date,
        date_trunc('month', t.transaction_date)    as transaction_month,
        t.transaction_type,
        t.status

    from transactions t
    left join customers c
        on t.customer_id = c.customer_id

),

final as (

    select
        customer_id,
        full_name,
        city,
        transaction_month,
        count(transaction_id)                      as transaction_count,
        sum(amount)                                as total_spend,
        avg(amount)                                as avg_transaction_value,
        min(amount)                                as min_transaction,
        max(amount)                                as max_transaction

    from joined
    group by
        customer_id,
        full_name,
        city,
        transaction_month

)

select * from final