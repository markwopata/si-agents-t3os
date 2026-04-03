with source as (

    select * from {{ ref('base_analytics_lease_accelerator__portfolio_balance_api_download') }}

),

renamed as (

    select
    
        -- ids
        ledger_id,
        deal_id,
        schedule,
        account_code,
        cost_center,
        gl_account_number,
        market_id,

        -- strings
        statement_sequencer,
        account_description,
        account_number_and_name,
        financial_statement,
        statement_section,
        gl_coding_convention,
        deal_status,
        entity,
        lessee,
        business_unit,
        currency_measured_in,
        asset_type,
        functional_currency,
        ledgerlist,

        -- numerics
        amount,
        ledger_code,

        -- booleans
        -- dates
        month_end_date,
        as_at_date,
        starting_fiscal_period,
        ending_fiscal_period,

        -- timestamps        
        _es_update_timestamp

    from source
    qualify dense_rank() over(partition by starting_fiscal_period, ledger_code order by _es_update_timestamp desc) = 1 -- for each starting_fiscal_period, get the most recent downloaded record.

)

select * from renamed
