{{
    config(
        materialized='incremental'
        ,unique_key = 'id'
    )
}}
WITH webex_calls AS (
    SELECT 
        cct.id,
        cct.origin,
        m.phone_number,
        cct.abandoned_sl_count,
        cct.abandoned_type,
        cct.agent_hangup_count,
        cct.agent_to_dn_transfer_count,
        cct.agent_to_queue_transfer_count,
        cct.agent_transfered_in_count,
        cct.barged_in_duration,
        cct.call_completed_count,
        cct.callback_request_time,
        cct.callback_retry_count,
        cct.conference_duration,
        cct.connected_duration,
        cct.consult_duration,
        cct.consult_to_ep_duration,
        TO_TIMESTAMP_NTZ(cct.created_time / 1000) AS created_at,
        TO_TIMESTAMP_NTZ(cct.ended_time / 1000) AS ended_at,
        cct.flow_activity_name,
        cct.hold_duration,
        cct.is_active,
        cct.is_callback,
        cct.is_outdial,
        cct.is_recording_deleted,
        cct.ivr_ended_count,
        cct.ivr_script_id,
        cct.ivr_script_name,
        cct.matched_skills,
        cct.matched_skill_name,
        cct.matched_skill_value,
        cct.outdial_conference_count,
        cct.outdial_conference_duration,
        cct.outdial_consult_count,
        cct.outdial_consult_to_ep_duration,
        cct.outdial_consult_to_queue_count,
        cct.outdial_consult_to_queue_duration,
        cct.overflow_count,
        cct.paused_duration,
        cct.post_call_consult_duration,
        cct.post_call_duration,
        cct.queue_count,
        cct.queue_duration,
        cct.required_skills,
        cct.required_skill_name,
        cct.required_skill_value,
        cct.required_skill_operand,
        cct.ringing_duration,
        cct.selfservice_duration,
        cct.short_in_ivr_count,
        cct.short_in_queue_count,
        cct.terminating_end,
        cct.termination_reason,
        cct.termination_type,
        cct.total_bnr_duration,
        cct.total_duration,
        cct.wrapup_duration,
        CASE 
            WHEN m.phone_number is not null THEN TRUE
            ELSE FALSE
        END AS is_branch_call,
        cct.process_start_timestamp AS extraction_started_at,
        cct.process_end_timestamp   AS extraction_completed_at

    FROM {{ref('platform', 'inbound__webex__contact_center_task_details')}} AS cct
    LEFT JOIN {{ref('platform', 'es_warehouse__public__markets')}} AS m
        ON RIGHT(REGEXP_REPLACE(m.phone_number, '[^0-9]', ''), 10) = 
           RIGHT(REGEXP_REPLACE(cct.origin::STRING, '[^0-9]', ''), 10)
        AND m.phone_number IS NOT NULL
        AND TRIM(m.phone_number) <> ''
)
SELECT * FROM webex_calls

{% if is_incremental() %}

  WHERE webex_calls.extraction_completed_at > (
    SELECT COALESCE(MAX(extraction_completed_at), '1900-01-01') 
    FROM {{ this }}
  )
{% endif %}