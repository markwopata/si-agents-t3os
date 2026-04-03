select
    f.payment_method_id,
    f.bank,
    f._fivetran_synced
from {{ source('analytics_stripe_vsg_charge_key', 'fpx') }} as f
