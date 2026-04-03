select
    cbt.id,
    cbt.amount as amount_in_cents,
    round(cbt.amount / 100.0, 2) as amount,
    cbt.created,
    cbt.currency,
    cbt.credit_note,
    cbt.description,
    cbt.ending_balance,
    cbt.livemode,
    cbt.metadata,
    cbt.type,
    cbt.customer_id,
    cbt.invoice_id,
    cbt._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'customer_balance_transaction') }} as cbt
