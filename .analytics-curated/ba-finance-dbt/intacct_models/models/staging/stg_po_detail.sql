{{
    config(
        materialized="table"
    )
 }}

select
    md5(pd.pk_po_header_id || '-' || pde.pk_po_line_id) as pk_po_detail_id,
    pd.pk_po_header_id as fk_po_header_id,
    pde.pk_po_line_id as fk_po_line_id,
    pd.receipt_number,
    pd.vendor_invoice_number,
    pd.purchase_order_number,
    pd.document_number,
    pd.document_type,
    pd.document_name,
    pd.gl_date,
    pd.invoice_date,
    pde.quantity,
    pde.unit_price,
    pde.extended_amount,
    pde.quantity_remaining, -- This is technically units based on the unit of measure. pde.quantity would expand out
    -- the quantity if uom != Each, but we appear to not be using anything non-Each last couple  years.
    pde.quantity_converted,
    pde.line_number,
    pde.item_id,
    coalesce(itga.account_number, iff(len(pde.item_id) = 5, right(pde.item_id,4), null)) as account_number,
    gla.account_name,
    pde.department_id,
    d.department_name,
    pde.fk_expense_type_id,
    et.expense_type,
    pde.entity_id,
    e.entity_name,
    e.extended_entity_name,
    pde.item_description,
    pde.item_type,
    pde.line_description,
    pde.unit_of_measure,
    pd.vendor_id,
    v.vendor_name,
    ui.pk_user_id as fk_sage_po_created_by_user_id,
    case
        when
            pd.t3_pr_created_by is null
            and pd.t3_po_created_by is not null
            and ui.user_description is null
            then pd.t3_po_created_by -- Cover if we can't get a match on user description - we should fix this
        else ui.user_description
    end as sage_po_created_by_name,
    pd.po_state,
    pde.line_status,
    pd.document_status,
    pd.is_blanket_po,
    pd.po_message,
    pd.reference,
    pd.terms,
    pd.source_document_name,
    pde.fk_source_po_line_id,
    pde.fk_t3_purchase_order_receiver_item_id,
    pd.fk_ap_header_id,
    pd.date_created_header,
    pd.date_updated_header,
    pde.date_created,
    -- Populated for vendor invoices
    pde.date_updated as date_updated_line,
    ru.url_sage,
    pd.tmp_po_number,
    tmp_t3_po_created_by
    from {{ ref("stg_analytics_intacct__po_header") }} as pd
    inner join {{ ref("stg_analytics_intacct__po_line") }} as pde
        on pd.document_name = pde.document_name
    left join (select
        pk_user_id,
        user_description,
        row_number()
            over (partition by user_description order by date_created desc)
            as rn
    from {{ ref("stg_analytics_intacct__user") }}
    qualify rn = 1) as ui
        on pd.t3_po_created_by = ui.user_description
    left join {{ ref("stg_analytics_intacct__record_url") }} as ru
        on
            pd.pk_po_header_id = ru.intacct_recordno
            and ru.intacct_object = 'PODOCUMENT'
    -- left join in case an item is not in their mapping
    left join {{ ref("stg_analytics_financial_systems__item_id_to_gl_account") }} as itga
        on pde.item_id = itga.item_id
    -- map from old item id to new item id
    left join {{ ref("stg_analytics_financial_systems__ogitem_to_newitem") }} as itm_trans
        on pde.item_id = itm_trans.original_item_id
    left join {{ ref("stg_analytics_intacct__gl_account") }} as gla
        on coalesce(itga.account_number, iff(len(pde.item_id) = 5, right(pde.item_id,4), null)) = gla.account_number
    left join {{ ref("stg_analytics_intacct__department") }} as d
        on pde.department_id = d.department_id
    inner join {{ ref("stg_analytics_intacct__entity") }} as e
        on pde.entity_id = e.entity_id
    -- Not all po lines have an expense line/type
    left join {{ ref("stg_analytics_intacct__expense_type") }} as et
        on pde.fk_expense_type_id = et.pk_expense_type_id
    -- Custvendid/vendor name can be null?
    left join {{ ref("stg_analytics_intacct__vendor") }} as v
        on pd.vendor_id = v.vendor_id
