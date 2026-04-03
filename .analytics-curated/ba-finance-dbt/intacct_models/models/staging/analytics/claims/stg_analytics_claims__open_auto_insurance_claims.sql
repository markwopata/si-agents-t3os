with source as (

    select * from {{ source('analytics_claims', 'open_auto_insurance_claims') }}

),

renamed as (

    select

        -- ids
        asset_number as asset_id,
        market_id,
        driver_employee_id as employee_id,

        -- numerics
        total_amount_due_from_3_p::int as total_due_from_third_party,
        amount_collected_from_3_p::int as amount_collected_from_third_party,
        total_amount_payable_by_htd_cvl_es_::int as total_due_from_ES,
        amount_htd_cvl_es_paid_::int as amount_paid_by_ES,
        asset_year,

        -- strings
        asset_model,
        asset_make,
        serial,
        plate_ as license_plate,
        general_manager,
        file_notes,
        repair_invoice_ as repair_invoice,
        location as market_name,
        driver_name as driver_full_name,
        driver_type,
        at_fault_payer,
        diary_last_action_taken as last_action_taken,
        es_vehicle_damage,
        status,
        status_comments,
        google_drive as google_drive_link,

        -- boolean
        material_loss_::boolean as is_material_loss,

        -- dates
        date_of_loss::date as date_of_loss,
        last_action_date::date as last_action_taken_date,
        repair_date::date as repair_date,

        -- timestamps
        _fivetran_synced

    from source

)

select * from renamed
where date_of_loss is not null --exclude break lines in Excel Sheet
