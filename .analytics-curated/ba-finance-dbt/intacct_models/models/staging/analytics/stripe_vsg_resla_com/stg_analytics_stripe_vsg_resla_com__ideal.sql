select
    i.payment_method_id,
    i.bank,
    i.bic,
    i._fivetran_synced
from {{ source('analytics_stripe_vsg_resla_com', 'ideal') }} as i
