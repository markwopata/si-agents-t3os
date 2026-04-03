select 
    safety_observation_key
    , safety_observation_id  
    , safety_observation_submission_date_key
    , safety_observation_submission_time_key
    , safety_observation_employee_key
    , safety_observation_market_key
    , safety_observation_observation_date_key
    , safety_observation_observation_time_key
    , safety_observation_observation_date_final_key
    , safety_observation_observation_time_final_key
    , observation_category
    , observation_type
    , observation_location
    , observation_description_summary
    , observation_description
    , corrective_action
    , corrective_action_type
    , corrective_action_explanation
    , requires_safety_manager_escalation
    , has_uploaded_photos

    , _created_recordtimestamp
    , _updated_recordtimestamp
    
from {{ ref('fact_safety_observation_details')}}