with payments as (
    select
        payment_id,
        invoice_id,
        payment_method_type_id,
        company_id,
        bank_account_id,
        status,
        date_created,
        reference,
        amount,
        amount_remaining
    from {{ ref('stg_es_warehouse_public__payments') }}
),

invoices as (
    select invoice_id
    from {{ ref('stg_es_warehouse_public__invoices') }}
),

payment_method_types as (
    select payment_method_type_id, name
    from {{ ref('stg_es_warehouse_public__payment_method_types') }}
),

companies as (
    select company_id, customer_name
    from {{ ref('stg_es_warehouse_public__companies') }}
),

payment_applications as (
    select payment_application_id, payment_id
    from {{ ref('stg_es_warehouse_public__payment_applications') }}
),

payment_application_erp_refs as (
    select payment_application_id, intacct_active_date
    from {{ ref('stg_es_warehouse_public__payment_application_erp_refs') }}
),

erp_synced_per_payment as (
    select
        pa.payment_id,
        any_value(pae.intacct_active_date) as erp_synced
    from payment_applications pa
    left join payment_application_erp_refs pae
        on pae.payment_application_id = pa.payment_application_id
    group by pa.payment_id
),

payment_history as (
    select payment_history_id, payment_id
    from {{ ref('stg_es_warehouse_public__payment_history') }}
),

payment_refund_erp_refs as (
    select payment_history_id
    from {{ ref('stg_es_warehouse_public__payment_refund_erp_refs') }}
),

refunds_per_payment as (
    select
        ph.payment_id,
        case when count(pr.payment_history_id) > 0 then 'Yes' else 'No' end as has_refunds
    from payment_history ph
    left join payment_refund_erp_refs pr
        on pr.payment_history_id = ph.payment_history_id
    group by ph.payment_id
),

bank_account_erp_refs as (
    select bank_account_id, intacct_bank_account_id, intacct_undepfundsacct
    from {{ ref('stg_es_warehouse_public__bank_account_erp_refs') }}
),

glaccount as (
    select account_number, account_name
    from {{ ref('stg_analytics_intacct__gl_account') }}
),

billing_company_preferences as (
    select *
    from {{ ref('stg_es_warehouse_public__billing_company_preferences') }}
),

-- pmt overview --
payment_data as (
    select distinct
        p.payment_id as payment_id,
        es.erp_synced as erp_synced,
        coalesce(rp.has_refunds, 'No') as has_refunds,

        case
            when p.status = 0 then 'No Refunds and Not Reversed'
            when p.status = 1 then 'Reversed'
            when p.status = 2 then 'Partial Refund'
            when p.status = 3 then 'Fully Refunded'
            else null
        end as status,

        p.date_created as date_created,
        c.customer_name as customer,
        c.company_id as customer_id,

        -- JSON-derived + staged fields
        bcp.prefs__internal_company as is_internal_customer,

        p.reference as reference,

        case
            when baer.intacct_bank_account_id is null then gla.account_name
            when baer.bank_account_id = 55 then 'Unrecovered Warranty - Contra'
            when baer.bank_account_id = 57 then 'Warranty Pass Through'
            else baer.intacct_bank_account_id
        end as deposit_to,

        pmt.name as payment_type,
        round(p.amount, 2) as amount_received,
        p.amount_remaining as amount_remaining,

        row_number() over (
            partition by p.payment_id
            order by
                case when coalesce(rp.has_refunds, 'No') = 'Yes' then 1 else 2 end,
                p.date_created desc
        ) as row_num

    from payments p
    left join invoices i
        on p.invoice_id = i.invoice_id
    left join payment_method_types pmt
        on p.payment_method_type_id = pmt.payment_method_type_id
    left join companies c
        on p.company_id = c.company_id
    left join billing_company_preferences bcp
        on c.company_id = bcp.company_id

    -- REPLACED the 1:many joins with a 1:1 per-payment join
    left join erp_synced_per_payment es
        on es.payment_id = p.payment_id
    left join refunds_per_payment rp
        on rp.payment_id = p.payment_id

    left join bank_account_erp_refs baer
        on baer.bank_account_id = p.bank_account_id
    left join glaccount gla
        on gla.account_number = baer.intacct_undepfundsacct
)

select
    payment_id,
    customer,
    customer_id,
    is_internal_customer,
    erp_synced,
    has_refunds,
    status,
    date_created,
    reference,
    deposit_to,
    payment_type,
    amount_received,
    amount_remaining
from payment_data
where row_num = 1
order by date_created desc
