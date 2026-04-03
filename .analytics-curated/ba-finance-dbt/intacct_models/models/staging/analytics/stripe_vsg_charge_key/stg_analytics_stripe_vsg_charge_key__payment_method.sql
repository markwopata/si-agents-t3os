select
    pm.id,
    pm.billing_detail_address_city,
    pm.billing_detail_address_country,
    pm.billing_detail_address_line_1,
    pm.billing_detail_address_line_2,
    pm.billing_detail_address_postal_code,
    pm.billing_detail_address_state,
    pm.billing_detail_email,
    pm.billing_detail_name,
    pm.billing_detail_phone,
    pm.created as date_created,
    pm.livemode as is_livemode,
    pm.metadata,
    pm.type,
    pm.customer_id,
    pm._fivetran_synced
from {{ source('analytics_stripe_vsg_charge_key', 'payment_method') }} as pm
