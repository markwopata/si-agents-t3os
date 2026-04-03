select 
    user_key
    , user_source
    , user_id
    , user_username
    , user_deleted
    , user_is_salesperson
    , user_company_key
    , user_first_name
    , user_last_name
    , user_full_name
    , user_timezone
    , user_accepted_terms
    , user_approved_for_purchase_orders
    , user_can_access_camera
    , user_can_create_asset_financial_records
    , user_can_grant_permissions
    , user_can_read_asset_financial_records
    , user_can_rent
    , user_sms_opted_out
    , user_read_only

    , user_employee_key
    , user_is_employee
    , user_is_support_user

    , _created_recordtimestamp
    , _updated_recordtimestamp
    
from {{ ref('dim_users_bi') }}