with snapshot as (

    select * from {{ ref('scd2_analytics_vsg_postgres__public__reservations') }}

),

regions as (

    select * from {{ ref('stg_analytics_vsg_postgres__public__regions') }}

),

vehicles as (

    select * from {{ ref('stg_analytics_vsg_postgres__public__vehicles') }}

),

clean_columns as (
    -- added additional columns to the snapshot, so need to clean those columns for historical records. 
    -- https://gitlab.internal.equipmentshare.com/business-intelligence/ba-finance-dbt/-/merge_requests/1187

    select
        s.dbt_scd_id,
        s.id,
        s.reservation_id,
        s.confirm_insurance,
        s.confirm_license,
        s.phone,
        s.vehicle_vin,
        v.status as vehicle_status,
        v.notes as vehicle_notes,
        s.email,
        s.customer_first_name,
        s.return_at,
        s.pickup_at,
        s.pickup_location,
        s.return_location,
        s.pickup_timezone,
        s.return_timezone,
        s.status,
        s.vehicle_model,
        s.customer_last_name,
        s.prefixed_id,
        s.pickup_location_id,
        s.return_location_id,
        s.vehicle_class,
        s.payment_balance,
        s.security_balance,
        s.platform,
        s.platform_id,
        s.notes,
        s.region_id,
        r.name as region_name,
        s.created_at,
        s.billing_complete,
        s.pickup_photos,
        s.return_photos,
        s.return_user_id,
        s.pickup_user_id,
        s.upload_return_photos,
        s.upload_pickup_photos,
        s.damage_waiver,
        s.charging_balance,
        s.charging_method,
        s.late,
        s.extended,
        s.returned_at,
        s.picked_up_at,
        s.updated_at,
        s.return_schedule_priority,
        s.pickup_schedule_priority,
        s.collections_status,
        s.gclid,
        s.tesla_rents_id,
        s.is_expired,
        s._fivetran_deleted,
        s._fivetran_synced,
        s.created_by_service,
        s.dbt_updated_at,
        date_trunc('day', s.dbt_updated_at) as dbt_snapshot_date,
        s.dbt_valid_from,
        s.dbt_valid_to,
        convert_timezone(s.pickup_timezone, s.pickup_at) as pickup_at_local_tz,
        date_trunc('day', convert_timezone(s.pickup_timezone, s.pickup_at)::timestamp) as pick_up_date,
        s.picked_up_at is not null as is_rented
    from snapshot as s
        left join regions as r
            on s.region_id = r.id
        left join vehicles as v
            on s.vehicle_vin = v.vin
)

select * from clean_columns
