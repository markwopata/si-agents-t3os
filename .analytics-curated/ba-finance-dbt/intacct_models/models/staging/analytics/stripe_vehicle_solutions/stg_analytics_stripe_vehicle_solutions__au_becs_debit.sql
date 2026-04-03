select
    abd.payment_method_id,
    abd.bsb_number,
    abd.fingerprint,
    abd.last_4,
    abd._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'au_becs_debit') }} as abd
