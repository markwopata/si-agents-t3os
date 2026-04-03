select
    ta.type,
    ta.type_id,
    ta.index,
    ta.tax_rate_id,
    ta.amount as amount_in_cents,
    round(ta.amount / 100.0, 2) as amount,
    ta.taxability_reason,
    ta.taxable_amount,
    ta.inclusive,
    ta._fivetran_synced
from {{ source('analytics_stripe_vsg_charge_key', 'tax_amount') }} as ta
