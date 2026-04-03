with po1 as (
    select
        po.*,
        coalesce(po.relieved_quantity, 0) * po.unit_price as po_amount_new,
        agg.*,
        sum(po.relieved_quantity) over (partition by po.receipt_number) as po_total_relieved_quantity,
        coalesce(sum(po.relieved_quantity)
            over (partition by po.fk_subledger_line_id), 0) as po_line_total_relieved_quantity,
        case
            when agg.po_total_quantity = po_total_relieved_quantity
                then 'po fully converted'
            when po_total_relieved_quantity = 0
                then 'po unconverted'
            when agg.po_total_quantity > po_total_relieved_quantity
                then 'po partially converted'
            when agg.po_total_quantity < po_total_relieved_quantity
                then 'po over converted'
            when po_total_relieved_quantity is null
                then 'po unconverted'
            else 'po unconverted'
        end as po_status,
        case
            when agg.po_line_total_quantity = po_line_total_relieved_quantity
                then 'po line fully converted'
            when po_line_total_relieved_quantity = 0
                then 'po line unconverted'
            when agg.po_line_total_quantity > po_line_total_relieved_quantity
                then 'po line partially converted'
            when agg.po_line_total_quantity < po_line_total_relieved_quantity
                then 'po line over converted'
            when po_line_total_relieved_quantity is null
                then 'po line unconverted'
            else 'po line unconverted'
        end as po_line_status
    from {{ ref('int_purchase_orders_po_union') }} as po
        inner join {{ ref('int_purchase_orders_po_aggregate') }} as agg on po.fk_subledger_line_id = agg.fk_po_line_id
    order by po.receipt_number desc, po.fk_subledger_line_id desc
),
po_unconverted as (
    select
        FK_SUBLEDGER_LINE_ID,
        0 as GL_AMOUNT,
        RECEIPT_NUMBER,
        DOCUMENT_NAME,
        0 as QUANTITY,
        0 as UNIT_PRICE,
        0 as PO_AMOUNT,
        0 as CPO_AMOUNT,
        0 as APA_TRUEUP_AMOUNT,
        0 as VI_AMOUNT,
        EXPENSE_ACCOUNT_NUMBER,
        'not yet relieved' as RELIEVED_BY,
        null as RELIEVED_BY_ENTRY_DATE,
        0 as RELIEVED_QUANTITY,
        null as CLOSED_RECEIPTS,
        null as BILL_NUMBERS,
        null as URL_SAGE,
        ENTRY_DATE,
        null as URL_JOURNAL,
        null as T3_COST_CAPTURE_URL,
        null as JOURNAL_NUMBER,
        VENDOR_ID,
        VENDOR_NAME,
        LINE_DESCRIPTION,
        MKT_ID,
        null as CONVERTING_DOC_FK_PO_LINE_ID,
        null as CONVERTING_DOC,
        null as RECORDNO,
        null as FK_GL_ENTRY_ID,
        coalesce(
            (avg(po1.po_line_total_quantity) over (partition by po1.fk_subledger_line_id) -
            avg(po1.po_line_total_relieved_quantity) over (partition by po1.fk_subledger_line_id) )
        , 0) * max(po1.unit_price) over (partition by po1.fk_subledger_line_id) as PO_AMOUNT_NEW,
        FK_PO_LINE_ID,
        null as PO_TOTAL_GL_AMOUNT,
        null as PO_TOTAL_QUANTITY,
        null as PO_LINE_TOTAL_QUANTITY,
        null as PO_TOTAL_RELIEVED_QUANTITY,         
        null as PO_LINE_TOTAL_RELIEVED_QUANTITY,
        PO_STATUS,
        PO_LINE_STATUS,

        (avg(po1.po_line_total_quantity) over (partition by po1.fk_subledger_line_id) -
        avg(po1.po_line_total_relieved_quantity) over (partition by po1.fk_subledger_line_id) )
        as
        qty_unconverted,
        qty_unconverted *  max(po1.unit_price) over (partition by po1.fk_subledger_line_id) as dollars_unconverted
    from po1
    where po1.po_line_status != 'po line fully converted' -- only unconverted or partially converted lines
    qualify row_number() over (
    partition by po1.fk_subledger_line_id
    order by po1.receipt_number desc, po1.fk_subledger_line_id desc
  ) = 1
    order by po1.receipt_number desc, po1.fk_subledger_line_id desc
)
select
    FK_SUBLEDGER_LINE_ID::varchar as FK_SUBLEDGER_LINE_ID,
    RECEIPT_NUMBER,
    DOCUMENT_NAME,
    QUANTITY,
    UNIT_PRICE,
    PO_AMOUNT_NEW as PO_AMOUNT,
    CPO_AMOUNT,
    APA_TRUEUP_AMOUNT,
    VI_AMOUNT,
    EXPENSE_ACCOUNT_NUMBER,
    RELIEVED_BY,
    RELIEVED_BY_ENTRY_DATE,
    RELIEVED_QUANTITY,
    CLOSED_RECEIPTS,
    BILL_NUMBERS,
    URL_SAGE,
    ENTRY_DATE,
    URL_JOURNAL,
    T3_COST_CAPTURE_URL,
    JOURNAL_NUMBER,
    VENDOR_ID,
    VENDOR_NAME,
    LINE_DESCRIPTION,
    MKT_ID,
    CONVERTING_DOC_FK_PO_LINE_ID,
    CONVERTING_DOC,
    RECORDNO,
    FK_GL_ENTRY_ID,
    FK_PO_LINE_ID,
    PO_TOTAL_GL_AMOUNT,
    PO_TOTAL_QUANTITY,
    PO_TOTAL_RELIEVED_QUANTITY,
    PO_LINE_TOTAL_QUANTITY,
    PO_LINE_TOTAL_RELIEVED_QUANTITY,
    PO_STATUS,
    PO_LINE_STATUS,
    0 as qty_unconverted, 
    0 as dollars_unconverted
from po1
union all
select
    concat(FK_SUBLEDGER_LINE_ID, '_unconverted')::varchar as FK_SUBLEDGER_LINE_ID,
    RECEIPT_NUMBER,
    DOCUMENT_NAME,
    QUANTITY,
    UNIT_PRICE,
    PO_AMOUNT_NEW as PO_AMOUNT,
    CPO_AMOUNT,
    APA_TRUEUP_AMOUNT,
    VI_AMOUNT,
    EXPENSE_ACCOUNT_NUMBER,
    RELIEVED_BY,
    RELIEVED_BY_ENTRY_DATE,
    RELIEVED_QUANTITY,
    CLOSED_RECEIPTS,
    BILL_NUMBERS,
    URL_SAGE,
    ENTRY_DATE,
    URL_JOURNAL,
    T3_COST_CAPTURE_URL,
    JOURNAL_NUMBER,
    VENDOR_ID,
    VENDOR_NAME,
    LINE_DESCRIPTION,
    MKT_ID,
    CONVERTING_DOC_FK_PO_LINE_ID,
    CONVERTING_DOC,
    RECORDNO,
    FK_GL_ENTRY_ID,
    FK_PO_LINE_ID,
    PO_TOTAL_GL_AMOUNT,
    PO_TOTAL_QUANTITY,
    PO_TOTAL_RELIEVED_QUANTITY,
    PO_LINE_TOTAL_QUANTITY,
    PO_LINE_TOTAL_RELIEVED_QUANTITY,
    PO_STATUS,
    PO_LINE_STATUS,
    QTY_UNCONVERTED,
    DOLLARS_UNCONVERTED
from po_unconverted pou