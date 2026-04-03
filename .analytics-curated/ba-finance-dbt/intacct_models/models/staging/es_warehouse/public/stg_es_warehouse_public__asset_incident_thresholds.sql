SELECT
    ait.asset_incident_threshold_id,
    ait.company_id,
    ait.asset_id,
    ait.asset_incident_threshold_field_id,
    ait.exceeded_value_range,
    ait.date_deactivated,
    ait.notify_operator,
    ait.date_created,
    ait._es_update_timestamp,
    ait.exceeded_value_range:"include_upper" AS exceeded_value_range__include_upper,
    ait.exceeded_value_range:"upper_bound" AS exceeded_value_range__upper_bound,
    ait.exceeded_value_range:"include_lower" AS exceeded_value_range__include_lower,
    ait.exceeded_value_range:"lower_bound" AS exceeded_value_range__lower_bound
FROM {{ source('es_warehouse_public', 'asset_incident_thresholds') }} as ait
