SELECT
    vsu.vehicle_state_usage_id,
    vsu.report_date,
    vsu.miles_driven,
    vsu.state_id,
    vsu.asset_id,
    vsu._es_update_timestamp
FROM {{ source('es_warehouse_public', 'vehicle_state_usage') }} as vsu
