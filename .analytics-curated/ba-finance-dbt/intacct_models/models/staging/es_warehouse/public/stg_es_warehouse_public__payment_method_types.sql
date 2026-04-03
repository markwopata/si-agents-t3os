SELECT
    pmt._es_load_timestamp,
    pmt.payment_method_type_id,
    pmt.name,
    pmt.active,
    pmt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'payment_method_types') }} as pmt
