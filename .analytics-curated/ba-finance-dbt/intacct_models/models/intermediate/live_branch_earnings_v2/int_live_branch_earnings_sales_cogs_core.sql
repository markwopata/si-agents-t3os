with revenue as (
    select *
    from {{ ref('int_live_branch_earnings_base_invoices') }}
    where line_item_type_id in ({{ live_be_core_sales_line_item_type_ids() }})
),

line_items_erp_refs_override as (
    select
        line_item_type_id,
        intacct_gl_account_no::varchar as account_number
    from {{ ref('int_live_branch_earnings_line_item_types') }}
)

select
    revenue.market_id,
    liero.account_number,
    revenue.transaction_number_format,
    revenue.transaction_number,
    revenue.description,
    revenue.gl_date::date as gl_date,
    revenue.document_type,
    revenue.document_number,
    revenue.url_sage,
    revenue.url_concur,
    revenue.url_admin,
    revenue.url_t3,
    revenue.nbv * -1 as amount,
    object_construct(
        'asset_id', revenue.asset_id,
        'vendor_id', revenue.vendor_id,
        'invoice_id', revenue.invoice_id,
        'line_item_id', revenue.line_item_id,
        'line_item_type_id', revenue.line_item_type_id
    ) as additional_data,
    revenue.source,
    'Core Sales COGS' as load_section,
    '{{ this.name }}' as source_model
from revenue
    inner join line_items_erp_refs_override as liero
        -- negative sign to match the line_item_type_id for cogs
        on revenue.line_item_type_id * -1 = liero.line_item_type_id
where
    (
        revenue.nbv != 0
        or
        revenue.nbv is null
    )
    and {{ live_branch_earnings_date_filter(date_field='revenue.billing_approved_date', timezone_conversion=true) }}
