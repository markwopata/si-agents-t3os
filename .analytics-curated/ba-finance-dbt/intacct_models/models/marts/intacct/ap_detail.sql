select
    apl.pk_ap_line_id as pk_ap_detail_id,
    apl.pk_ap_line_id as fk_ap_line_id,
    aph.pk_ap_header_id as fk_ap_header_id,
    apl.ap_line_type,
    aph.ap_header_type,
    aph.invoice_number,
    aph.gl_date,
    aph.invoice_date,
    aph.due_date,
    aph.document_number,
    aph.description,
    aph.description2,
    aph.source_document_name,
    aph.invoice_memo,
    apl.line_description,
    apl.debit_credit_sign,
    apl.line_number,
    apl.amount,
    apl.account_number,
    gla.account_name,
    aph.financial_entity,
    aph.bank_account,
    aph.payment_type,
    apl.offset_account_number,
    gla2.account_name as offset_account_name,
    v.vendor_id,
    v.vendor_name,
    v.is_related_party as vendor_is_related_party,
    apl.customer_id,
    c.customer_name,
    c.is_related_party as customer_is_related_party,
    e.entity_id,
    e.entity_name,
    d.department_id,
    d.department_name,
    apl.fk_expense_type_id,
    et.expense_type,
    apl.item_id,
    right(coalesce(new_item.item_id, apl.item_id), 4) as expense_account_number,
    apl.fk_parent_ap_line_id,
    apl.secondary_line_number,
    aph.invoice_state,
    ru.url_sage as url_invoice,
    aph.url_concur,
    aph.fk_created_by_user_id,
    u_c.username as created_by_username,
    u_c.user_description as created_by_name,
    aph.fk_updated_by_user_id,
    u_m.username as updated_by_username,
    u_m.user_description as updated_by_name
from {{ ref("stg_analytics_intacct__ap_line") }} as apl
    inner join {{ ref("stg_analytics_intacct__ap_header") }} as aph
        on apl.fk_ap_header_id = aph.pk_ap_header_id
    left join {{ ref("stg_analytics_intacct__vendor") }} as v
        on aph.vendor_id = v.vendor_id
    left join {{ ref("stg_analytics_intacct__customer") }} as c
        on apl.fk_customer_id = c.pk_customer_id
    left join {{ ref("stg_analytics_intacct__record_url") }} as ru
        on
            aph.pk_ap_header_id = ru.intacct_recordno
            and ru.intacct_object ilike 'AP%'
    left join {{ ref("stg_analytics_intacct__gl_account") }} as gla
        on apl.account_number = gla.account_number
    left join {{ ref("stg_analytics_intacct__gl_account") }} as gla2
        on apl.offset_account_number = gla2.account_number
    left join {{ ref("stg_analytics_intacct__entity") }} as e
        on apl.fk_entity_id = e.pk_entity_id
    left join {{ ref("stg_analytics_intacct__department") }} as d
        on apl.department_id = d.department_id
    left join {{ ref("stg_analytics_intacct__user") }} as u_c
        on aph.fk_created_by_user_id = u_c.pk_user_id
    left join {{ ref("stg_analytics_intacct__user") }} as u_m
        on aph.fk_updated_by_user_id = u_m.pk_user_id
    -- Not all ap lines have an expense line/type
    left join {{ ref("stg_analytics_intacct__expense_type") }} as et
        on apl.fk_expense_type_id = et.pk_expense_type_id
    left join {{ ref("stg_analytics_financial_systems__ogitem_to_newitem") }} as new_item
        on apl.item_id = new_item.original_item_id
