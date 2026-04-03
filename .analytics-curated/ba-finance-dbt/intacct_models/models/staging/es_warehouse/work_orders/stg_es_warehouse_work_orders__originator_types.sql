SELECT
    ot.originator_type_id,
    ot.name,
    ot._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'originator_types') }} as ot
