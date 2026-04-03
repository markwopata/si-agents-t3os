with payments as (
    select *
    from {{ ref("stg_es_warehouse_public__payments") }}
),

bank_account_erp_refs as (
    select *
    from {{ ref("stg_es_warehouse_public__bank_account_erp_refs") }}
),

branch_erp_refs as (
    select *
    from {{ ref("stg_es_warehouse_public__branch_erp_refs") }}
),

payment_applications as (
    select *
    from {{ ref("stg_es_warehouse_public__payment_applications") }}
),

invoices as (
    select *
    from {{ ref("stg_es_warehouse_public__invoices") }}
),

companies as (
    select *
    from {{ ref("stg_es_warehouse_public__companies") }}
),

distinct_invoices_and_departments as (
    select distinct
        invoices.invoice_id,
        branch_erp_refs.intacct_department_id as branch_id
    from invoices
        left join branch_erp_refs
            on invoices.market_id = branch_erp_refs.branch_id
),

combined_data as (
    select
        invoices.market_id,
        invoices.invoice_id,
        invoices.invoice_no::varchar as document_number,
        'Bad Debt Write-off;'
        || ' Invoice Date: '
        || invoices.billing_approved_date::date
        || '; Invoice #: '
        || invoices.invoice_no
        || '; Customer: '
        || companies.customer_name as description,
        convert_timezone('America/Chicago', payments.payment_date)::date as gl_date,
        payment_applications.amount as payment_application_amount
    from payments
        inner join bank_account_erp_refs
            on payments.bank_account_id = bank_account_erp_refs.bank_account_id
        left join payment_applications
            on payments.payment_id = payment_applications.payment_id
        left join invoices
            on payment_applications.invoice_id = invoices.invoice_id
        left join companies
            on payments.company_id = companies.company_id
        left join distinct_invoices_and_departments
            on invoices.invoice_id = distinct_invoices_and_departments.invoice_id
    where bank_account_erp_refs.intacct_undepfundsacct in ('1205', '1206')
        and payments.status != 1 -- payment not reversed
        and distinct_invoices_and_departments.branch_id is not null
)

select
    market_id,
    'IAAA' as account_number,
    'Invoice ID' as transaction_number_format,
    invoice_id::varchar as transaction_number,
    description,
    gl_date,
    'Invoice' as document_type,
    document_number,
    null as url_sage,
    null as url_concur,
    'https://admin.equipmentshare.com/#/home/transactions/invoices/' || invoice_id as url_admin,
    null as url_t3,
    round(sum(payment_application_amount) * -0.75, 2) as amount,
    object_construct(
        'invoice_id', invoice_id
    ) as additional_data,
    'ES_WAREHOUSE' as source,
    'Bad Debt Write Off' as load_section,
    '{{ this.name }}' as source_model
from combined_data
group by all
