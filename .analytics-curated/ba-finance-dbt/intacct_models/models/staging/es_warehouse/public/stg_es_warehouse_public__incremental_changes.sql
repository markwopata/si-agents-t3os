SELECT
    ic.incremental_changes_id,
    ic.changes,
    ic.processed
FROM {{ source('es_warehouse_public', 'incremental_changes') }} as ic
