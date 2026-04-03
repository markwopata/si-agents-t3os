with on_rent_reservations as (

    select 
        as_of_date,
        region_name,
        count(distinct reservation_id) as on_rent_reservations
    from {{ ref('vsg_reservations_daily_on_rent') }}
    group by
        all

)

, vehicle_snapshot as (

        select *
        from {{ ref('int_vsg_vehicles_snapshot_enriched') }}
        where 1 = 1
            and dbt_valid_to is null
            and status != 'Total Loss' -- if a vehicle is totaled, it is not available for rent. thus, don't count it as part of the total number of vins

)

, total_number_of_vins as (

    select
        current_date() as as_of_date,
        current_timestamp() as collected_at,
        region_name,
        count(distinct vin) as total_vins
    from vehicle_snapshot
    group by
        all

)

select
    v.as_of_date,
    v.collected_at,
    r.on_rent_reservations,
    v.total_vins,
    v.region_name,
    coalesce(round(r.on_rent_reservations / nullifzero(v.total_vins), 2)*100, 0) as region_on_rent_utilization,
    sum(r.on_rent_reservations) over() as cumulative_on_rent_reservations,
    sum(v.total_vins) over() as cumulative_total_vins,
    coalesce(round(cumulative_on_rent_reservations / nullifzero(cumulative_total_vins), 2)*100, 0) as on_rent_utilization
from total_number_of_vins v
left join on_rent_reservations r
    on v.as_of_date = r.as_of_date
    and v.region_name = r.region_name
where 1 = 1
