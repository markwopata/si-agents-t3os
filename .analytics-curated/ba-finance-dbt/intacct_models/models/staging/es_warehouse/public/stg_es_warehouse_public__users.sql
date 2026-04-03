with source as (
    select * from {{ source('es_warehouse_public', 'users') }}
)

, renamed as (
    select

        -- ids
        user_id,
        blockscore_id,
        employer_user_id,
        security_level_id,
        company_id,
        location_id,
        verification_status_id,
        blockscore_people_id,
        photo_id,
        link_device_push_id,
        user_type_id,
        try_to_number(nullif(replace(employee_id, 'CW', ''), '')) as employee_id,
        employee_id as raw_employee_id,
        branch_id,
        crm_contact_id,
        user_agent_id,
        universal_contact_id,

        -- strings
        lower(trim(email_address)) as email_address,
        first_name,
        last_name,
        concat(first_name,' ',last_name) as full_name,
        company_name,
        preferred_landing_page,
        bad_email_address,
        username,
        password_hash,
        description,
        middle_name,
        phone_number,
        drivers_license,
        birth_day,
        birth_year,
        birth_month,
        timezone,
        last_searched_zip_code
        -- numerics
        zip_code,
        cell_phone_number,
        xero_salesperson_account_code,
        -- booleans
        deleted as is_deleted,
        accepted_terms as is_acccepted_terms,
        approved_for_purchase_orders,
        is_salesperson,
        sms_opted_out,
        can_create_asset_financial_records,
        can_read_asset_financial_records,
        read_only,
        braintree_payment_made,
        keypad_code,
        bad_phone_number as is_bad_phone_number,
        can_access_camera,
        can_rent,
        can_grant_permissions,
        -- dates
        -- timestamps
        _es_update_timestamp,
        date_created,
        date_updated
            
    from source

)

select * from renamed
