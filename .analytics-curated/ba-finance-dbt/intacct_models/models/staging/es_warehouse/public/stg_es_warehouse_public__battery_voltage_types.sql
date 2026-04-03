SELECT
    bvt.battery_voltage_type_id,
    bvt.threshold,
    bvt.name,
    bvt.is_internal,
    bvt._es_update_timestamp,
    bvt.threshold:"include_lower" AS threshold__include_lower,
    bvt.threshold:"include_upper" AS threshold__include_upper,
    bvt.threshold:"lower_bound" AS threshold__lower_bound,
    bvt.threshold:"upper_bound" AS threshold__upper_bound
FROM {{ source('es_warehouse_public', 'battery_voltage_types') }} as bvt
