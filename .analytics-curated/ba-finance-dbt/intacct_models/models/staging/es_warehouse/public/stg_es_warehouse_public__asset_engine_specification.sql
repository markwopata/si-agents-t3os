SELECT
    aes.asset_engine_specification_id,
    aes.asset_id,
    aes.engine_make_id,
    aes.engine_model_name,
    aes.engine_serial_number,
    aes._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_engine_specification') }} as aes
