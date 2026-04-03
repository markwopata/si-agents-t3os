SELECT
    rudg.asset_id,
    rudg.company_id,
    rudg.year,
    rudg.equipment_make_id,
    rudg.model,
    rudg.name,
    rudg.billing_location_id,
    rudg.city,
    rudg.state,
    rudg.zip_code,
    rudg.total_utilized_time
FROM {{ source('es_warehouse_public', 'rpt_utilization_dashboard_genie') }} as rudg
