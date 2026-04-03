with rev_credit_sum as (
-- When running sum of credits meets or exceeds revenue, triggers a COGS credit reversal.
    select
        (case
            when credit_note_line_item_id is not null then 'credit'
            else 'rev'
        end) as source,
        invoice_id,
        asset_id,
        sum(amount) as running_sum
    from {{ ref('int_admin_invoice_and_credit_line_detail') }}
    where (
        line_item_type_id in ({{ live_be_core_sales_line_item_type_ids() }})
        or line_item_type_id in ({{ live_be_retail_sales_line_item_type_ids() }})
    )
    group by all
),

dealership_cogs_max_asset as ( -- For joining COGS from retail sales app data, need to fill in for empty asset_ids
    select
        invoice_id,
        max(asset_id) as max_asset_id
    from {{ ref('retail_sales_assets') }}
    where is_current = true
        and invoice_id is not null
    group by all
),

dealership_rev_cogs_sum as (
-- Fills in missing assetIDs with the max for the invoice, this will tie any missing attachments to their asset
    select
        ld.invoice_id,
        (case
            when (ld.asset_id = 0 or ld.asset_id is null) then ma.max_asset_id
            else ld.asset_id
        end) as asset_id,
        sum(ld.amount) as amount
    from {{ ref('retail_sales_line_detail') }} as ld
        left join dealership_cogs_max_asset as ma on ld.invoice_id = ma.invoice_id
    where ld.cost_revenue = 'cost'
        and ld.is_current = true
        and ld.invoice_id is not null
    group by all
),

max_credit_note as (
-- If multiple credits are paid out, only want to create offsetting entry on the last credit paid out for an invoice/asset combo
    select
        additional_data:invoice_id::number as invoice_id,
        additional_data:asset_id::number as asset_id,
        max(additional_data:credit_note_id) as max_credit_note_id
    from {{ ref('int_live_branch_earnings_credits') }}
    where amount != 0
        and (additional_data:memo not ilike '%trade in%' and additional_data:memo not ilike '%trade-in%')
    group by all
)

select
    c.market_id,
    liero.override_gl_account_no::varchar as account_number,
    c.transaction_number_format,
    c.transaction_number,
    c.description,
    c.gl_date,
    'Invoice' as document_type,
    c.additional_data:invoice_id as document_number,
    c.url_sage,
    c.url_concur,
    c.url_admin,
    c.url_t3,
    (case
        when c.additional_data:line_item_type_id in ({{ live_be_retail_sales_line_item_type_ids() }})
            and drc.amount is not null then -drc.amount
        else coalesce(nbv.nbv,{{ calculate_nbv('aa.original_equipment_cost',
                                               'aa.asset_type', 'aa.first_rental_date',
                                               'aa.purchase_date',
                                               'aa.date_created',
                                               'i.billing_approved_date') }})
    end) as amount,
    c.additional_data,
    c.source,
    'Sales COGS Credits' as load_section,
    '{{ this.name }}' as source_model
from {{ ref('int_live_branch_earnings_credits') }} as c
    inner join max_credit_note as mcn
        on c.additional_data:credit_note_id = mcn.max_credit_note_id
            and c.additional_data:invoice_id::number = mcn.invoice_id
            and c.additional_data:asset_id::number = mcn.asset_id
    left join {{ ref('seed_line_item_erp_refs_override') }} as liero
        on c.additional_data:line_item_type_id * -1 = liero.line_item_type_id
    left join {{ ref ('stg_es_warehouse_public__invoices') }} as i
        on c.additional_data:invoice_id::number = i.invoice_id
    left join {{ ref('stg_es_warehouse_public__assets_aggregate') }} as aa
        on c.additional_data:asset_id::number = aa.asset_id
    left join {{ ref('int_live_branch_earnings_asset4000_nbv') }} as nbv
        on c.additional_data:asset_id::number = nbv.asset_id
            and date_trunc(month, i.billing_approved_date) = nbv.join_date
    left join dealership_rev_cogs_sum as drc
        on c.additional_data:invoice_id::number = drc.invoice_id
            and c.additional_data:asset_id::number = drc.asset_id
    left join rev_credit_sum as rs
        on c.additional_data:invoice_id::number = rs.invoice_id
            and c.additional_data:asset_id::number = rs.asset_id
            and rs.source = 'rev'
    left join rev_credit_sum as cs on c.additional_data:invoice_id::number = cs.invoice_id
        and c.additional_data:asset_id::number = cs.asset_id
        and cs.source = 'credit'
where abs(cs.running_sum) >= abs(rs.running_sum)
    and c.amount != 0
    and (c.additional_data:memo not ilike '%trade in%' and c.additional_data:memo not ilike '%trade-in%')
    and (
        c.additional_data:line_item_type_id in ({{ live_be_core_sales_line_item_type_ids() }})
        or c.additional_data:line_item_type_id in ({{ live_be_retail_sales_line_item_type_ids() }})
    )
