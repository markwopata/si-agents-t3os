select
    cnrr._es_load_timestamp,
    cnrr.credit_note_request_reason_id,
    cnrr.requires_note,
    cnrr.description,
    cnrr.active,
    cnrr._es_update_timestamp
from {{ source('es_warehouse_public', 'credit_note_request_reasons') }} as cnrr
