with bu_asset_report as (

    select * from {{ ref('stg_analytics_lease_accelerator__bu_asset_api_download') }}
    where 
        admin_asset_id > 0
        and asset_cost_local > 0
        and asset_type not in ('Software', 'Aircraft and Related') 
        -- excluding these asset types b/c:
        -- ES isn't buying out software or aircraft leases

        -- excluding these statuses b/c
        -- do not want to calculate nbv for terminated, bought out, or disposed leases

        -- select only the most recent data since the table contains historical appends

)

, portfolio_trial_balance as (

    select * from {{ ref('int_portfolio_balance_pivoted_to_leases_and_market') }}

)

, rouse_estimates as (

    select * from {{ ref('stg_data_science_fleet_opt__all_equipment_rouse_estimates') }}

)

, bu_asset_total_oec_calculation as (
    select
        b.lease
        , b.admin_asset_id
        , b.market_id
        , b.serial_number
        , b.las_asset_id
        , b.asset_cost_local
        , sum(b.asset_cost_local) over(partition by b.lease, b.market_id) as total_oec
    from bu_asset_report b
)

select

    -- grain
    p.starting_fiscal_period
    , b.admin_asset_id

    -- ids
    , b.market_id
    , b.las_asset_id
    , b.lease

    -- strings
    , b.serial_number
    , 'Lease Accelerator' as source

    -- numerics
    , b.asset_cost_local
    , b.total_oec
    , coalesce(asset_cost_local / nullif(total_oec, 0), 0) as oec_allocation
    , p.roua * oec_allocation as roua
    , p.accumulated_depreciation * oec_allocation as accumulated_depreciation
    , p.lease_liability * oec_allocation as lease_liability
    , coalesce(r.buyout_price,0) as buyout_price

    -- estimated nbv = roua + accumulated_depreciation + buyout_price + lease_liability
    , ((p.roua * oec_allocation) + (p.accumulated_depreciation * oec_allocation)) + (buyout_price + (p.lease_liability * oec_allocation)) as nbv_estimated_book_value

    -- booleans
    -- dates
    -- timestamps

from bu_asset_total_oec_calculation b
left join portfolio_trial_balance p
    on b.lease = p.schedule
    and b.market_id = p.market_id
left join rouse_estimates r
    on r.asset_id = b.admin_asset_id
