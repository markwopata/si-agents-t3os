select
    cns.credit_note_status_id,
    cns.name as credit_note_status_name,
    cns._es_update_timestamp,
    cns._es_load_timestamp
from {{ source('es_warehouse_public', 'credit_note_statuses') }} as cns
