with invoices as (
    select
        invoices.invoice_id,
        invoices.market_id,
        invoices.billing_approved_date,
        invoices.invoice_no,
        invoices.company_id,
        companies.customer_name
    from {{ ref('stg_es_warehouse_public__invoices') }} as invoices
        left join {{ ref("stg_es_warehouse_public__companies") }} as companies
            on invoices.company_id = companies.company_id
),

retail_sales_invoices as (
    select distinct invoice_id
    from {{ ref('retail_sales_quotes') }}
    where is_current = true
        and status = 'complete'
),

line_items as (
    select
        invoice_id,
        line_item_id,
        amount,
        asset_id,
        line_item_type_id
    from {{ ref('stg_es_warehouse_public__line_items') }}
    where amount != 0
),

output as (
    select
        i.market_id,
        ilbelit.intacct_gl_account_no::varchar as account_number,
        'Invoice ID | Line Item ID' as transaction_number_format,
        i.invoice_id || '|' || li.line_item_id as transaction_number,
        {{ be_live_build_description([
            {'key': 'Invoice #','field': 'i.invoice_no'},
            {'key': 'Asset ID','field': 'li.asset_id'},
            {'key': 'Customer','field': 'i.customer_name'}
        ]) }} as description,
        i.billing_approved_date as gl_date,
        'Invoice' as document_type,
        i.invoice_id::varchar as document_number,
        null as url_sage,
        null as url_concur,
        null as url_admin,
        null as url_t3,
        li.amount,
        li.asset_id,
        null as vendor_id,
        null as source,
        'int_live_branch_earnings_base_invoices' as load_section,
        coalesce(nbv.nbv,{{ calculate_nbv('aa.original_equipment_cost',
                                          'aa.asset_type',
                                          'aa.first_rental_date',
                                          'aa.purchase_date',
                                            'aa.date_created',
                                            'i.billing_approved_date') }}) as nbv,
        li.line_item_type_id,
        i.invoice_id,
        li.line_item_id,
        i.billing_approved_date,
        aa.is_rerent_asset
    from line_items as li
        inner join invoices as i
            on li.invoice_id = i.invoice_id
        inner join {{ ref("int_live_branch_earnings_line_item_types") }} as ilbelit
            on li.line_item_type_id = ilbelit.line_item_type_id
        left join {{ ref('stg_es_warehouse_public__assets_aggregate') }} as aa
            on li.asset_id = aa.asset_id
        left join {{ ref('int_live_branch_earnings_asset4000_nbv') }} as nbv
            on li.asset_id = nbv.asset_id and date_trunc(month, i.billing_approved_date) = nbv.join_date
        left join retail_sales_invoices as rsi
            on li.invoice_id = rsi.invoice_id
    where (
        i.company_id not in ({{ es_companies() }})
        or (i.company_id in ({{ es_companies() }}) and i.market_id = 1 and li.line_item_type_id = 8)
    ) -- excludes the ES companies

    and (
        li.line_item_type_id not in ({{ live_be_retail_sales_line_item_type_ids() }})
        or (li.line_item_type_id in ({{ live_be_retail_sales_line_item_type_ids() }}) and rsi.invoice_id is not null)
    )

)

select * from output
