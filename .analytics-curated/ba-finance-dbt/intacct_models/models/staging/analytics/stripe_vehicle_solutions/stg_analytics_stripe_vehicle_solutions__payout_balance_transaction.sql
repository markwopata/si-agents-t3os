select
    pbt.payout_id,
    pbt.balance_transaction_id,
    pbt._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'payout_balance_transaction') }} as pbt
