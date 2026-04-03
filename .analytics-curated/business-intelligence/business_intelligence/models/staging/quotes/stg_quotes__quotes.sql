with 

source as (

    select * from {{ source('quotes', 'quote') }}

),

renamed as (

    select
        id as quote_id,

        branch_id,

        customer_id as quote_customer_id,
        company_id,
        nullif(trim(company_name), '') as company_name,
        nullif(trim(new_company_name), '') as new_company_name,
        contact_id as quote_contact_user_id,
        nullif(trim(contact_email), '') as quote_contact_email,
        nullif(trim(contact_name), '') as quote_contact_name,
        nullif(trim(contact_phone), '') as quote_contact_phone_number,
        
        created_by as quote_created_by,
        created_date,

        CAST(delivery_fee AS NUMBER(18,2)) AS delivery_fee,
        delivery_mileage,
        delivery_type_id,
        delivery_type_name as delivery_type,
        deliver_to,
        deliver_to_address,
        deliver_to_latitude,
        deliver_to_longitude,
        escalation_id as quote_escalation_id,
        has_pdf,
        is_tax_exempt,
        last_modified_by as updated_by,
        last_modified_date as updated_date,
        location_description,
        location_id,
        missed_rental_reason as missed_quote_reason,
        missed_rental_reason_other as missed_quote_reason_other,
        new_location_info,
        ordered_by,
        ordered_by_email,
        ordered_by_phone,
        order_created_by,
        order_created_date,
        order_id,
        CAST(pickup_fee AS NUMBER(18,2)) AS pickup_fee,
        CAST(po_id as NUMBER) as po_id,  
        po_name,
        project_type,
        quote_number,
        rpp_id,
        rpp_name,
        rsp_company_id,
        sales_rep_id as salesperson_user_id,
        sales_tax_percentage,
        site_contact_name,
        site_contact_phone,
        start_date as requested_start_datetime,
        end_date as requested_end_datetime,
        expiry_date as expiration_datetime,
        state_specific_tax_percentage,
        request_source_id,
        duplicated_from_quote_id,

        _es_update_timestamp

    from source

)

select * from renamed
