select
    dbt.dispute_id,
    dbt.balance_transaction_id,
    dbt._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'dispute_balance_transaction') }} as dbt
