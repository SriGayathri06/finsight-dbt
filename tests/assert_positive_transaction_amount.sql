-- This test FAILS if any rows are returned
-- A completed transaction must always have a positive amount

select
    transaction_id,
    amount
from {{ ref('stg_transactions') }}
where amount <= 0