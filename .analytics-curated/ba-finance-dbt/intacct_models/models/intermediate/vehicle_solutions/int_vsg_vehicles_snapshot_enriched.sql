with vehicle_snapshot as (

    select * from {{ ref('scd2_analytics_vsg_postgres__public__vehicles') }}

),

regions as (

    select * from {{ ref('stg_analytics_vsg_postgres__public__regions') }}

),

vehicles_latest_return_date as (

    select
        vehicle_vin,
        max(returned_at) as latest_return_date
    from {{ ref('int_vsg_reservations_snapshot_enriched') }}
    where 1 = 1
        and status in ('Returned', 'On Rent') -- only want to consider reservations rows that have last been returned or on rent. a reservation can be started, but have a return date for some reason, so we exclude those.
    group by 
        all

),

clean_columns as (

    select
        v.dbt_scd_id,
        v.id,
        v.vin,
        v.region_id,
        r.name as region_name,
        lrd.latest_return_date,
        datediff('day', lrd.latest_return_date, current_date()) as days_since_last_return,
        v.status,
        v.notes,
        v.cleaning_start,
        v.color,
        v.model,
        v.cleaning_end,
        v.license_plate,
        v.address,
        v.location_id,
        v.created_at,
        v.year,
        v.platform,
        v.polled_at,
        v.location_at,
        v.updated_at,
        v.battery_level,
        v.battery_range,
        v.charging_state,
        v.locked,
        v.odometer,
        v.state,
        v.latitude,
        v.longitude,
        v.front_driver_tread_depth,
        v.front_passenger_tread_depth,
        v.back_driver_tread_depth,
        v.back_passenger_tread_depth,
        v.rack_rate,
        v.purchase_value,
        v.model_id,
        v.license_plate_state,
        v.pickup_photos_at,
        v.show_on_website,
        v._fivetran_deleted,
        v._fivetran_synced,
        date_trunc('day', v.dbt_updated_at) as dbt_snapshot_date,
        v.dbt_valid_from,
        v.dbt_valid_to,
    from vehicle_snapshot as v
        left join regions as r
            on v.region_id = r.id
        left join vehicles_latest_return_date as lrd
            on v.vin = lrd.vehicle_vin
)

select * from clean_columns
