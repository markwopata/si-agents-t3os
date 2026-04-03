select 
    bis.bulk_import_session_id,
    bis.note,
    bis.imported_by,
    bis.reverted_by,
    bis.date_created,
    bis.date_reverted,
    bis._es_update_timestamp
from {{ source('es_warehouse_inventory', 'bulk_import_sessions')}} bis
