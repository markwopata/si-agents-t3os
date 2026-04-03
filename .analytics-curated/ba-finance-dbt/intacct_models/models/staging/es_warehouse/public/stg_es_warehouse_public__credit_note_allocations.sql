with source as (

    select * from {{ source('es_warehouse_public', 'credit_note_allocations') }}

),

renamed as (

    select

        -- ids
            credit_note_allocation_id,
            created_by_user_id,
            credit_note_id,
            invoice_id,
            allocation_type_id,
            erp_allocated_to_id,
            reversal_user_id,
            bank_account_id,
        -- strings
            reversal_reason,
            reference,
        -- numerics
            amount,
        -- booleans

        -- timestamps
            date_created,
            date_updated,
            erp_creation_date,
            _es_update_timestamp,
            reversal_date,
            date


    from source

)

select * from renamed
