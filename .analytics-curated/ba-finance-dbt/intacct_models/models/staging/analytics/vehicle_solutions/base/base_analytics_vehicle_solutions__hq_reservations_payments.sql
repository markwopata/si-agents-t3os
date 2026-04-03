select
    hrpl.payment_id,
    hrpl.reservation_id,
    hrpl.prefixed_id,
    hrpl.amount,
    hrpl.reference,
    hrpl.authorization_or_payment,
    hrpl.payment_type,
    hrpl.payment_date,
    hrpl.approved_status,
    hrpl.payment_status,
    hrpl.transaction_id,
    hrpl.transaction_description,
    hrpl.external_transaction_id,
    hrpl._es_update_timestamp
from {{ source('analytics_vehicle_solutions', 'hq_reservations_payments__landing') }} as hrpl
