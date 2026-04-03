select
    ur.id,
    ur.timestamp,
    ur.period_start,
    ur.period_end,
    ur.total_usage,
    ur.livemode,
    ur.invoice_id,
    ur.subscription_item_id,
    ur._fivetran_synced
from {{ source('analytics_stripe_vsg_charge_key', 'usage_record') }} as ur
