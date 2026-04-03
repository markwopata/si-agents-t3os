-- get last day asset was owned by EquipmentShare (day before it becomes non-ES owned)
-- merged on next step to adj cap schedule

with schedule_assets as ( -- assets from requests made in retool app
    select distinct asset_id
    from {{ ref('stg_analytics_service__major_asset_repair_requests') }}
    -- only requests that meet capitalization criteria or were overridden & approved for capitalization
    where depreciation_flag = true
),

es_company_ids as ( 
    select distinct asset_company_id
    from {{ ref('int_assets') }} 
    where is_es_owned_company = true -- company ids for es companies, aligns with logic in retool.
),

ownership as (
    select
        iaho.asset_id,
        iaho.daily_timestamp::date as day_dt,
        iaho.asset_company_id,
        case
            when iaho.asset_company_id in (select asset_company_id from es_company_ids) then true
            else false
        end as is_es_owned -- flag for whether asset is owned by ES on a given day, aligns with logic in retool
    from {{ ref('int_asset_historical_ownership') }} as iaho
    where exists (
        select 1
        from schedule_assets as sa
        where sa.asset_id = iaho.asset_id -- only assets that have been submitted for major asset repair requests in retool
    )
),

ownership_transitions as (
    select
        asset_id,
        day_dt,
        is_es_owned,
        lead(is_es_owned) over (partition by asset_id order by day_dt) as next_is_es_owned
    from ownership
),

last_es_owned_day as (
    select
        asset_id,
        max(day_dt) as last_es_owned_day
    from ownership_transitions
    -- last ES-owned day is when today is ES-owned and next recorded day is not ES-owned
    where is_es_owned = true
      and next_is_es_owned = false
    group by 1
)

select
    asset_id,
    date_trunc('month', last_es_owned_day) as sale_month,
    last_es_owned_day
from last_es_owned_day
