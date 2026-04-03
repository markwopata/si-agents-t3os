with invoices as (
    select * from {{ ref('ar_detail') }}
    where ar_header_type = 'arinvoice'
)

select
    -- ids
    customer_id,
    invoice_id,
    credit_note_id,
    fk_ar_line_id,
    line_item_type_id,

    -- strings
    line_item_type_name,
    ar_line_type,
    invoice_number,
    ar_header_type,
    url_admin,

    -- dates
    invoice_date
from invoices
