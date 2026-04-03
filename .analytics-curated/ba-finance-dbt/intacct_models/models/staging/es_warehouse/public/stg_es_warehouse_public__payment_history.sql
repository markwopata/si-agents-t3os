SELECT
    ph.payment_history_id,
    ph.payment_id,
    ph.user_id,
    ph.date,
    ph.type,
    ph.amount,
    ph.description,
    ph.payment_application_reversal_reason_id,
    ph.payment_portal_id,
    ph.field_changes,
    ph._es_update_timestamp
FROM {{ source('es_warehouse_public', 'payment_history') }} as ph
