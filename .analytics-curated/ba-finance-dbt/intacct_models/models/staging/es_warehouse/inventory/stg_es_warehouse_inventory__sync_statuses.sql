SELECT
    ss.table_name,
    ss.last_id,
    ss.last_xmin,
    ss.domain_id,
    ss.inserted_on,
    ss.notes,
    ss.last_transformation_timestamp,
    ss.backfill_timestamp
FROM {{ source('es_warehouse_inventory', 'sync_statuses') }} as ss
