with vehicle_statuses as (

        select *
        from {{ ref('int_vsg_vehicles_snapshot_enriched') }}
        where 1 = 1
            and dbt_valid_to is null

)
select
    current_date() as as_of_date,
    current_timestamp() as collected_at,
    region_name,
    vin,
    model,
    platform,
    status,
    notes,
    latest_return_date,
    days_since_last_return,
    count(distinct vin) over(partition by region_name, status) as total_vins -- for each region and status, I want the total number of vehicles in that status
from vehicle_statuses
order by region_name, status, vin
