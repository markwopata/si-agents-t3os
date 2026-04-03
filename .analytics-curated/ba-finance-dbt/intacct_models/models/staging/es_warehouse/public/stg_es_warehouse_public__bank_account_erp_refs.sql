with source as (

    select * from {{ source('es_warehouse_public', 'bank_account_erp_refs') }}

),

renamed as (

    select
        -- ids
        bank_account_erp_refs_id,
        bank_account_id,
        erp_instance_id,
        intacct_bank_account_id,
        intacct_location_id,

        -- strings
        intacct_undepfundsacct,

        -- timestamps
        _es_update_timestamp

    from source

)

select * from renamed
