with source as (
    select * from {{ source('analytics_financial_systems', 'item_id_to_gl_account') }}
)

, renamed as (
    select
        -- ids
        item_id,

        -- strings
        status,
        account as account_number,
        account_type,
        gl_group,
        account_description,
        name,
        period_end_closing_type,
        incl_excl,
        account_status,
        item_type,
        normal_balance,

        -- timestamps
        _fivetran_synced
    
    from source
)
select * from renamed
