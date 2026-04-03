with source as (

    select * from {{ source('es_warehouse_public', 'assets') }}

),

renamed as (

    select

        -- ids
        asset_id,
        asset_type_id,
        company_id,
        tracker_id,
        asset_settings_id,
        photo_id,
        time_fence_id,
        equipment_make_id,
        market_id,
        maintenance_group_id,
        camera_id,
        elog_device_id,
        analog_to_digital_fuel_level_curve_id,
        category_id,
        location_id,
        equipment_condition_id,
        equipment_model_id,
        service_branch_id,
        inventory_branch_id,
        rental_branch_id,
        battery_voltage_type_id,
        equipment_class_id,
        service_provider_company_id,
        dot_number_id,

        -- strings
        custom_name,
        description,
        model,
        name,
        driver_name,
        serial_number,
        vin,
        make,
        license_plate_number,
        asset_class,
        'https://admin.equipmentshare.com/#/home/assets/asset/' || asset_id as url_admin,
        'https://app.estrack.com/#/assets/all/asset/' || asset_id as url_t3,

        -- numerics
        year,
        payout_percentage,
        price_per_hour,
        price_per_day,
        price_per_week,
        price_per_month,
        purchase_price,
        weight_lbs,
        hours,
        odometer,
        total_fuel_used_liters,
        total_idle_fuel_used_liters,
        total_idle_seconds,

        -- booleans
        deleted as is_deleted,
        available_for_rent as is_available_for_rent,
        weekly_minimum as is_weekly_minimum,
        elogs_certified as is_elogs_certified,
        placed_in_service as is_placed_in_service,
        available_to_rapid_rent as is_available_to_rapid_rent,

        -- dates
        date_created,
        date_updated,

        -- timestamps
        _es_update_timestamp

    from source

)

select * from renamed
