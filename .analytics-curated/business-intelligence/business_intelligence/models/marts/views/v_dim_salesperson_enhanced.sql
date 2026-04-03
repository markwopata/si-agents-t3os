SELECT  
    salesperson_key
    , user_id
    , user_is_deleted
    , employee_id
    , employee_email_current
    , name_current
    , date_hired_current
    , date_rehired_current
    , date_terminated_current
    , has_salesperson_title
    , salesperson_jurisdiction
    , worker_type_current

    , market_division_name_hist
    , market_id_hist
    , market_name_hist
    , market_region_hist
    , market_region_name_hist
    , market_district_hist
    , employee_title_hist
    , position_effective_date_hist
    , employee_status_hist
    
    , first_salesperson_date
    , first_TAM_date
    
    , direct_manager_employee_id_current
    , direct_manager_name_current
    , direct_manager_user_id_current
    , direct_manager_email_address_current
    
    , _valid_from
    , _valid_to
    , _is_current
    , _created_recordtimestamp
    , _updated_recordtimestamp

from {{ ref('dim_salesperson_enhanced') }}