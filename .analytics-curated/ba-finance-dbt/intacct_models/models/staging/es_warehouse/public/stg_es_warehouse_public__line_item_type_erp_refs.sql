with source as (

    select * from {{ source('es_warehouse_public', 'line_item_type_erp_refs') }}

),

renamed as (

    select

        -- ids
        line_item_type_erp_ref_id,
        line_item_type_id,
        erp_instance_id,

        -- numerics
        intacct_gl_account_no,

        -- timestamps
        _es_update_timestamp

    from source

)

select * from renamed
