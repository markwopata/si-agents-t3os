-- Initial query for list of purchase orders and related apa true ups. Will union in next step. 

with ap_true_up_entries as (
    select
        split_part(gl1.entry_description, ' - ', 1) as recordno, --normally unique value unless the po line was adjusted more than once. Ex. E101674, Juice (Journal 1733 & 1736)
        gl1.journal_transaction_number as var_journal_number,
        round(sum(gl1.amount), 2) as var_posted_amount,
        gl1.entry_date as var_posted_date,
        gl1.url_journal,
        gl1.entry_description,
        gl1.fk_gl_entry_id
    from {{ ref('gl_detail') }} as gl1
    where gl1.journal_type = 'APA'
        and gl1.account_number != '2014'
        and gl1.created_by_username = 'APA_TRUE_UP'
    group by
        gl1.journal_transaction_number, gl1.entry_date, gl1.fk_gl_entry_id,
        gl1.url_journal, gl1.entry_description,
        split_part(gl1.entry_description, ' - ', 1)
)

select
    gl.fk_subledger_line_id, --fk for po line id
    gl.amount as gl_amount,
    src__po.receipt_number,
    src__po.document_name,
    0 as quantity,
    0 as unit_price,
    atue.var_posted_amount as extended_amount,
    0 as po_amount,
    0 as cpo_amount,
    atue.var_posted_amount as apa_trueup_amount,
    0 as vi_amount,
    gl.account_number as expense_account_number,
    'apa true up' as relieved_by,
    atue.var_posted_date as relieved_by_entry_date,
    0 as relieved_quantity,
    '' as closed_receipts,
    '' as bill_numbers,
    src__po.url_sage,
    atue.var_posted_date as entry_date,
    atue.url_journal,
    src__po.url_t3 as t3_cost_capture_url,
    atue.var_journal_number as journal_number,
    src__po.vendor_id,
    src__po.vendor_name,
    coalesce(src__po.line_description, '') as line_description,
    gl.department_id as mkt_id,
    po.fk_po_line_id as converting_doc_fk_po_line_id,
    concat('APA TRUE UP-', po.fk_po_line_id) as converting_doc,
    atue.recordno,
    atue.fk_gl_entry_id

from {{ ref('gl_detail') }} as gl -- gl details
    left join {{ ref('po_detail') }} as src__po -- source po details 
        on gl.fk_subledger_line_id = src__po.fk_po_line_id
            and gl.intacct_module = '9.PO'
    left join {{ ref('po_detail') }} as po -- po details
        on src__po.fk_po_line_id = po.fk_source_po_line_id
    -- Get AP variance entries posted by Sworks; inner join to keep apa entries only
    inner join ap_true_up_entries as atue
        on po.fk_po_line_id::text = atue.recordno
where 
    gl.account_number != '2014'
    and src__po.document_type in ('Purchase Order')
group by all
