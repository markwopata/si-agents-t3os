SELECT
    wof.work_order_file_id,
    wof.url,
    wof.created_by,
    wof.date_deleted,
    wof.metadata_id,
    wof.work_order_id,
    wof.date_created,
    wof.date_updated,
    wof._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_files') }} as wof
