SELECT
    tspadu.asset_id,
    tspadu.company_id,
    tspadu.utilization_date,
    tspadu.hours_total,
    tspadu.hours_added
FROM {{ source('es_warehouse_public', 'telematics_service_providers_assets_daily_utilization') }} as tspadu
