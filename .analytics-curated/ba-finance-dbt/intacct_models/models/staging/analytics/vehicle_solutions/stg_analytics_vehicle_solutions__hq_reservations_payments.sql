select
    hrp.payment_id,
    hrp.reservation_id,
    hrp.prefixed_id,
    hrp.amount,
    hrp.reference,
    hrp.authorization_or_payment,
    hrp.payment_type,
    hrp.payment_date,
    hrp.approved_status,
    hrp.payment_status,
    hrp.transaction_id,
    hrp.transaction_description,
    hrp.external_transaction_id,
    hrp._es_update_timestamp
from {{ ref('base_analytics_vehicle_solutions__hq_reservations_payments') }} as hrp
qualify row_number() over (partition by hrp.payment_id order by hrp._es_update_timestamp desc) = 1
