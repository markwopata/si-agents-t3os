select
    f.balance_transaction_id,
    f.index,
    f.connected_account_id,
    f.amount as amount_in_cents,
    round(f.amount / 100.0, 2) as amount,
    f.application,
    f.currency,
    f.description,
    f.type,
    f._fivetran_synced
from {{ source('analytics_stripe_vsg_charge_key', 'fee') }} as f
