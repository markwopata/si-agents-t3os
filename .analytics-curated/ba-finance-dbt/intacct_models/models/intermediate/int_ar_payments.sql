with cte as (
    select 
        paid_item_key
        , min(payment_date) as min_payment_date
        , max(payment_date) as most_recent_payment_date
        , sum(amount) as total_amount_paid
    from  {{ ref('stg_analytics_intacct__ar_invoice_payment') }}
    group by 
        1
)

select 
      h.customer_id
    , h.invoice_number
    , h.invoice_id
    , h.ar_header_type
    , h.customer_name
    , h.invoice_state
    , h.gl_date
    , h.due_date
    , h.invoice_date
    , h.account_number
    , h.amount
    , h.line_description
    , h.ar_line_type
    , ip.total_amount_paid
    , ip.most_recent_payment_date
    , ip.min_payment_date
    , case
        when datediff('d', h.due_date, current_date)  < 30  then 'current'
        when (invoice_number is null or invoice_number like 'CR%')  then 'current'
        when ip.paid_item_key is not null then 'current'

        when datediff('d', h.due_date, current_date) between 31 and 60   then '31_60_days_past_due'

        when datediff('d', h.due_date, current_date) between 61 and 90  then '61_90_days_past_due'

        when datediff('d', h.due_date, current_date) between 91 and 120   then '91_120_days_past_due'

        when datediff('d', h.due_date, current_date) > 120   then '120_days_past_due'
    end as days_past_due_category
from {{ ref('ar_detail') }} h
left join cte ip
    on h.pk_ar_detail_id = ip.paid_item_key