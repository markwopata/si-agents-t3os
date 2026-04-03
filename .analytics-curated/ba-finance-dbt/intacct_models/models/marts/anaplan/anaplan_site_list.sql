with markets as (
    select distinct
        ef.market_id,
        case when ef.market_id = 0 then 'Corporate' else im.market_name end as market_name,
        m.district,
        m.region_name,
        case m.market_type
            when 'Core Solutions' then 'Core Rental'
            when 'ITL' then 'Industrial Tool'
            when 'Advanced Solutions' then 'Advanced Solutions'
            when 'Materials' then 'Hardware'
        end as market_type,
        m.market_start_month,
        m.state,
        1 as tier
    from {{ ref("stg_analytics_revmodel__es_financials_23q2close") }} as ef
        inner join {{ ref("stg_analytics_revmodel__es_financials_versions") }} as efv
            on ef.version = efv.version
                and ef.month_ = efv.month_
                and efv.version_set_name = '2022Q1-2025Q1 Close Prelim v7 - Site Level Financials'
        left join {{ ref("market") }} as m
            on ef.market_id = m.market_id
        left join {{ ref("int_markets") }} as im
            on ef.market_id = im.market_id
        left join {{ ref("stg_analytics_intacct__department") }} as d
            on ef.market_id::text = d.department_id
    where ef.cost_revenue in ('R', 'C')
)

select
    m.market_id::int as market_id,
    m.market_name,
    m.district,
    m.region_name,
    m.market_type,
    m.market_start_month,
    m.state,
    m.tier
from markets as m

union all

select
    d.department_id::int as market_id,
    d.department_name as market_name,
    null as district,
    null as region_name,
    'Corporate' as market_type,
    null as market_start_month,
    null as state,
    1 as tier
from {{ ref("stg_analytics_intacct__department") }} as d
where try_to_number(d.department_id) >= 1000000
    and try_to_number(d.department_id) < 1010000
