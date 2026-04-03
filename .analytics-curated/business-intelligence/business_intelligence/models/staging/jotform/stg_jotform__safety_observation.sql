SELECT
    distinct
    id                                                            as safety_observation_id
    , created_at                                                  as submission_datetime
    , name_first                                                  as first_name
    , name_last                                                   as last_name
    , lower(email)                                                as employee_email
    , branch_location                                             as branch_location
    , region                                                      as region
    , COALESCE(observation_category, 'Unspecified')               as observation_category
    , observation_type                                            as observation_type
    , TO_TIMESTAMP_NTZ(observation_date)::date                    as observation_date
    , to_varchar(
        try_to_time(case 
            when regexp_like(observation_time, '^\d{2}:\d{2} [AP]M$') 
            then observation_time
            else lpad(split_part(observation_time, ':', 1), 2, '0') || ':' ||
                case
                when length(split_part(split_part(observation_time, ' ', 1), ':', 2)) = 1
                    then rpad(split_part(split_part(observation_time, ' ', 1), ':', 2), 2, '0')
                else lpad(split_part(split_part(observation_time, ' ', 1), ':', 2), 2, '0')
                end || ' ' ||
                split_part(observation_time, ' ', 2)
            end, 'HH12:MI AM'
        ), 'HH12:MI AM' 
    )                                                             as observation_time_12h
    , TIMESTAMP_NTZ_FROM_PARTS(
        TO_TIMESTAMP_NTZ(observation_date)::date,
        COALESCE(observation_time_12h, TIME '00:00:00')
    )                                                             as observation_datetime
    , COALESCE(LEAST(observation_datetime, created_at)
        , observation_datetime, created_at)                       as observation_datetime_final
    , observation_location                                        as observation_location
    , observation_description                                     as observation_description
    , TRY_PARSE_JSON(photos)::ARRAY                               as photos
    , corrective_action                                           as corrective_action
    , corrective_action_type                                      as corrective_action_type
    , corrective_action_explanation                               as corrective_action_explanation
    , IFF(safety_manager_elevation = 'Yes', true, false)          as requires_safety_manager_escalation

    -- columns unused downstream
    , form_id as _jotform_form_id
    , status as _jotform_submission_status
    , new as _jotform_submission_is_new
    , flag = 1 as _jotform_submission_is_flagged
    , notes as _jotform_submission_notes
    , updated_at as _jotform_submission_updated_at
    , workflowstatus as _jotform_workflow_status
    , isworkflowenabled as _jotform_is_workflow_enabled

FROM {{ source('jotform', 'safety_observation') }}