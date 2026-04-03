select
    cd.id,
    cd.end as date_end,
    cd."START" as date_start,
    cd.promotion_code,
    cd.checkout_session,
    cd.coupon_id,
    cd.invoice_item_id,
    cd.customer_id,
    cd.subscription_id,
    cd.invoice_id,
    cd._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'customer_discount') }} as cd
