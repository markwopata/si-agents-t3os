SELECT
    hf.asset_usage_id,
    hf.asset_id,
    hf.miles_driven,
    hf.on_time,
    hf.hauled_time,
    hf.hauling_time,
    hf.idle_time,
    hf.hauled_distance,
    hf.hauling_distance,
    hf.report_range,
    hf.source_metadata,
    hf._es_update_timestamp,
    hf.report_range:"end_range" AS report_range__end_range,
    hf.report_range:"start_range" AS report_range__start_range,
    hf.source_metadata:"trip_ids" AS source_metadata__trip_ids,
    hf.source_metadata:"asset_idle_ids" AS source_metadata__asset_idle_ids
FROM {{ source('es_warehouse_public', 'hau_fix') }} as hf
