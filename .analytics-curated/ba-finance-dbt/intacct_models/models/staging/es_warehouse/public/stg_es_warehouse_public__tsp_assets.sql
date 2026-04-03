SELECT
    ta.company_name,
    ta.company_id,
    ta.asset_id,
    ta.custom_name,
    ta.description,
    ta.year,
    ta.model,
    ta.tracker_id,
    ta.make,
    ta.hours,
    ta.odometer,
    ta.device_serial,
    ta.tracker_name,
    ta.category_id,
    ta.date_created,
    ta.date_updated
FROM {{ source('es_warehouse_public', 'tsp_assets') }} as ta
