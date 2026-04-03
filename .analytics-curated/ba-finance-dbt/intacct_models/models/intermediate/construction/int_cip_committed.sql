with pd_converted as (
    select
        po_detail.fk_source_po_line_id,
        sum(quantity) as quantity
    from {{ ref("po_detail") }} as po_detail
    where po_detail.document_type != 'Purchase Order Entry'
        and po_detail.fk_source_po_line_id is not null
    group by po_detail.fk_source_po_line_id
)

select
    pd.fk_po_line_id,
    pd.document_number,
    pd.document_type,
    pd.gl_date,
    pd.account_number,
    pd.account_name,
    pd.department_id,
    try_cast(pd.department_id as int) as market_id,
    pd.department_name,
    pd.url_sage,
    pd.line_description,
    /* Extract 11-0000 style code at the very beginning; default to ZZ-9999 (unclassified) */
    coalesce(regexp_substr(pd.line_description, '^(\\w{2}-\\w{4}) :.*', 1, 1, 'i', 1), 'ZZ-9999') as division_code,
    cbdc.division_name,
    pd.quantity,
    coalesce(pd_converted.quantity, 0) as quantity_converted,
    coalesce(pd.quantity, 0) - coalesce(pd_converted.quantity, 0) as quantity_remaining,
    round((coalesce(pd.quantity, 0) - coalesce(pd_converted.quantity, 0)) * pd.unit_price, 2) as committed_amount
from {{ ref("po_detail") }} as pd
    left join pd_converted
        on pd.fk_po_line_id = pd_converted.fk_source_po_line_id
    left join {{ ref("stg_analytics_retool__cip_budget_division_codes") }} as cbdc
        on coalesce(regexp_substr(pd.line_description, '^(\\w{2}-\\w{4}) :.*', 1, 1, 'i', 1), 'ZZ-9999')
            = cbdc.division_code
where pd.document_type ilike '%purchase order entry%'
    and pd.account_number in (
        '1509', -- Construction in Progress
        '1233', -- Build-to-Suit CIP
        '1604'  -- Build-to-Suit Receivable - Receivable account for Blue Owl and Premiere
    )
    and round((coalesce(pd.quantity, 0) - coalesce(pd_converted.quantity, 0)) * pd.unit_price, 2) > 0
order by pd.fk_po_line_id
