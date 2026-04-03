select
    ard.pk_ar_line_id as pk_ar_detail_id,
    ard.pk_ar_line_id as fk_ar_line_id,
    ard.fk_ar_header_id,
    iff(arr.pk_ar_header_id is null, false, true) as does_header_exist,
    ard.ar_line_type,
    arr.ar_header_type,
    arr.invoice_number,
    arr.gl_date,
    arr.invoice_date,
    arr.due_date,
    arr.document_number,
    arr.description,
    arr.invoice_memo,
    arr.date_paid,
    ard.line_description,
    ard.debit_credit_sign,
    ard.line_number,
    ard.amount,
    ard.account_number,
    gla.account_name,
    arr.bank_account,
    arr.payment_method,
    ard.offset_account_number,
    gla2.account_name as offset_account_name,
    coalesce(ard.customer_id, arr.customer_id) as customer_id,
    c.customer_name,
    c.is_related_party,
    e.entity_id,
    e.entity_name,
    d.department_id,
    d.department_name,
    ard.fk_parent_ar_line_id,
    ard.secondary_line_number,
    ru.url_sage as url_invoice,
    arr.invoice_state,
    ard.fk_admin_line_item_id,
    coalesce(ard.fk_admin_asset_id, li.asset_id) as fk_admin_asset_id,
    ard.fk_admin_adj_line_item_id,
    li.line_item_type_id,
    lit.line_item_type_name,
    li.amount as admin_line_item_amount,
    li.extended_data:part_number::text as part_number,
    i.invoice_id,
    coalesce(i.billing_approved_date, cn.date_created) as billing_approved_date,
    cn.credit_note_id,
    case
        when
            i.invoice_id is not null
            then 'https://admin.equipmentshare.com/#/home/transactions/invoices/' || i.invoice_id
        when
            cn.credit_note_id is not null
            then 'https://admin.equipmentshare.com/#/home/transactions/credit-notes/' || cn.credit_note_id
    end as url_admin
from {{ ref("stg_analytics_intacct__ar_line") }} as ard
    -- This is a left join because there can be ar lines where we don't have the ar header
    left join {{ ref("stg_analytics_intacct__ar_header") }} as arr
        on ard.fk_ar_header_id = arr.pk_ar_header_id
    left join {{ ref("stg_analytics_intacct__customer") }} as c
        on coalesce(ard.customer_id, arr.customer_id) = c.customer_id
    left join {{ ref("stg_analytics_intacct__record_url") }} as ru
        on
            arr.pk_ar_header_id = ru.intacct_recordno
            and ru.intacct_object ilike 'AR%'
    left join {{ ref("stg_analytics_intacct__gl_account") }} as gla
        on ard.account_number = gla.account_number
    left join {{ ref("stg_analytics_intacct__gl_account") }} as gla2
        on ard.offset_account_number = gla2.account_number
    left join {{ ref("stg_analytics_intacct__entity") }} as e
        on ard.entity_id = e.entity_id
    left join {{ ref("stg_analytics_intacct__department") }} as d
        on ard.department_id = d.department_id
    left join {{ ref("stg_es_warehouse_public__line_items") }} as li
        on ard.fk_admin_line_item_id = li.line_item_id
    left join {{ ref("stg_es_warehouse_public__line_item_types") }} as lit
        on li.line_item_type_id = lit.line_item_type_id
    left join {{ ref("stg_es_warehouse_public__credit_note_erp_refs") }} as acr
        on ard.fk_ar_header_id = acr.fk_ar_header_id
    left join {{ ref("stg_es_warehouse_public__invoice_erp_refs") }} as air
        on ard.fk_ar_header_id = air.fk_ar_header_id
    left join {{ ref("stg_es_warehouse_public__invoices") }} as i
        on coalesce(li.invoice_id, air.invoice_id) = i.invoice_id
    left join {{ ref("stg_es_warehouse_public__credit_note_line_items") }} as cnli
        on ard.fk_admin_adj_line_item_id = cnli.credit_note_line_item_id
    left join {{ ref("stg_es_warehouse_public__credit_notes") }} as cn
        on coalesce(cnli.credit_note_id, acr.credit_note_id) = cn.credit_note_id
