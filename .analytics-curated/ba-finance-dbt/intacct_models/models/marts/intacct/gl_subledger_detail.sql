-- Raw GL detail (no matching sub-ledger)
select
    gd.pk_gl_detail_id,
    gd.market_id,
    gd.market_name,
    gd.entry_date,
    gd.account_number,
    gd.account_name,
    gd.journal_type,
    gd.journal_transaction_number,
    gd.journal_title,
    gd.entry_description,
    round(gd.amount, 2) as gl_amount,
    gd.created_by_username,
    null as vendor_id,
    null as vendor_name,
    null as customer_id,
    null as customer_name,
    'Journal Entry' as document_type,
    'N/A' as document_number,
    gd.entry_description as line_description,
    null as quantity,
    null as unit_price,
    null as source_document_name,
    gd.url_journal,
    null as url_concur,
    null as url_invoice_sage,
    null as url_invoice_admin,
    null as url_po_sage,
    null as url_po_t3,
    gd.intacct_module,
    'gl_detail' as src
from {{ ref('gl_detail') }} as gd
where gd.intacct_module not in ('9.PO', '3.AP', '4.AR')

union all

-- PO sub-ledger
select
    gd.pk_gl_detail_id,
    gd.market_id,
    gd.market_name,
    gd.entry_date,
    gd.account_number,
    gd.account_name,
    gd.journal_type,
    gd.journal_transaction_number,
    gd.journal_title,
    gd.entry_description,
    round(gd.amount, 2) as gl_amount,
    gd.created_by_username,
    pd.vendor_id,
    pd.vendor_name,
    /* AR columns become null in PO segment */
    null as customer_id,
    null as customer_name,
    coalesce(pd.document_type, 'Journal Entry') as document_type,
    coalesce(pd.document_number, 'N/A') as document_number,
    coalesce(pd.line_description, pd_src.line_description, gd.entry_description)
        as line_description,
    pd.quantity,
    pd.unit_price,
    pd.source_document_name,
    gd.url_journal,
    /* AP fields become null here */
    null as url_concur,
    /* For PO, no invoice URL from AP/AR */
    null as url_invoice_sage,
    null as url_invoice_admin,
    pd.url_sage as url_po_sage,
    pd.url_t3 as url_po_t3,
    gd.intacct_module,
    'po_detail' as src
from {{ ref('gl_detail') }} as gd
    left join {{ ref('po_detail') }} as pd
        on gd.fk_subledger_line_id = pd.fk_po_line_id
    left join {{ ref('po_detail') }} as pd_src
        on pd.fk_source_po_line_id = pd_src.fk_po_line_id
where gd.intacct_module = '9.PO'

union all

-- AP sub-ledger
select
    gd.pk_gl_detail_id,
    gd.market_id,
    gd.market_name,
    gd.entry_date,
    gd.account_number,
    gd.account_name,
    gd.journal_type,
    gd.journal_transaction_number,
    gd.journal_title,
    gd.entry_description,
    round(gd.amount, 2) as gl_amount,
    gd.created_by_username,
    /* Vendor info from AP */
    ad.vendor_id,
    ad.vendor_name,
    /* AR columns are null here */
    null as customer_id,
    null as customer_name,
    coalesce(ad.ap_header_type, 'Journal Entry') as document_type,
    coalesce(ad.invoice_number, 'N/A') as document_number,
    coalesce(ad.line_description, gd.entry_description)
        as line_description,
    /* Quantity, Unit price generally not in AP line items */
    null as quantity,
    null as unit_price,
    ad.source_document_name,
    gd.url_journal,
    ad.url_concur,
    /* AP invoice URL */
    ad.url_invoice as url_invoice_sage,
    null as url_invoice_admin,
    null as url_po_sage,
    null as url_po_t3,
    gd.intacct_module,
    'ap_detail' as src
from {{ ref('gl_detail') }} as gd
    left join {{ ref('ap_detail') }} as ad
        on gd.fk_subledger_line_id = ad.fk_ap_line_id
where gd.intacct_module = '3.AP'

union all

-- AR sub-ledger
select
    gd.pk_gl_detail_id,
    gd.market_id,
    gd.market_name,
    gd.entry_date,
    gd.account_number,
    gd.account_name,
    gd.journal_type,
    gd.journal_transaction_number,
    gd.journal_title,
    gd.entry_description,
    round(gd.amount, 2) as gl_amount,
    gd.created_by_username,
    /* No vendor info in AR */
    null as vendor_id,
    null as vendor_name,
    ard.customer_id,
    ard.customer_name,
    coalesce(ard.ar_header_type, 'Journal Entry') as document_type,
    coalesce(ard.invoice_number, 'N/A') as document_number,
    coalesce(ard.line_description, gd.entry_description)
        as line_description,
    null as quantity,
    null as unit_price,
    null as source_document_name,
    gd.url_journal,
    null as url_concur,
    /* AR invoice URL fields */
    ard.url_invoice as url_invoice_sage,
    ard.url_admin as url_invoice_admin,
    null as url_po_sage,
    null as url_po_t3,
    gd.intacct_module,
    'ar_detail' as src
from {{ ref('gl_detail') }} as gd
    left join {{ ref('ar_detail') }} as ard
        on gd.fk_subledger_line_id = ard.fk_ar_line_id
where gd.intacct_module = '4.AR'
