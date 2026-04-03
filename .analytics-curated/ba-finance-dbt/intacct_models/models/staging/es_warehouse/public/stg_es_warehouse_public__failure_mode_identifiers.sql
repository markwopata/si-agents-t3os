SELECT
    fmi.failure_mode_identifier_id,
    fmi.description,
    fmi._es_update_timestamp
FROM {{ source('es_warehouse_public', 'failure_mode_identifiers') }} as fmi
