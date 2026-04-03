with source as (
    select * from {{ source('analytics_intacct', 'po_header') }}
),

renamed as (
    select
        -- ids
        recordno as pk_po_header_id,
        custvendid as vendor_id,
        docid as document_name,
        prrecordkey as fk_ap_header_id,

        -- strings
        docno as document_number,
        docparid as document_type,

        -- Populated for vendor invoices
        case
            when document_type in ('Purchase Order', 'Closed Purchase Order') then document_number
        end as receipt_number,

        case
            when document_type in ('Vendor Invoice') then document_number
        end as vendor_invoice_number,

        case
            when document_type in ('purchase order entry') then document_number
        end as purchase_order_number,

        state as po_state,
        status as document_status,
        message as po_message,
        ponumber as reference,
        term_name as terms,
        createdfrom as source_document_name,
        t3_po_created_by,
        t3_pr_created_by,
        split_part(t3_po_created_by, ' - ', 1) as tmp_t3_po_created_by,

        -- numerics
        split_part(document_number, '-', 1) as tmp_po_number,

        -- booleans
        blanket_po as is_blanket_po,

        -- dates

        case
            when document_type = 'Vendor Invoice' then whenposted
            else whencreated
        end as gl_date,

        case
            when document_type = 'Vendor Invoice' then whencreated
        end as invoice_date, -- gl is gl_date for VI, whencreated should be the intended gl date for receipts

        -- timestamps
        whencreated as document_date,
        auwhencreated as date_created_header,
        whenmodified as date_updated_header,
        ddsreadtime as dds_read_timestamp,
        _es_update_timestamp
    from source
)

select * from renamed
