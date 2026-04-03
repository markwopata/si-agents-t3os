select
    ct.id,
    ct.country,
    ct.created,
    ct.livemode,
    ct.type,
    ct.value,
    ct.object,
    ct.verification_status,
    ct.verification_verified_address,
    ct.verification_verified_name,
    ct.owner_type,
    ct.owner_account_id,
    ct.owner_customer_id,
    ct.customer_id,
    ct._fivetran_synced
from {{ source('analytics_stripe_vsg_resla_com', 'customer_tax') }} as ct
