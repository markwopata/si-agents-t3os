select
    sr.id,
    sr.active,
    sr.display_name,
    sr.amount as amount_in_cents,
    round(sr.amount / 100.0, 2) as amount,
    sr.currency,
    sr.type,
    sr.created,
    sr.delivery_estimate_maximum_unit,
    sr.delivery_estimate_maximum_value,
    sr.delivery_estimate_minimum_unit,
    sr.delivery_estimate_minimum_value,
    sr.livemode,
    sr.tax_behavior,
    sr.tax_code,
    sr._fivetran_synced
from {{ source('analytics_stripe_vsg_resla_com', 'shipping_rate') }} as sr
