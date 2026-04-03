

with source as (

    select * from {{ source('rental_order_request', 'rental_requests') }}

),

renamed as (

    select
        _es_update_timestamp::TIMESTAMP_NTZ as _es_update_timestamp,

        id as rental_order_request_id,
        quote_id,
        type as rental_order_request_type,
        status,
        
        -- user details
        user_uuid as rental_request_user_id,
        user_id,
        company_id,
        branch_id,
        guest_user_request,
        po_number as po_name,

        created_at as created_date,
        updated_at as updated_date,
        deleted_at as deleted_date,

        receiver_contact_name,
        receiver_contact_phone,
        receiver_option,

        jobsite_address_id,
        get_directions_link,
        longitude,
        latitude,
        city,
        state,
        state_name,
        timezone,

        shift_id,
        shift_plan_name,
        shift_plan_description,
        shift_plan_multiplier,

        dropoff_fee,
        dropoff_option,
        delivery_fee,
        delivery_option,
        delivery_instructions,
        rpp_percentage,
        rental_protection_plan,
        rental_subtotal,
        equipment_charges,
        rpp_cost,
        taxes,
        order_total as total 

    from source

)

select * from renamed
