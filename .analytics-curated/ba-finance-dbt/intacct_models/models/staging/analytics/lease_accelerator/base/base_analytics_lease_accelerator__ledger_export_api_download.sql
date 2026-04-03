with source as (

    select * from {{ source('lease_accelerator', 'ledger_export_api_download') }}

),

renamed as (

    select

        -- ids
        ledgerentryid as ledger_entry_id,
        ledgerentrysubid as ledger_entry_sub_id,

        -- strings
        transactional_currency,
        functional_currency,
        reporting_currency,
        accountdescription as account_description,
        comments,
        jeshortdesc as journal_entry_description,
        fx_rate_type,
        schedule,

        -- numerics
        ledger_code,
        posting_code,
        status,
        asset_number,
        debit_amount,
        credit_amount,
        debit_amount - credit_amount as net_amount,
        segment2 as gl_account_number,
        segment3 as market_id,
        
        -- booleans
        -- dates
        -- timestamps
        ledger_date,
        fx_conversion_date as related_period,
        _es_update_timestamp

    from source

)

select * from renamed
