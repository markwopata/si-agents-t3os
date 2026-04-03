SELECT
    ppn.provider_part_number_id,
    ppn.provider_id,
    ppn.part_number,
    ppn.date_created,
    ppn.date_updated,
    ppn._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'provider_part_numbers') }} as ppn
