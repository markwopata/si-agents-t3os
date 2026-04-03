with revenue as (
    select r.*
    from {{ ref('int_live_branch_earnings_base_invoices') }} as r
),

credit_notes as (
    select
        c.credit_note_number,
        c.date_created,
        cnli.line_item_id,
        cnli.credit_note_line_item_id,
        cnli.credit_revenue,
        c.credit_note_id,
        c.memo,
        li.line_item_type_id
    from {{ ref('stg_es_warehouse_public__credit_notes') }} as c
        inner join {{ ref('stg_es_warehouse_public__credit_note_line_items') }} as cnli
            on c.credit_note_id = cnli.credit_note_id
        inner join {{ ref("stg_es_warehouse_public__line_items") }} as li
            on cnli.line_item_id = li.line_item_id
    where c.credit_note_status_id = 2
),

output as (

    select
        revenue.market_id,
        revenue.account_number,
        'Invoice ID | Line Item ID | Credit Note # | Credit Note Line Item ID' as transaction_number_format,
        revenue.invoice_id || ' | ' || revenue.line_item_id || ' | '
        || credit_notes.credit_note_number || ' | ' || credit_notes.credit_note_line_item_id as transaction_number,
        case
            when revenue.asset_id is null
                then
                    'Asset ID: ' || ' || Credit Note #: ' || credit_notes.credit_note_number
            else
                'Asset ID: ' || revenue.asset_id || ' || Credit Note #: ' || credit_notes.credit_note_number
        end as description,
        convert_timezone('America/Chicago', credit_notes.date_created)::date as gl_date,
        'Credit Note' as document_type,
        credit_notes.credit_note_number::varchar as document_number,
        revenue.url_sage,
        revenue.url_concur,
        'https://admin.equipmentshare.com/#/home/transactions/credit-notes/'
        || credit_notes.credit_note_id as url_admin,
        revenue.url_t3,
        credit_notes.credit_revenue * -1 as amount,
        object_construct(
            'asset_id', revenue.asset_id,
            'vendor_id', revenue.vendor_id,
            'invoice_id', revenue.invoice_id,
            'line_item_id', revenue.line_item_id,
            'line_item_type_id', revenue.line_item_type_id,
            'memo', credit_notes.memo,
            'credit_note_number', credit_notes.credit_note_number,
            'credit_note_id', credit_notes.credit_note_id
        ) as additional_data,
        revenue.source,
        'Admin Credit Notes' as load_section,
        '{{ this.name }}' as source_model
    from revenue
        inner join credit_notes
            on revenue.line_item_id = credit_notes.line_item_id
    where {{ live_branch_earnings_date_filter(date_field='credit_notes.date_created', timezone_conversion=true) }}
)

select * from output

union all

select
    market_id,
    account_number,
    transaction_number_format,
    transaction_number,
    'Trade In Offset || ' || description as description,
    gl_date,
    document_type,
    document_number,
    url_sage,
    url_concur,
    url_admin,
    url_t3,
    amount * -1 as amount,
    additional_data,
    source,
    load_section,
    source_model
from output
where additional_data:memo ilike any ('%trade in%', '%trade-in%')
    and additional_data:memo not ilike '%rebill%'
