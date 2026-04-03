with bu_asset_report as (

    select 
        *
        , sum(allocated_cost_local) over(partition by lease) as total_lease_oec
        , allocated_cost_local / total_lease_oec as asset_id_lease_oec_percentage
        , total_lease_oec * asset_id_lease_oec_percentage as oec_proportion
    from {{ ref('stg_analytics_lease_accelerator__bu_asset_api_download') }}

)

, monthly_payment_schedules as (

    select * from {{ ref('stg_analytics_lease_accelerator__payment_schedule') }}

)

select
    -- grain
    asset.las_asset_id
    , s.payment_date

    -- ids
    , asset.admin_asset_id
    , s.schedule_number
    , s.lease_genre

    -- strings
    , s.ledger_code
    , asset.asset_type
    , asset.lease

    -- numerics
    , asset.asset_id_lease_oec_percentage
    , asset.total_lease_oec
    , asset.oec_proportion
    , s.payment_amount
    , s.payment_amount * asset.asset_id_lease_oec_percentage as amount_paid

    -- dates
    , s.period_start_date

from bu_asset_report asset
inner join monthly_payment_schedules s
    on asset.lease = s.schedule_number
