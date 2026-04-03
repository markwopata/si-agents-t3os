with invoices as (
    select * from {{ ref('stg_es_warehouse_public__invoices') }}
),

purchase_orders as (
    select * from {{ ref('stg_es_warehouse_public__purchase_orders') }}
),

orders as (
    select * from {{ ref('stg_es_warehouse_public__orders') }}
),

markets as (
    select * from {{ ref('stg_es_warehouse_public__markets') }}
),

billing_providers as (
    select * from {{ ref('stg_es_warehouse_public__billing_providers') }}
),

billing_company_preferences as (
    select * from {{ ref('stg_es_warehouse_public__billing_company_preferences') }}
)

select
    i.invoice_no,
    i.invoice_id,
    i.order_id,
    i.date_created,
    i.billing_approved_date,
    i.paid_date,
    i.company_id,

    -- JSON-derived + staged fields
    bcp.prefs__internal_company as is_internal_company,

    m.market_name,
    po.name as reference,

    i.billed_amount,
    i.owed_amount,
    i.tax_amount,
    i.public_note as invoice_memo,

    i.billing_provider_id,
    bp.name as billing_provider_name

from invoices i
left join purchase_orders po
    on i.purchase_order_id = po.purchase_order_id
left join orders o
    on o.order_id = i.order_id
left join markets m
    on m.market_id = o.market_id
left join billing_providers bp
    on i.billing_provider_id = bp.billing_provider_id
left join billing_company_preferences bcp
    on i.company_id = bcp.company_id

order by i.date_created desc
