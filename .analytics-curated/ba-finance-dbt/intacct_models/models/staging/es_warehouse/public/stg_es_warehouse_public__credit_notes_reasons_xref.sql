select
    cnrx.credit_notes_reasons_xref_id,
    cnrx.credit_note_id,
    cnrx.notes,
    cnrx.credit_note_request_reason_id,
    cnrx._es_update_timestamp,
    cnrx._es_load_timestamp
from {{ source('es_warehouse_public', 'credit_notes_reasons_xref') }} as cnrx
