with payments as (
    select
        payment_applications.invoice_id,
        dateadd(month, 9, invoices.billing_approved_date) as bad_debt_date,
        sum(payment_applications.amount) as amount
    from {{ ref("stg_es_warehouse_public__payment_applications") }} as payment_applications
        inner join {{ ref("stg_es_warehouse_public__invoices") }} as invoices
            on payment_applications.invoice_id = invoices.invoice_id
    where
        payment_applications.reversed_date is null
        and payment_applications.date <= bad_debt_date
        and dateadd(
            month, 9, invoices.billing_approved_date
        ) between '{{ live_be_start_date() }}' and '{{ live_be_end_date() }}'
    group by 1, 2
),

credits as (
    select
        credit_note_allocations.invoice_id,
        dateadd(month, 9, invoices.billing_approved_date) as bad_debt_date,
        sum(credit_note_allocations.amount) as amount
    from {{ ref("stg_es_warehouse_public__credit_note_allocations") }} as credit_note_allocations
        inner join {{ ref("stg_es_warehouse_public__invoices") }} as invoices
            on credit_note_allocations.invoice_id = invoices.invoice_id
    where
        credit_note_allocations.reversal_date is null
        and credit_note_allocations.date_created <= bad_debt_date
        and dateadd(
            month, 9, invoices.billing_approved_date
        ) between '{{ live_be_start_date() }}' and '{{ live_be_end_date() }}'
    group by 1, 2
),

union_payments_and_credits as (
    select *
    from payments

    union all

    select *
    from credits
),

total_payments_and_credits as (
    select
        invoice_id,
        sum(amount) as amount
    from union_payments_and_credits
    group by 1
),

output as (
    select
        invoices.invoice_id,
        invoices.invoice_no,
        invoices.url_admin,
        dateadd(month, 9, invoices.billing_approved_date) as gl_date,
        coalesce(total_payments_and_credits.amount, 0) as amount,
        invoices.billed_amount,
        invoices.company_id,
        invoices.market_id,
        invoices.billed_amount - coalesce(total_payments_and_credits.amount, 0) as unpaid_amount,
        invoices.owed_amount
    from {{ ref("stg_es_warehouse_public__invoices") }} as invoices
        left join total_payments_and_credits as total_payments_and_credits
            on invoices.invoice_id = total_payments_and_credits.invoice_id
    where invoices.company_id not in ({{ es_companies() }})
        and invoices.company_id not in (6954, 55524)
)

select
    market_id,
    'IAAA' as account_number,
    'Invoice ID' as transaction_number_format,
    invoice_id::varchar as transaction_number,
    'Invoice #: ' || invoice_no || ' unpaid as of ' || gl_date::date as description,
    gl_date,
    'Invoice Number' as document_type,
    invoice_no as document_number,
    null as url_sage,
    null as url_concur,
    url_admin,
    null as url_t3,
    unpaid_amount * -0.5 as amount,
    object_construct(
        'invoice_id', invoice_id
    ) as additional_data,
    'ES_WAREHOUSE' as source,
    'Bad Debt From Invoices' as load_section,
    '{{ this.name }}' as source_model
from output
where unpaid_amount != 0
    and gl_date between '{{ live_be_start_date() }}' and '{{ live_be_end_date() }}'
