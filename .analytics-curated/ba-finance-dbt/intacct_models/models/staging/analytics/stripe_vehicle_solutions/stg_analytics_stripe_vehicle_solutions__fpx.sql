select
    f.payment_method_id,
    f.bank,
    f._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'fpx') }} as f
