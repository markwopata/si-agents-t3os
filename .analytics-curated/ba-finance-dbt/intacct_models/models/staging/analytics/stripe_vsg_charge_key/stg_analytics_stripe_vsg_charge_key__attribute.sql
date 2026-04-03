select
    a.id,
    a.name,
    a.value,
    a._fivetran_synced
from {{ source('analytics_stripe_vsg_charge_key', 'attribute') }} as a
