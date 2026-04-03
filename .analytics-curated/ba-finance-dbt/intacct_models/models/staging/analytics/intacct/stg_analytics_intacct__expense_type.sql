with source as (
    select * from {{ source('analytics_intacct', 'expense_type') }}
)

, renamed as (
    select
        -- ids
        id as pk_expense_type_id,

        -- strings
        name as expense_type,
        expense_category,

        -- timestamps
        whencreated as date_created,
        whenmodified as date_updated,
        ddsreadtime as dds_read_timestamp,
        _es_update_timestamp
    
    from source
)
select * from renamed
