SELECT
    company_key
    , created_by_employee_user_key
    , salesperson_user_key
    , credit_specialist_user_key
    , created_date_key
    , received_date_key
    , completed_date_key

    , credit_application_camr_id
    , credit_application_status
    , credit_application_type
    , credit_application_source
    , credit_application_notes 

    , duns 
    , fein 
    , sic 
    , naics_primary 
    , naics_secondary 
    
    , has_insurance_info
    , coi_received
    , insurance_company
    , insurance_email
    , insurance_phone

    , credit_safe_no
    , is_government_entity
    , has_online_app_status
    , is_salesperson_override
    , is_initial_web_self_signup
    , is_initial_web_unauthenticated
    , unauthenticated_dot_com_app_id

    , _created_recordtimestamp
    , _updated_recordtimestamp 

FROM {{ ref('fact_credit_applications') }}