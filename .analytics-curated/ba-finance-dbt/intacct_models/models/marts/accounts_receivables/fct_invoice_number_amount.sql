with ar_detail as (
    select * from {{ ref('ar_detail') }}
)

select
    invoice_id,
    customer_id,
    invoice_number,
    sum(amount) as invoice_amount
from ar_detail
group by
    all
