SELECT
    pa.asset_id,
    pa.serial_number,
    pa.equipment_make_id,
    pa.make,
    pa.equipment_model_id,
    pa.model,
    pa.company_id,
    pa.company_name
FROM {{ source('es_warehouse_public', 'podio_assets') }} as pa
