select
    cpmd.charge_id,
    cpmd.payment_method_type,
    cpmd.value,
    cpmd._fivetran_synced
from {{ source('analytics_stripe_vsg_charge_key', 'charge_payment_method_details') }} as cpmd
