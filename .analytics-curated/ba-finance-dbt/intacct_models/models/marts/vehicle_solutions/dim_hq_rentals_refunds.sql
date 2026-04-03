with stripe_charges as (

    select * from {{ ref('stg_analytics_stripe_vehicle_solutions__charge') }}

),

stripe_refunds as (

    select * from {{ ref('stg_analytics_stripe_vehicle_solutions__refund') }}

)

select
    c.reservation_id,
    date_trunc('day', r.created) as refund_date,
    array_agg(c.receipt_url) as receipt_urls,
    sum(r.amount) as total_refund_amount
from stripe_charges as c
    inner join stripe_refunds as r
        on c.id = r.charge_id
group by
    1,2