select
    dbt.dispute_id,
    dbt.balance_transaction_id,
    dbt._fivetran_synced
from {{ source('analytics_stripe_vsg_charge_key', 'dispute_balance_transaction') }} as dbt
