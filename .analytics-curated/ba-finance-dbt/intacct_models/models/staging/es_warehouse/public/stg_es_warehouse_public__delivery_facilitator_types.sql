SELECT
    dft.delivery_facilitator_type_id,
    dft.name,
    dft._es_update_timestamp
FROM {{ source('es_warehouse_public', 'delivery_facilitator_types') }} as dft
