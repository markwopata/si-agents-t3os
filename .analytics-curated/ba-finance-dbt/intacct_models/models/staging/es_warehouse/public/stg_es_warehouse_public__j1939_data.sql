SELECT
    jd.j1939_data_id,
    jd.tracking_event_id,
    jd.tracker_id,
    jd.spn,
    jd.pgn,
    jd.value,
    jd.report_timestamp,
    jd.asset_id,
    jd.pgn_group_id,
    jd.date_created,
    jd._es_update_timestamp
FROM {{ source('es_warehouse_public', 'j1939_data') }} as jd
