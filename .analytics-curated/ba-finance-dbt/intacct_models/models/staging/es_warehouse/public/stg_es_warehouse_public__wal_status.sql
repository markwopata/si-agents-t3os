SELECT
    ws.wal_status_id,
    ws.wal_status,
    ws.active
FROM {{ source('es_warehouse_public', 'wal_status') }} as ws
