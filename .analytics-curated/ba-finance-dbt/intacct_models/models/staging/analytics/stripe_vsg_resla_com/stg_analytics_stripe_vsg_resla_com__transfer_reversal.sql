select
    tr.id,
    tr.amount as amount_in_cents,
    round(tr.amount / 100.0, 2) as amount,
    tr.created,
    tr.currency,
    tr.destination_payment_refund,
    tr.metadata,
    tr.balance_transaction_id,
    tr.source_refund_id,
    tr.transfer_id,
    tr._fivetran_synced
from {{ source('analytics_stripe_vsg_resla_com', 'transfer_reversal') }} as tr
