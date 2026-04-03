with source as (

    select * from {{ source('es_warehouse_public', 'v_payout_programs') }}

),

renamed as (

    select

        -- ids
        payout_program_assignment_id,
        asset_id,
        payout_program_id,
        updated_by_user_id,
        payout_program_schedule_id,
        replaced_by_asset_id,
        payout_program_type_id,

        -- strings
        payout_program_billing_type,
        payout_program_name,
        replaced_or_removed_reason,

        -- numerics
        asset_payout_percentage,

        -- timestamps
        _es_update_timestamp,
        start_date,
        end_date

    from source

)

select * from renamed
