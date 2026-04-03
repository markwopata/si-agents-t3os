select
    afr.id,
    afr.amount as amount_in_cents,
    round(afr.amount / 100.0, 2) as amount,
    afr.created,
    afr.currency,
    afr.metadata,
    afr.balance_transaction_id,
    afr.application_fee_id,
    afr._fivetran_synced
from {{ source('analytics_stripe_vsg_charge_key', 'application_fee_refund') }} as afr
