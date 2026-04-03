select
    i.payment_method_id,
    i.bank,
    i.bic,
    i._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'ideal') }} as i
