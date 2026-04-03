select
    pmc.payment_method_id,
    pmc.description,
    pmc.brand,
    pmc.fingerprint,
    pmc.funding,
    pmc.three_d_secure_usage_supported,
    pmc.type,
    pmc.charge_id,
    pmc.wallet_type,
    pmc._fivetran_synced
from {{ source('analytics_stripe_vsg_resla_com', 'payment_method_card') }} as pmc
