with las_asset_payment_schedule as (
    select * from {{ ref('int_payment_schedules_pivoted_to_assets') }}
)

select
    asset_type,
    payment_date::date as payment_date,
    date_trunc(month, payment_date) as period_start_date,
    round(sum(amount_paid), 2) as amount_paid,
    md5(concat(asset_type, payment_date)) as pk_lease_accelerator_payment_schedule_id
from las_asset_payment_schedule
group by
    all
