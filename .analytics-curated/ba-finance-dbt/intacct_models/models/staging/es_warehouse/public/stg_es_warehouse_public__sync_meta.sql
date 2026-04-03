SELECT
    sm.sync_meta_id,
    sm.table_name,
    sm.last_xmin,
    sm.new_row_count,
    sm.domain_id,
    sm.date_created
FROM {{ source('es_warehouse_public', 'sync_meta') }} as sm
