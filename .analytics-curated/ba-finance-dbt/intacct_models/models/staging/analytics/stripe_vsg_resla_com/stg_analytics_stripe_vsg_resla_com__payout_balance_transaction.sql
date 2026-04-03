select
    pbt.payout_id,
    pbt.balance_transaction_id,
    pbt._fivetran_synced
from {{ source('analytics_stripe_vsg_resla_com', 'payout_balance_transaction') }} as pbt
