 {{ config(
    materialized="table"
    , cluster_by=["category"]
    ) }}
 
select
    bdu.category,
    count(distinct bdu.asset_id) as distinct_asset_count,
    sum(bdu.on_time_cst) / 3600 as on_time_hours,
    count(concat(bdu.date, bdu.asset_id)) as rental_date_count,
    on_time_hours / (8 * rental_date_count) as utilization_30_day_category_benchmark
from {{ ref("stg_t3__by_day_utilization") }} bdu
join
    {{ ref("stg_t3__company_values") }} cv
    on cv.asset_id = bdu.asset_id
    and bdu.date >= cv.start_date
    and bdu.date <= cv.end_date
    and cv.rental_id is not null
    and 
    (cv.owner_company_id = 1854 
    or 
    cv.owner_company_id in 
    (select asset_id from ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS where end_date is null)
    )

where bdu.date >= dateadd(day, -30, current_date())
and bdu.category is not null
group by bdu.category
order by
    distinct_asset_count desc
    {{ var("row_limit") }}

