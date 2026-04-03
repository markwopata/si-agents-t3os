select
    t.id,
    t.amount as amount_in_cents,
    round(t.amount / 100.0, 2) as amount,
    t.created,
    t.currency,
    t.description,
    t.expected_availability_date,
    t.failure_code,
    t.failure_message,
    t.livemode,
    t.metadata,
    t.statement_descriptor,
    t.status,
    t.transfer_group,
    t.source_id,
    t.balance_transaction_id,
    t._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'topup') }} as t
