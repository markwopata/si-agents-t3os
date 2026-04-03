select
    reservation_id,
    date_trunc('day', earning_date) as earning_date,
    sum(case
        when lower(reason) like '%reimbursement%' then -amount
        else amount
    end) as trip_earnings_amount -- total trip earnings amount - matches Turo HQ interface value
from {{ ref('stg_analytics_vehicle_solutions__turo_earnings') }}
group by
    1, 2
