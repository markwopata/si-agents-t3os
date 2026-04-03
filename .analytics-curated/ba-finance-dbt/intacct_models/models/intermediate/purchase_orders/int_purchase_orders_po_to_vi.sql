-- Initial query for list of purchase orders and related documents (excluding apa true up).

select
    gl.fk_subledger_line_id, --fk for po line id, is not unique, can be duplicated if more than 1 transaction impacts each po line.
    gl.amount as gl_amount, -- gl amount for each fk_subledger_line_id, can be duplicated, unable to sum this column
    src__po.receipt_number, --po number
    src__po.document_name, --long po number
    src__po.quantity, -- po quantity, can be duplicated, unable to sum this column
    src__po.unit_price, -- po unit price for each fk_subledger_line_id
    src__po.extended_amount, --DO WE USE THIS ANYWHERE????
    sum( coalesce(src__po.quantity,0) * src__po.unit_price ) as po_amount,
    sum( case when po.document_type = 'Closed Purchase Order' then coalesce(po.quantity, 0) * coalesce(po.unit_price, 0) else 0 end) as cpo_amount, 
    0 as apa_trueup_amount,
    sum(coalesce(ap.AMOUNT,0)) as vi_amount, -- vendor invoice amount
    gl.account_number as expense_account_number, --Expense account the PO is hitting
    listagg(distinct case
        when po.document_type = 'Closed Purchase Order'
            then 'closed receipt'
        when po.document_type = 'Vendor Invoice'
            then 'invoice matched to receipt'
        when po.document_type is not null
            then 'Other Document Type - ' || po.document_type
        when po.fk_po_line_id is null then null
        else 'unknown'
    end, ',') as relieved_by, -- Docmument type the po was relieved/converted by
    po.gl_date as relieved_by_entry_date, -- Entry date for the relieved/converted document
    coalesce(sum(po.quantity), 0) as relieved_quantity, -- Quantity relieved/converted
    listagg(distinct case
        when po.document_type = 'Closed Purchase Order'
            then po.document_number
    end) as closed_receipts, -- Document number closing the remaining quantity on the po line, fk_subledger_line_id
    listagg(distinct ap.invoice_number) as bill_numbers, -- Bill/vendor invoice document number closing the remaining quantity on the po line
    po.url_sage as sage_po_url,
    gl.entry_date, -- po received date
    gl.url_journal as sage_journal_url,
    src__po.url_t3 as t3_cost_capture_url,
    gl.journal_transaction_number as journal_number,
    po.vendor_id, --vendor id
    po.vendor_name, --vendor name
    coalesce(po.line_description, '') as line_description, -- po line description
    gl.department_id as mkt_id, -- marekt/ branch/ department id
    po.fk_po_line_id as converting_doc_fk_po_line_id,
    po.document_name as converting_doc,
    null as recordno,
    gl.fk_gl_entry_id as apa_fk_gl_entry_id
from {{ ref('gl_detail') }} as gl -- gl details
    left join {{ ref('po_detail') }} as src__po -- source po details 
        on gl.fk_subledger_line_id = src__po.fk_po_line_id
            and gl.intacct_module = '9.PO' -- only for PO records
    left join {{ ref('po_detail') }} as po -- po details
        on src__po.fk_po_line_id = po.fk_source_po_line_id
    left join {{ ref('ap_detail') }} as ap -- vi details
        on ap.line_number - 1 = po.line_number
            and po.document_name = ap.source_document_name
where 
    gl.account_number != '2014' --ignoring 2014-Goods Received Not Invoiced side of the entry
    and src__po.document_type in ('Purchase Order') -- Need this to ignore CPOs
group by all
