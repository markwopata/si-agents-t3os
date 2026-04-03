{{ config(
    materialized='table'
    , cluster_by=['company_id', 'day']
) }}

with recursive
    date_series_base as (
        select to_timestamp(dateadd(day, -365, current_date())) as series
        union all
        select series + interval '1 day'
        from date_series_base
        where series + interval '1 day' <= to_timestamp(current_date())
    ),
    date_series_raw as (
        select series::date as day, dayname(series::date) as day_name from date_series_base
    ),
    date_filterd_hau as (
        select
            report_range:start_range as start_range,
            report_range:end_range as end_range,
            *
        from {{ ref("platform", "es_warehouse__public__hourly_asset_usage") }} hau
        where start_range >= DATEADD(day, -365, CURRENT_DATE())
    ),
    distinct_asset_ids as (select distinct asset_id from date_filterd_hau),
    date_series as (
        select *
        from date_series_raw
        cross join distinct_asset_ids
        order by asset_id desc, day desc
    ),
    per_day_rental_assets as (
        select
            ds.day,
            cv.rental_company_id as rental_company_id,
            count(distinct(cv.asset_id)) as rental_asset_count
        from date_series ds
        left join
            {{ ref("stg_t3__company_values") }} cv
            on cv.asset_id = ds.asset_id
            and ds.day >= cv.start_date
            and ds.day <= cv.end_date
        group by ds.day, cv.rental_company_id
    ),
    per_day_owned_assets as (
        select
            ds.day,
            cv.owner_company_id as owner_company_id,
            count(distinct(cv.asset_id)) as owned_asset_count
        from date_series ds
        left join
            {{ ref("stg_t3__company_values") }} cv
            on cv.asset_id = ds.asset_id
            and ds.day >= cv.start_date
            and ds.day <= cv.end_date
        group by ds.day, cv.owner_company_id
    ),
    distinct_company_ids as (
        select distinct company_id
        from {{ ref("platform", "es_warehouse__public__companies") }}
    ),
    date_series_with_companies as (
        select ds.day, dc.company_id
        from date_series_raw ds
        join distinct_company_ids dc
    )

select
    ds.day,
    ds.company_id,
    coalesce(ra.rental_asset_count, 0) as rental_asset_count,
    coalesce(oa.owned_asset_count, 0) as owned_asset_count
from date_series_with_companies ds
left join
    per_day_owned_assets oa on oa.day = ds.day and oa.owner_company_id = ds.company_id
left join
    per_day_rental_assets ra on ra.day = ds.day and ds.company_id = ra.rental_company_id
