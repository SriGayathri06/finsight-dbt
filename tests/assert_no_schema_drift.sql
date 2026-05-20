-- tests/assert_no_schema_drift.sql
-- Fails if raw.transactions has columns 
-- not present in stg_transactions

with raw_cols as (
    select column_name
    from finsight_db.information_schema.columns
    where table_name = 'TRANSACTIONS'
    and table_schema = 'RAW'
),

stg_cols as (
    select column_name
    from finsight_db.information_schema.columns
    where table_name = 'STG_TRANSACTIONS'
    and table_schema = 'STAGING'
),

new_columns as (
    select r.column_name
    from raw_cols r
    left join stg_cols s 
        on r.column_name = s.column_name
    where s.column_name is null
)

-- Test FAILS if any new columns exist in raw
-- that aren't in staging yet
select * from new_columns