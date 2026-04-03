SELECT
    spn.suspect_parameter_number_id,
    spn.description,
    spn._es_update_timestamp
FROM {{ source('es_warehouse_public', 'suspect_parameter_numbers') }} as spn
