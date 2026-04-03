with source as (

    select * from {{ ref('base_analytics_lease_accelerator__ledger_export_api_download') }}

),

renamed as (

    select

        -- ids
        ledger_entry_id,
        ledger_entry_sub_id,

        -- strings
        transactional_currency,
        functional_currency,
        reporting_currency,
        account_description,
        comments,
        journal_entry_description,
        fx_rate_type,
        schedule,

        -- numerics
        ledger_code,
        posting_code,
        status,
        asset_number,
        debit_amount,
        credit_amount,
        net_amount,
        gl_account_number,
        market_id,

        -- booleans
        -- dates

        -- timestamps
        ledger_date,
        related_period,
        _es_update_timestamp

    from source
    qualify dense_rank() over(partition by ledger_code order by _es_update_timestamp desc) = 1  -- filtering to each ledger_code's most recent report run
)

select * from renamed
