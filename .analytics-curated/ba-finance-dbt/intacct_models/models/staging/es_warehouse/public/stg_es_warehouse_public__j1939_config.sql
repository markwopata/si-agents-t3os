SELECT
    jc.j1939_config_id,
    jc.config_name,
    jc.config_description
FROM {{ source('es_warehouse_public', 'j1939_config') }} as jc
