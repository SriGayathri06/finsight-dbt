with raw_cols as (
    select lower(column_name) as column_name
    from finsight_db.information_schema.columns
    where table_name = 'TRANSACTIONS'
    and table_schema = 'RAW'
),

stg_cols as (
    select lower(column_name) as column_name
    from finsight_db.information_schema.columns
    where table_name = 'STG_TRANSACTIONS'
    and table_schema = 'STAGING'
),

-- columns intentionally renamed in staging
-- raw name → staging name mappings
known_renames as (
    select 'loaded_at' as raw_column_name
),

new_columns as (
    select r.column_name
    from raw_cols r
    left join stg_cols s
        on r.column_name = s.column_name
    left join known_renames k
        on r.column_name = k.raw_column_name
    where s.column_name is null
      and k.raw_column_name is null  -- exclude known renames
)

select * from new_columns