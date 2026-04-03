select
    apd.id,
    apd.connected_account_id,
    apd.created,
    apd.domain_name,
    apd.livemode,
    apd._fivetran_synced
from {{ source('analytics_stripe_vsg_resla_com', 'apple_pay_domain') }} as apd
