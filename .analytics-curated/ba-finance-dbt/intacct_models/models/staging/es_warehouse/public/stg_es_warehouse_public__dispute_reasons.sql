SELECT
    dr._es_load_timestamp,
    dr.dispute_reason_id,
    dr.active,
    dr.description,
    dr._es_update_timestamp
FROM {{ source('es_warehouse_public', 'dispute_reasons') }} as dr
