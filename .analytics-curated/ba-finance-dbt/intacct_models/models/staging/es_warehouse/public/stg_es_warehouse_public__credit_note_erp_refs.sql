with source as (

    select * from {{ source('es_warehouse_public', 'credit_note_erp_refs') }}

),

renamed as (

    select

        -- ids
        credit_note_erp_ref_id,
        credit_note_id,
        erp_instance_id,

        -- numerics
        intacct_record_no as fk_ar_header_id,

        -- timestamps
        reversal_date,
        _es_update_timestamp

    from source

)

select * from renamed
