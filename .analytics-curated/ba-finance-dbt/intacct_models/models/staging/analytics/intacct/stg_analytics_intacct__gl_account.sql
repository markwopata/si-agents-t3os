with source as (
    select * from {{ source('analytics_intacct', 'gl_account') }}
),

renamed as (
    select
        -- ids
        recordno as pk_account_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,

        -- strings
        accountno as account_number,
        title as account_name,
        accounttype as account_type,
        normalbalance as account_normal_balance,
        closingtype as closing_type,
        category as account_category,
        status,

        -- timestamps
        whenmodified as date_updated,
        whencreated as date_created,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp

    from source
)

select * from renamed
