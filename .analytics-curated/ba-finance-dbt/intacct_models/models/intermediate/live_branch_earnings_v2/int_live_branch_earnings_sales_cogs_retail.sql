with line_items_erp_refs_override as (
    select
        line_item_type_id,
        override_gl_account_no
    from {{ ref('seed_line_item_erp_refs_override') }}
),

missing_asset_new_used_flag as (
    select
        invoice_id,
        sum(case
            when type_of_sale ilike '%new%' then 1
            else 0
        end) as new_sale,
        sum(case
            when type_of_sale ilike '%used%' then 1
            else 0
        end) as used_sale,
        (case when new_sale >= used_sale then 'new'
            else 'used'
        end) as new_used
    from {{ ref('retail_sales_quotes') }}
    where is_current = true
    group by all
),

base_invoices as (
    select
        market_id,
        invoice_id,
        asset_id,
        max(line_item_type_id) as line_item_type_id
    from {{ ref('int_live_branch_earnings_base_invoices') }}
    where line_item_type_id in ({{ live_be_retail_sales_line_item_type_ids() }}) -- restrict to retail sales line items
    group by all
)

select
    coalesce(bi.market_id, ld.market_id) as market_id,
    (case
        when ld.line_type in ('rebate', 'discount') then '6101'
        when liero.override_gl_account_no::varchar is not null then liero.override_gl_account_no::varchar
        when nu.new_used = 'new' then 'GBAA'
        when nu.new_used = 'used' then 'GBBA'
        else 'GBAA'
    end) as account_number,
    'Invoice ID | PK ID' as transaction_number_format,
    i.invoice_id || '|' || ld.pk_id as transaction_number,
    (case
        when ld.line_type is not null
            then 'Cost Type: ' || ld.line_type || ' || '
                ||  {{ be_live_build_description([
             {'key': 'Invoice #','field': 'i.invoice_no'},
             {'key': 'Asset ID','field': 'ld.asset_id'},
             {'key': 'Customer','field': 'c.customer_name'}
         ]) }}
        else {{ be_live_build_description([
             {'key': 'Invoice #','field': 'i.invoice_no'},
             {'key': 'Asset ID','field': 'ld.asset_id'},
             {'key': 'Customer','field': 'c.customer_name'}
         ]) }}
    end) as description,
    i.billing_approved_date::date as gl_date,
    'Invoice' as document_type,
    i.invoice_id::varchar as document_number,
    null as url_sage,
    null as url_concur,
    null as url_admin,
    null as url_t3,
    ld.amount,
    object_construct(
        'asset_id', ld.asset_id,
        'invoice_id', i.invoice_id
    ) as additional_data,
    null as source,
    'Retail Sales COGS' as load_section,
    '{{ this.name }}' as source_model
from {{ ref('retail_sales_line_detail') }} as ld
    inner join {{ ref('retail_sales_quotes') }} as q on ld.quote_pk_id = q.quote_pk_id
    left join missing_asset_new_used_flag as nu on ld.invoice_id = nu.invoice_id
    left join {{ ref('stg_es_warehouse_public__invoices') }} as i on ld.invoice_id = i.invoice_id
    left join {{ ref("stg_es_warehouse_public__companies") }} as c on i.company_id = c.company_id
    left join
        base_invoices
            as bi
        on ld.invoice_id = bi.invoice_id
            and ld.asset_id = bi.asset_id
    left join line_items_erp_refs_override as liero
        -- negative sign to match the line_item_type_id for cogs
        on bi.line_item_type_id * -1 = liero.line_item_type_id
where ld.cost_revenue = 'cost'
    and ld.is_current = true
    and ld.status = 'complete'
    and ld.line_type not ilike '%t3%' -- remove t3 expenses from BE
    and {{ live_branch_earnings_date_filter(date_field='i.billing_approved_date', timezone_conversion=true) }}
    and q.type_of_sale != 'rpo' -- remove RPO sales 
