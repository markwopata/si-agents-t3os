with source as (

    select * from {{ source('lease_accelerator', 'portfolio_balance_api_download') }}

),

renamed as (

    select

        -- ids
        ledger_id,                                    -- numeric, looks like ledger_id
        deal_id,                                      -- numeric representation of schedule - schedule is not unique with deal_id - some duplicate entered schedule numbers
        schedule,                                     -- number for a lease schedule
        account_code,                                 -- account number, but some are null
        cost_center,                                  -- market_id, but varchar because there's some stuff like TBD/Corp1
        gl_segment_2 as gl_account_number,            -- account_number
        gl_segment_3 as market_id,                    -- same as cost_center plus some that say PendingApproval

        -- strings
        statement_sequencer,                          -- (ordering) sequence on statement
        account_description,                          -- some kind of line type, does not match up 1-1 to account_code
        account_number_and_name,
        financial_statement,                          -- 'Balance Sheet' or 'Income Statement'
        statement_section,                            -- 'Assets','Liabilities', 'Expenses'
        gl_coding_convention,
        deal_status,                                  -- Active, Terminated, Defunct (Rolled Back)
        entity,                                       -- always EquipmentShare.com Inc
        lessee,                                       -- always EquipmentShare.com Inc
        business_unit,                                -- always EquipmentShare.com Inc
        currency_measured_in,                         -- always null
        lease_genre as asset_type,                    -- Equipment, Real Estate, or both
        functional_currency,                          -- (all) USD
        ledgerlist,                                   -- ASC842-Consolidated,ASC842-Operating
        
        -- numerics
        amount,                                       -- rounded to 2 decimals from raw_amount
        ledger_code,                                  -- numeric, looks like ledger_id

        -- dates
        month_end_date,
        as_at_date,                                   -- cast to date
        starting_fiscal_period,                       -- cast to date
        ending_fiscal_period,                         -- cast to date

        -- timestamps        
        _es_update_timestamp                          -- cast to timestamp_tz

    from source

)

select * from renamed
