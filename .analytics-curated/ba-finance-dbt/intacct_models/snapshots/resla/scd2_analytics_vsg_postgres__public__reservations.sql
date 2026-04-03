{% snapshot scd2_analytics_vsg_postgres__public__reservations %}

{{
    config(
        target_database=generate_database_name(),
        unique_key="id",
        strategy='timestamp',
        updated_at='_fivetran_synced',
        invalidate_hard_deletes=True
    )
}}

select
    r.id,
    regexp_substr(r.prefixed_id, '\\d+$')::int as reservation_id,
    r.confirm_insurance,
    r.confirm_license,
    r.phone,
    r.vehicle_vin,
    r.email,
    r.customer_first_name,
    r.return_at,
    r.pickup_at,
    convert_timezone(pickup_timezone, r.pickup_at) as pickup_at_local_tz, -- pickup_at is in UTC. This converts it to the local time zone of the pickup location for when reservations are "actually" picked up.
    r.picked_up_at is not null as is_rented, -- if the reservation has been picked up, then it is currently on rent
    r.pickup_location,
    r.return_location,
    r.pickup_timezone,
    r.return_timezone,
    r.status,
    r.vehicle_model,
    r.customer_last_name,
    r.prefixed_id,
    r.pickup_location_id,
    r.return_location_id,
    r.vehicle_class,
    r.payment_balance,
    r.security_balance,
    r.platform,
    r.platform_id,
    r.notes,
    r.region_id,
    r.created_at,
    r.billing_complete,
    r.pickup_photos,
    r.return_photos,
    r.return_user_id,
    r.pickup_user_id,
    r.upload_return_photos,
    r.upload_pickup_photos,
    r.damage_waiver,
    r.charging_balance,
    r.charging_method,
    r.late,
    r.extended,
    r.returned_at,
    r.picked_up_at,
    r.updated_at,
    r.return_schedule_priority,
    r.pickup_schedule_priority,
    r.collections_status,
    r.gclid,
    r.tesla_rents_id,
    r.is_expired,
    r._fivetran_deleted,
    r._fivetran_synced,
    r.created_by_service
from {{ source('analytics_vsg_postgres__public', 'reservations') }} as r
{% endsnapshot %}
