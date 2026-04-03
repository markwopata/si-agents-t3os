with ar_payments as (
    select * from {{ ref('int_ar_payments') }}
),

ar_customer_aging as (
    select
        customer_id,
        days_past_due_category,
        sum(amount) as amount_age,
        count(
            distinct case
                when
                    ar_header_type = 'arinvoice' and invoice_state = 'Posted' or invoice_state = 'Partially Paid'
                    then invoice_number
            end
        ) as count_invoices
    from ar_payments
    -- where customer_id ='100511' 
    group by
        all
),

ar_customer_aging_pivot as (
    select
        customer_id,

        -- current bucket
        sum(case when days_past_due_category = 'current' then amount_age else 0 end) as current_amount_invoices,
        sum(case when days_past_due_category = 'current' then count_invoices else 0 end) as current_count_invoices,

        -- 31 - 60 bucket
        sum(case when days_past_due_category = '31_60_days_past_due' then amount_age else 0 end)
            as _31_60_days_past_due_amount_invoices,
        sum(case when days_past_due_category = '31_60_days_past_due' then count_invoices else 0 end)
            as _31_60_days_past_due_count_invoices,

        -- 61 - 90 bucket
        sum(case when days_past_due_category = '61_90_days_past_due' then amount_age else 0 end)
            as _61_90_days_past_due_amount_invoices,
        sum(case when days_past_due_category = '61_90_days_past_due' then count_invoices else 0 end)
            as _61_90_days_past_due_count_invoices,

        -- 91 - 120 bucket
        sum(case when days_past_due_category = '91_120_days_past_due' then amount_age else 0 end)
            as _91_120_days_past_due_amount_invoices,
        sum(case when days_past_due_category = '91_120_days_past_due' then count_invoices else 0 end)
            as _91_120_days_past_due_count_invoices,

        -- 120+ bucket
        sum(case when days_past_due_category = '120_days_past_due' then amount_age else 0 end)
            as _120_days_past_due_amount_invoices,
        sum(case when days_past_due_category = '120_days_past_due' then count_invoices else 0 end)
            as _120_days_past_due_count_invoices

    from ar_customer_aging
    group by
        1
),

companies_info as (
    select
        company_id,
        do_not_rent_flag,
        credit_limit
    from {{ ref('stg_es_warehouse_public__companies') }}
),

d_invoices as (
    select
        invoice_id,
        invoice_number,
        invoice_date,
        credit_note_id,
        url_admin
    from {{ ref('dim_ar_invoices') }}
),

invoice_amount as (
    select
        invoice_id,
        customer_id,
        invoice_number,
        invoice_amount
    from {{ ref('fct_invoice_number_amount') }}
),

customer_balance_measures as (
    select
        customer_id,
        sum(case when ar_header_type = 'arinvoice' then amount else 0 end) as invoice_amount,
        sum(case when ar_header_type = 'aradjustment' then amount else 0 end) as adjustment_amount,
        sum(case when ar_header_type = 'aradvance' then amount else 0 end) as advance_amount,
        sum(case when ar_header_type = 'arpayment' then amount else 0 end) as payment_amount
    from {{ ref('ar_detail') }}
    group by
        1
),

cte as (
    select distinct
        p.customer_id,
        i.credit_limit,
        -- adding the amounts since adjustments, advances, and payments are negative
        m.invoice_amount + m.adjustment_amount + m.advance_amount + m.payment_amount as customer_total_balance_owed,
        m.invoice_amount
        + m.adjustment_amount
        + m.advance_amount
        + m.payment_amount
        - coalesce(i.credit_limit, 0) as amount_overextended,

        -- current bucket
        piv.current_amount_invoices,
        piv.current_count_invoices,

        -- 31-60 bucket
        piv._31_60_days_past_due_amount_invoices,
        piv._31_60_days_past_due_count_invoices,

        -- 61-90 bucket
        piv._61_90_days_past_due_amount_invoices,
        piv._61_90_days_past_due_count_invoices,

        -- 91-120 bucket
        piv._91_120_days_past_due_amount_invoices,
        piv._91_120_days_past_due_count_invoices,

        -- 120+ bucket
        piv._120_days_past_due_amount_invoices,
        piv._120_days_past_due_count_invoices
    from ar_payments as p
        inner join companies_info as i
            on p.customer_id::text = i.company_id::text
        inner join d_invoices as di
            on p.invoice_id = di.invoice_id
        inner join invoice_amount as f
            on di.invoice_id = f.invoice_id
        inner join customer_balance_measures as m
            on p.customer_id = m.customer_id
        inner join ar_customer_aging_pivot as piv
            on p.customer_id = piv.customer_id
-- where p.customer_id = '100511'

)

select * from cte
