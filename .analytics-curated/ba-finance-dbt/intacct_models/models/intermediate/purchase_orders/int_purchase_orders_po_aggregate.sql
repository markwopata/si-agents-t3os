--Calculate aggregates for the unioned model. Used to determine if po line/po is fully converted.

select
    po.fk_po_line_id,
    sum(gl.amount) over (partition by receipt_number) as po_total_gl_amount,
    sum(po.quantity) over (partition by receipt_number) as po_total_quantity,
    sum(po.quantity) over (partition by fk_subledger_line_id) as po_line_total_quantity,
    sum(gl.amount) over (partition by fk_subledger_line_id) as po_line_gl_amount
from {{ ref('gl_detail') }} as gl -- gl details
    inner join {{ ref('po_detail') }} as po -- po details 
        on gl.fk_subledger_line_id = po.fk_po_line_id
            and gl.intacct_module = '9.PO'
where
    gl.account_number != '2014'
    and po.document_type = 'Purchase Order'
