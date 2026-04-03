SELECT
    askv.asset_status_key_value_id,
    askv.asset_id,
    askv.asset_status_value_type_id,
    askv.name,
    askv.value,
    askv.value_timestamp,
    askv.updated,
    askv._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_status_key_values') }} as askv
