SELECT
    mgi.maintenance_group_interval_id,
    mgi.service_interval_id,
    mgi.maintenance_group_id,
    mgi.description,
    mgi.name,
    mgi.delete_date,
    mgi.trigger_from_due,
    mgi.warn_from_due,
    mgi.usage_warn_from_due,
    mgi.secondary_usage_trigger_from_due,
    mgi.secondary_usage_warn_from_due,
    mgi.usage_trigger_from_due,
    mgi.date_created,
    mgi.date_updated,
    mgi._es_update_timestamp
FROM {{ source('es_warehouse_public', 'maintenance_group_intervals') }} as mgi
