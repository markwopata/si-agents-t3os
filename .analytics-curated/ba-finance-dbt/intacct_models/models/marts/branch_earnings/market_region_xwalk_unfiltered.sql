select 
    m.market_id::int as market_id
    , m.market_name
    , s.name as state
    , m.abbreviation
    , d.region_id as region
    , r.region_name
    , m.area_code
    , d.district_id as district
    , d.district_id as region_district
    , d.id as _id_dist
    , md.market_type_id
    , mt.name as market_type
    , md.is_dealership
    , md.division_id
    , dt.division_name
    , md.is_active_market
    , current_timestamp() as date_updated
from {{ ref('stg_es_warehouse_public__markets') }} m
inner join {{ ref('stg_analytics_market_data__market_data') }} md
    on md.market_id = m.market_id
left join {{ ref('stg_es_warehouse_public__locations')}} l
    on m.location_id = l.location_id
left join {{ ref('stg_es_warehouse_public__states') }} s
    on l.state_id = s.state_id
left join {{ ref('stg_analytics_public__districts' )}} d
    on md.district_id = d.id
left join {{ ref('stg_analytics_public__regions') }} r
    on d.region_id = r.region_id
left join {{ ref('stg_analytics_market_data__division_types') }} dt
    on md.division_id = dt.division_id
left join {{ ref('stg_analytics_market_data__market_types') }} mt
    on md.market_type_id = mt.market_type_id
