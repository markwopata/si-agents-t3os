select
    m.market_id,
    mt.market_type_id,
    m.market_name,
    pm_id.parent_market_id,
    pm_name.market_name as parent_market_name,
    -- use Branch Earnings start month from the parent market if it exists. else, use the child market's BE start month
    coalesce(pm_month.branch_earnings_start_month, cm_month.branch_earnings_start_month) as branch_earnings_start_month,
    datediff(
        months, coalesce(pm_month.branch_earnings_start_month, cm_month.branch_earnings_start_month), current_date()
    )
    + 1 as current_months_open,
    coalesce(current_months_open > 12, false) as is_open_over_12_months,
    md.is_dealership,
    md.division_id,
    md.is_active_market as is_market_data_active_market,
    dt.division_name,
    m.company_id,
    c.company_name,
    m.abbreviation,
    m.area_code,
    m.is_active,
    m.is_public_msp,
    m.is_public_rsp,
    ec.company_id is not null as is_market_es_owned,
    m.location_id,
    l.nickname as location_nickname,
    l.street_1,
    l.street_2,
    l.city,
    s.abbreviation as state,
    s.name as state_name,
    d.region_id as region,
    d.district_id as district,
    d.district_id as region_district,
    d.id as _id_dist,
    r.region_name,
    mt.name as market_type,
    l.zip_code,
    mc.county,
    l.street_1 || ', ' || coalesce(l.street_2 || ', ', '') || l.city || ', ' || s.abbreviation || ' '
    || l.zip_code as full_address,
    l.latitude,
    l.longitude,
    'https://www.google.com/maps/place/' || l.latitude || ',' || l.longitude || '/data=!3m1!1e3/@' || l.latitude
    || ',' || l.longitude || ',450m' as url_google_maps,
    m.date_created,
    m.date_updated,
    m._es_update_timestamp
from {{ ref("stg_es_warehouse_public__markets") }} as m
    left join {{ ref("stg_es_warehouse_public__locations") }} as l -- can be null
        on m.location_id = l.location_id
    left join {{ ref("stg_es_warehouse_public__states") }} as s
        on l.state_id = s.state_id
    inner join {{ ref("stg_es_warehouse_public__companies") }} as c
        on m.company_id = c.company_id
    left join {{ ref("stg_analytics_public__es_companies") }} as ec
        on m.company_id = ec.company_id
            and ec.owned
    left join {{ ref('stg_analytics_branch_earnings__parent_market' ) }} as pm_id
        on m.market_id = pm_id.market_id
            and date_trunc(month, current_date()) >= pm_id.start_month -- only consider parent mappings that have already started.
            and date_trunc(month, current_date()) <= coalesce(pm_id.end_month, '2099-12-31') -- only consider parent mappings that have not ended
    left join {{ ref('stg_analytics_gs__market_rollout') }} as cm_month -- used for child market's BE start month
        on m.market_id = cm_month.market_id
    left join {{ ref('stg_analytics_gs__market_rollout') }} as pm_month -- used for parent market's BE start month
        on pm_id.parent_market_id = pm_month.market_id
    left join {{ ref( 'stg_es_warehouse_public__markets' ) }} as pm_name -- used for parent market's market name
        on pm_id.parent_market_id = pm_name.market_id
    left join {{ ref('stg_analytics_market_data__market_data') }} as md
        on m.market_id = md.market_id
    left join {{ ref('stg_analytics_public__districts' ) }} as d
        on md.district_id = d.id
    left join {{ ref('stg_analytics_public__regions') }} as r
        on d.region_id = r.region_id
    left join {{ ref('stg_analytics_market_data__division_types') }} as dt
        on md.division_id = dt.division_id
    left join {{ ref('stg_analytics_market_data__market_types') }} as mt
        on md.market_type_id = mt.market_type_id
    left join {{ ref('stg_analytics_tax__market_county') }} as mc
        on m.market_id = mc.market_id
