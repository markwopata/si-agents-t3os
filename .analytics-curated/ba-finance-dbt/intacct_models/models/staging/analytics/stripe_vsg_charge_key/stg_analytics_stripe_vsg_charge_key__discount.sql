select
    d.id,
    d.amount as amount_in_cents,
    round(d.amount / 100.0, 2) as amount,
    d.end as date_end,
    d."START" as date_start,
    d.promotion_code,
    d.checkout_session_line_item_id,
    d.credit_note_line_item_id,
    d.coupon_id,
    d.invoice_item_id,
    d.checkout_session_id,
    d.customer_id,
    d.subscription_id,
    d.invoice_id,
    d.type,
    d.type_id,
    d._fivetran_synced
from {{ source('analytics_stripe_vsg_charge_key', 'discount') }} as d
