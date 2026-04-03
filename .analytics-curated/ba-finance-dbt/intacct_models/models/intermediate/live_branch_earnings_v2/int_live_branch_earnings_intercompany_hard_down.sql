with invoices as (
    select
        i.invoice_id,
        i.billing_approved_date,
        i.market_id,
        i.purchase_order_id
    from {{ ref("stg_es_warehouse_public__invoices") }} as i
        inner join {{ ref('market') }} as m
            on i.market_id = m.child_market_id
    where
        i.billing_approved_date >= '{{ live_be_start_date() }}'
        and i.billing_approved_date <= current_date
        and i.company_id = 1854
        and m.market_name ilike any ('%hard down%', '%landmark%') -- Hard down and landmark markets
),

line_items as (
    select
        line_item_id,
        line_item_type_id,
        invoice_id,
        amount,
        asset_id
    from {{ ref("stg_es_warehouse_public__line_items") }}
    where amount != 0
),

intercompany_line_item_mapping as (
    select
        account_number,
        line_item_type_id
    from {{ ref("seed_intercompany_line_item_account_mapping") }}
),

gl_accounts as (
    select
        account_number,
        account_name
    from {{ ref("stg_analytics_intacct__gl_account") }}
),

plexi_bucket_mapping as (
    select
        revexp,
        display_name,
        "GROUP",
        sort_group,
        sage_gl
    from {{ ref("stg_analytics_gs__plexi_bucket_mapping") }}
),

purchase_orders as (
    select
        purchase_order_id,
        name,
        coalesce(
            try_cast(regexp_substr(name, '\\(([^)]+)\\)', 1, 1, 'ie', 1) as number),
            try_cast(regexp_substr(name, '"([^"]+)', 1, 1, 'ie', 1) as number)
        ) as po_market_id
    from {{ ref("stg_es_warehouse_public__purchase_orders") }}
    where name not ilike '%billed from track%' and po_market_id is not null
),

output as (
    select
        case
            when plexi_bucket_mapping.revexp = 'REV'
                then invoices.market_id
            when plexi_bucket_mapping.revexp = 'EXP'
                then purchase_orders.po_market_id
        end as adjusted_market_id,
        gl_accounts.account_number,
        'Invoice ID | Line Item Id | REVEXP' as transaction_number_format,
        invoices.invoice_id
        || '|'
        || line_items.line_item_id
        || '|'
        || plexi_bucket_mapping.revexp as transaction_number,
        'Invoice ID: '
        || invoices.invoice_id
        || ' ;Line Item ID: '
        || line_items.line_item_id
        || ' ;From Branch ID: '
        || invoices.market_id::varchar
        || ' ;To Branch ID: '
        || coalesce(
            regexp_substr(purchase_orders.name, '\\(([^)]+)\\)', 1, 1, 'ie', 1)::number,
            regexp_substr(purchase_orders.name, '"([^"]+)', 1, 1, 'ie', 1)::number
        ) as description,
        invoices.billing_approved_date::date as gl_date,
        'Line Item Id' as document_type,
        line_items.line_item_id::varchar as document_number,
        '' as url_sage,
        '' as url_concur,
        'https://admin.equipmentshare.com/#/home/transactions/invoices/'
        || invoices.invoice_id as url_admin,
        '' as url_t3,
        iff(plexi_bucket_mapping.revexp = 'REV', line_items.amount, line_items.amount * -1) as amount,
        object_construct(
            'asset_id', line_items.asset_id,
            'invoice_id', invoices.invoice_id,
            'line_item_id', line_items.line_item_id
        ) as additional_data,
        'ES_WAREHOUSE' as source,
        'Intercompany Hard Down' as load_section,
        '{{ this.name }}' as source_model
    from invoices
        inner join line_items on invoices.invoice_id = line_items.invoice_id
        inner join
            intercompany_line_item_mapping
            on line_items.line_item_type_id = intercompany_line_item_mapping.line_item_type_id
        left join
            gl_accounts
            on intercompany_line_item_mapping.account_number::varchar = gl_accounts.account_number::varchar
        left join
            plexi_bucket_mapping
            on intercompany_line_item_mapping.account_number::varchar = plexi_bucket_mapping.sage_gl::varchar
        inner join purchase_orders on invoices.purchase_order_id = purchase_orders.purchase_order_id
),

filter_out_missing_offset as (  -- Filter out the missing offsetting line items
    select document_number
    from output
    qualify count(document_number) over (partition by document_number) = 2
)

select
    adjusted_market_id::varchar as market_id,
    * exclude (adjusted_market_id)
from output
where document_number in (select fomo.document_number from filter_out_missing_offset as fomo)
