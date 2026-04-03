with source as (

    select * from {{ source('es_warehouse_inventory', 'transactions') }}

),

renamed as (

    select
        -- ids
        transaction_id,
        transaction_type_id,
        transaction_status_id,
        from_id,
        to_id,
        custom_id,
        transaction_group_id,
        company_id,
        from_uuid_id,
        to_uuid_id, 

        -- strings
        created_by,
        memo,
        split_from,
        modified_by,
        transaction_id::varchar as doc_no,

        -- timestamps
        _es_update_timestamp,
        date_created,
        date_updated,
        date_completed,
        date_cancelled

    from source

)

select * from renamed
