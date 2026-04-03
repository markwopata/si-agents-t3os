with source as (

    select * from {{ source('es_warehouse_public', 'invoice_erp_refs') }}

),

renamed as (

    select

        -- ids
        invoice_erp_ref_id,
        invoice_id,

        -- numerics
        intacct_record_no as fk_ar_header_id,
        intacct_invoice_no,

        -- timestamps
        _es_update_timestamp

    from source

)

select * from renamed
