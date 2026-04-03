SELECT
    tspfdu.company_id,
    tspfdu.utilization_date,
    tspfdu.fleet_hours_added,
    tspfdu.tsp_fleet_size
FROM {{ source('es_warehouse_public', 'telematics_service_providers_fleet_daily_utilization') }} as tspfdu
