with source as (

    select * from {{ source('es_warehouse_public', 'branch_erp_refs') }}

),

renamed as (

    select

        -- ids
        branch_erp_refs_id,
        branch_id,
        erp_instance_id,
        intacct_department_id,
        intacct_location_id,

        -- timestamps
        _es_update_timestamp

    from source

)

select * from renamed
