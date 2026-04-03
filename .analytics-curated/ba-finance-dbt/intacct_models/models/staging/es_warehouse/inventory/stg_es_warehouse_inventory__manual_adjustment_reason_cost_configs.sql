SELECT
    marcc._es_load_timestamp,
    marcc.manual_adjustment_reason_cost_config_id,
    marcc.config,
    marcc.description,
    marcc._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'manual_adjustment_reason_cost_configs') }} as marcc
