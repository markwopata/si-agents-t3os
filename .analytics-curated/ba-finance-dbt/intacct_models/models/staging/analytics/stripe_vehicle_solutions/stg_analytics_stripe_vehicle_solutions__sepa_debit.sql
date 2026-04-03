select
    sd.payment_method_id,
    sd.bank_code,
    sd.branch_code,
    sd.country,
    sd.fingerprint,
    sd.last_4,
    sd._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'sepa_debit') }} as sd
