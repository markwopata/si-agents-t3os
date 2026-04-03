SELECT
    hua.hours_update_audit_id,
    hua.asset_id,
    hua.tracking_event_id,
    hua.old_hours,
    hua.new_hours,
    hua.time_accumulator,
    hua.created,
    hua.user_id,
    hua.application_name,
    hua._es_update_timestamp
FROM {{ source('es_warehouse_public', 'hours_update_audit') }} as hua
