with purchase_orders as (
    select
        po.purchase_order_number,
        po.purchase_order_id,
        po.url_t3
    from {{ ref("stg_procurement_public__purchase_orders") }} as po
        inner join {{ ref('stg_analytics_public__es_companies') }} as ec
            on
                po.company_id = ec.company_id
                and ec.owned
)

select
    spd.pk_po_detail_id,
    spd.fk_po_header_id,
    spd.fk_po_line_id,
    spd.receipt_number,
    spd.vendor_invoice_number,
    spd.purchase_order_number,
    spd.document_number,
    spd.document_type,
    spd.document_name,
    spd.gl_date,
    spd.invoice_date,
    spd.quantity,
    spd.unit_price,
    spd.extended_amount,
    spd.quantity_remaining,
    spd.quantity_converted,
    spd.line_number,
    spd.item_id,
    spd.account_number,
    spd.account_name,
    spd.department_id,
    spd.department_name,
    spd.fk_expense_type_id,
    spd.expense_type,
    spd.entity_id,
    spd.entity_name,
    spd.extended_entity_name,
    spd.item_description,
    spd.item_type,
    spd.line_description,
    spd.unit_of_measure,
    spd.vendor_id,
    spd.vendor_name,
    spd.fk_sage_po_created_by_user_id,
    spd.po_state,
    spd.line_status,
    spd.document_status,
    spd.is_blanket_po,
    apr.invoice_number,
    spd.po_message,
    spd.reference,
    spd.terms,
    spd.source_document_name,
    spd.sage_po_created_by_name,
    u.user_id as fk_t3_po_created_by_user_id,
    u.first_name || ' ' || u.last_name as t3_po_created_by_name,
    u2.user_id as fk_t3_pr_created_by_user_id,
    u2.first_name || ' ' || u2.last_name as t3_pr_created_by_name,
    spd.fk_source_po_line_id,
    spd.fk_t3_purchase_order_receiver_item_id,
    coalesce(po.purchase_order_id, po2.purchase_order_id)
        as fk_t3_purchase_order_id,
    spd.fk_ap_header_id,
    spd.date_created_header,
    spd.date_updated_header,
    spd.date_created,
    spd.date_updated_line,
    spd.url_sage,
    coalesce(po.url_t3, po2.url_t3) as url_t3,
    apr.url_concur,
    poli.purchase_order_line_memo,
    case
            when spd.document_type in ('Purchase Order Entry', 'Purchase Order') then spd.document_number
            else spd.reference
        end as po_number,
    case
            when spd.document_type in ('Purchase Order Entry', 'Purchase Order') then spd.account_number
            when spd.document_type = 'Closed Purchase Order' then '2014'
            else ''
        end as line_posting_account,
    case
            when spd.document_type in ('Purchase Order Entry', 'Purchase Order') then '2014'
            when spd.document_type = 'Closed Purchase Order' then spd.account_number
            else ''
        end as line_offset_account

from {{ ref("stg_po_detail") }} as spd
    left join {{ ref("stg_es_warehouse_public__users") }} as u
        on spd.tmp_t3_po_created_by = u.user_id::text
    left join {{ ref("stg_es_warehouse_public__users") }} as u2
        on spd.tmp_t3_po_created_by = u2.user_id::text
    left join purchase_orders as po2
        on spd.tmp_po_number = po2.purchase_order_number::text
    left join {{ ref("stg_analytics_intacct__ap_header") }} as apr
        on spd.fk_ap_header_id = apr.pk_ap_header_id
    left join {{ ref("stg_procurement_public__purchase_order_receiver_items") }} pori
        on spd.fk_t3_purchase_order_receiver_item_id = pori.fk_t3_purchase_order_receiver_item_id
    left join {{ ref("stg_procurement_public__purchase_order_line_items") }} as poli
        on pori.purchase_order_line_item_id = poli.purchase_order_line_item_id
    left join purchase_orders as po
        on poli.purchase_order_line_item_id = po.purchase_order_id