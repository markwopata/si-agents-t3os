with bu_asset_equipment as (

    select * from {{ ref('stg_analytics_lease_accelerator__bu_asset_all_equipment_api_download') }}

),

asset_details as (

    select * from {{ ref('int_asset_historical') }}

)

select
    -- grain
    b.las_asset_id,
    b.ledger_category,

    -- ids
    b.admin_asset_id,
    b.market_id as las_cost_center,
    case
        when b.market_id::varchar = 'TBD' or (a.market_name in ('Corporate', 'Main Branch')) then '1000000'
        -- if market_id from int_asset_historical is null, use LAS cost_center
        else coalesce(a.market_id::varchar, b.market_id::varchar)
    end as market_id,
    a.market_name as market_id_name,

    -- booleans
    coalesce(b.market_id::varchar = a.market_id::varchar, false) as market_id_match,  -- force FALSE if null

    -- strings
    b.serial_number,
    b.host_name,
    b.description,
    b.lease,
    b.asset_type,
    b.status,
    b.term,
    b.product_number,
    b.manufacturer,
    b.asset_reference_number,
    b.lease_genre,

    -- numerics
    b.asset_cost_local,
    b.asset_rent_local,
    b.months_remaining,

    -- dates
    b.date_entered,
    b.booking_ledger_date,
    b.commencement_date,
    b.original_end_date,
    b.effective_end_date

from bu_asset_equipment as b
    left join asset_details as a
        on b.admin_asset_id = a.asset_id
            and b.as_at_date = a.daily_timestamp::date
