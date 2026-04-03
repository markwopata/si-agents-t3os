SELECT
    askvho.asset_status_key_value_id,
    askvho.asset_id,
    askvho.asset_status_value_type_id,
    askvho.name,
    askvho.value,
    askvho.value_timestamp,
    askvho.updated,
    askvho._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_status_key_values_history_old') }} as askvho
