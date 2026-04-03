with payments as (
    select * from {{ ref('stg_es_warehouse_public__payments') }}
),

payment_applications as (
    select * from {{ ref('stg_es_warehouse_public__payment_applications') }}
)

-- payment application --
select
    pa.payment_application_id as payment_application_id,
    p.payment_id as payment_id,
    pa.invoice_id as invoice_id,
    pa.amount as amount,
    pa.user_id as user_id,
    p.payment_date as date,
    pa.reversed_date,
    pa.reversed_by_user_id,
    pa.reversal_reason,
    p._es_update_timestamp as _es_update_timestamp,
    pa.payment_application_reversal_reason_id as payment_application_reversal_reason_id
from payments as p
left join payment_applications as pa on pa.payment_id = p.payment_id
where
    pa.payment_application_id is not null
order by p.date_created desc
