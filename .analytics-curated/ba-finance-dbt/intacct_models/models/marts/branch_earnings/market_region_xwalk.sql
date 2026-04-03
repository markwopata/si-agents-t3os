{{ 
    config(
    schema = 'public',
    post_hook=[
        "grant select on {{ this }} to role DBT_PLATFORM_ETL_ROLE",
        "grant select on {{ this }} to role PLATFORM_ETL_ROLE",
    ]
    )
}}

select
    m.market_id::int as market_id,
    m.market_name,
    m.parent_market_id,
    m.parent_market_name,
    m.branch_earnings_start_month,
    m.current_months_open,
    m.is_open_over_12_months,
    m.state_name as state,
    m.abbreviation,
    m.region,
    m.region_name,
    m.area_code,
    m.district,
    m.region_district,
    m._id_dist,
    m.market_type_id,
    m.market_type,
    m.is_dealership,
    m.division_id,
    m.division_name,
    current_timestamp() as date_updated
from {{ ref('int_markets' ) }} as m
where m.is_market_data_active_market = true
