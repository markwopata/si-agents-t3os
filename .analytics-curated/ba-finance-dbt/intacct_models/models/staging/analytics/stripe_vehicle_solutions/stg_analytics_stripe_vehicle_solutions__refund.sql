select
    r.id,
    r.amount as amount_in_cents,
    round(r.amount / 100.0, 2) as amount,
    r.connected_account_id,
    r.created,
    r.currency,
    r.description,
    r.failure_reason,
    r.metadata,
    r.reason,
    r.receipt_number,
    r.status,
    r.balance_transaction_id,
    r.charge_id,
    r.failure_balance_transaction_id,
    r.payment_intent_id,
    r._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'refund') }} as r
