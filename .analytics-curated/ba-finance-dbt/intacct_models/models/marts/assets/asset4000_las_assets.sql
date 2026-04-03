with asset4000_assets as (

    select
        
        d.asset_code -- one row is one asset 
        , f.depreciation_date
        , d.market_id
        , d.asset_account
        , d.accumulated_depreciation_account
        , d.depreciation_expense_account
        , d.serial_number
        , d.admin_asset_id
        , d.sage_transaction_number

        -- strings
        , 'Asset4000' as source
        , d.address
        , d.asset_title
        , d.asset_class
        , d.asset_class_name
        , d.facility_type
        , d.last_modified_by
        , d.make
        , d.model
        , d.invoice_number
        , d.invoice_number_two
        , d.invoice_number_three
        , d.asset_disposal_reason

        -- timestamps
        , d.asset_disposal_date
        , d.asset_purchase_date
        , d.asset_capitalized_date
        , d.asset_gl_assignment_date
        , d.asset_expiration_date
        , d.asset_depreciation_start_date

        -- numerics
        , sum(f.nbv) as nbv
        , sum(f.gbv) as gbv
        , sum(f.gbv) - sum(f.nbv) as accumulated_depreciation
        , sum(period_depreciation_expense) as period_depreciation_expense
        , sum(f.year_to_date_depreciation_expense) as year_to_date_depreciation_expense
        , sum(f.salvage_value) as salvage_value
    from {{ ref('dim_asset4000_assets')}} d
    inner join {{ ref('fct_asset4000_asset_financials') }} f
        on d.asset_code = f.asset_code
        and d.depreciation_date = f.depreciation_date
    group by 
        all

)

, las_assets as (

    select * from {{ ref('lease_accelerator_nbv_calculation') }}

)

select 
    lease,
    market_id,
    null as address,
    source,
    las_asset_id,
    serial_number,
    admin_asset_id,
    asset_cost_local,
    total_oec,
    oec_allocation,
    roua,
    accumulated_depreciation,
    null as period_depreciation_expense,
    lease_liability,
    buyout_price,
    nbv_estimated_book_value as nbv_estimated_book_value,
    starting_fiscal_period as report_date,

    -- asset4000 columns (null for las)
    null as asset_code,
    null as depreciation_date,
    null as asset_account,
    null as accumulated_depreciation_account,
    null as depreciation_expense_account,
    null as sage_transaction_number,
    null as asset_title,
    null as asset_class,
    null as asset_class_name,
    null as facility_type,
    null as last_modified_by,
    null as make,
    null as model,
    null as invoice_number,
    null as invoice_number_two,
    null as invoice_number_three,
    null as asset_disposal_reason,
    null as asset_disposal_date,
    null as asset_purchase_date,
    null as asset_capitalized_date,
    null as asset_gl_assignment_date,
    null as asset_expiration_date,
    null as asset_depreciation_start_date,
    null as gbv,
    null as year_to_date_depreciation_expense,
    null as salvage_value
from las_assets

union all

select 
    null as lease,
    market_id,
    address,
    'Asset4000' as source,
    null as las_asset_id,
    serial_number,
    admin_asset_id,
    null as asset_cost_local,
    null as total_oec,
    null as oec_allocation,
    null as roua,
    accumulated_depreciation,
    period_depreciation_expense,
    null as lease_liability,
    null as buyout_price,
    nbv as nbv_estimated_book_value,
    depreciation_date as report_date,

    -- asset4000 columns (actual values)
    asset_code,
    depreciation_date,
    asset_account,
    accumulated_depreciation_account,
    depreciation_expense_account,
    sage_transaction_number,
    asset_title,
    asset_class,
    asset_class_name,
    facility_type,
    last_modified_by,
    make,
    model,
    invoice_number,
    invoice_number_two,
    invoice_number_three,
    asset_disposal_reason,
    asset_disposal_date,
    asset_purchase_date,
    asset_capitalized_date,
    asset_gl_assignment_date,
    asset_expiration_date,
    asset_depreciation_start_date,
    gbv,
    year_to_date_depreciation_expense,
    salvage_value
from asset4000_assets
