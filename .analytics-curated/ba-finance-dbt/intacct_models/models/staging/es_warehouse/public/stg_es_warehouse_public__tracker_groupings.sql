SELECT
    tg.tracker_type_id,
    tg.tracker_vendor,
    tg.tracker_type,
    tg.tracker_grouping
FROM {{ source('es_warehouse_public', 'tracker_groupings') }} as tg
