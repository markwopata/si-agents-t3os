with parent_markets as (
    select distinct
        market_id,
        market_name,
        region_district
    from {{ ref("market") }}
    where branch_earnings_start_month <= '{{ live_be_start_date() }}'
),

market_goals as (

    select *
    from {{ ref("stg_analytics_public__market_goals") }}
    where months between '{{ live_be_start_date() }}' and '{{ live_be_end_date() }}'
)

select
    parent_markets.market_id,
    'JAAA' as account_number,
    'Market ID' as transaction_number_format,
    parent_markets.market_id::varchar as transaction_number,
    concat('Corporate Allocation', ' ', parent_markets.market_name) as description,
    market_goals.months::date as gl_date,
    'Market ID' as document_type,
    parent_markets.market_id::varchar as document_number,
    null as url_sage,
    null as url_concur,
    null as url_admin,
    null as url_t3,
    case
        when (upper(parent_markets.market_name) like '%RETAIL%' and parent_markets.market_id != '61105')
            then -10000
        when upper(parent_markets.market_name) like '%MOBILE%TOOL%'
            then -1000
        when parent_markets.market_name like '%XOM%'
            then -5000
        when market_goals.market_level = 'C1'
            then -15000
        when market_goals.market_level = 'C2'
            then -10000
        when market_goals.market_level = 'C3'
            then -5000
        when market_goals.market_level = 'C4'
            then -5000
        when market_goals.market_level = 'AS1'
            then -5000
        when market_goals.market_level = 'AS2'
            then -5000
        when market_goals.market_level = 'AS3'
            then -5000
        when market_goals.market_level = 'T1'
            then -5000
    end as amount,
    object_construct('market_level', market_goals.market_level) as additional_data,
    'ANALYTICS' as source,
    'Corporate Allocation' as load_section,
    '{{ this.name }}' as source_model
from parent_markets
    inner join market_goals
        on parent_markets.market_id = market_goals.market_id
where parent_markets.region_district is not null
    and market_goals.end_date is null
    or (
        parent_markets.market_name like '%RETAIL%'
        and parent_markets.market_id != '61105'
    )
