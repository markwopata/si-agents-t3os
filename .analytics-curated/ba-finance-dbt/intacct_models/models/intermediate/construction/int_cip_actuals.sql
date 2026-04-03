{{
    config(
        materialized='view'
    )
}}
with markets as (
    select distinct market_id from {{ ref("int_cip_budgets") }}
)

select
    gd.pk_gl_detail_id,
    gd.market_id::int as market_id,
    gd.market_name,
    coalesce(cec2.division_code, 'ZZ-9999') as division_code,
    coalesce(bdc2.division_name, 'UNCLASSIFIED') as division_name,
    coalesce(cp.project_id, -1) as project_id,
    coalesce(cp.project_code, 'NO PROJECT') as project_code,
    round(sum(gd.gl_amount), 2) as actual_amount,
    gd.entry_date,
    gd.journal_type,
    gd.journal_transaction_number,
    gd.journal_title,
    gd.entry_description,
    gd.created_by_username,
    gd.vendor_id,
    gd.vendor_name,
    gd.document_type,
    gd.document_number,
    gd.line_description,
    gd.source_document_name,
    case when gd.source_document_name ilike '%Purchase Order-%'
            then split_part(gd.source_document_name, 'Purchase Order-', -1)
        when gd.source_document_name ilike '%Purchase Order Entry-%'
            then split_part(gd.source_document_name, 'Purchase Order Entry-', -1)
        when gd.src = 'ap_detail'
            then gd.document_number
        else gd.source_document_name
    end as originating_po_number,
    gd.url_journal,
    gd.url_concur,
    gd.url_invoice_sage,
    gd.url_po_sage,
    gd.url_po_t3,
    cec2.date_created,
    cec2.created_by,
    cec2.date_updated,
    cec2.updated_by,
    gd.account_number,
    gd.account_name
from {{ ref("gl_subledger_detail") }} as gd
    left join {{ ref("stg_analytics_retool__cip_expense_classifications") }} as cec2
        on gd.pk_gl_detail_id = cec2.pk_gl_detail_id
    left join {{ ref("stg_analytics_retool__cip_budget_division_codes") }} as bdc2
        on cec2.division_code = bdc2.division_code
    left join {{ ref("stg_analytics_retool__cip_accounting_categories") }} as cac
        on cec2.accounting_category_id = cac.accounting_category_id
    left join {{ ref("stg_analytics_retool__cip_projects") }} as cp
        on cec2.project_id = cp.project_id
    inner join markets as m -- Only list actuals that have related market with a budget
        on gd.market_id = m.market_id
where
    -- Keep rows with a market_id or a project_id
    (cp.project_id is not null or m.market_id is not null)
    and gd.account_number in (
        '1509', -- Construction in Progress
        '1233', -- Build-to-Suit CIP
        '1604' -- Build-to-Suit Receivable - Receivable account for Blue Owl and Premiere
    )
    -- Exclude Reimbursements (this is when accounting reclasses the expense out to blue owl)
    --  - and Placed In Service (this is when accounting capitalizes the asset)
    -- out of CIP
    and (
        not cac.accounting_category_name in ('Reimbursement', 'Placed In Service')
        or cac.accounting_category_name is null
    )
    and gd.market_id is not null
group by all
