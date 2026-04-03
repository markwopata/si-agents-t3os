{{ config(
    materialized='incremental'
    , incremental_strategy = 'merge'
    , cluster_by=['conversation_id', 'updated_at', '_fivetran_synced']
    , unique_key=['conversation_id']
    , on_schema_change='sync_all_columns'
) }}

with 

source as (

    -- deduplicate conversation_history by choosing the most recent record 
    select * 
    from {{ source('intercom', 'conversation_history') }}
    qualify row_number() over (partition by id order by updated_at desc) = 1

),

renamed as (

    select
        id as conversation_id,
        updated_at,
        created_at,
        open,
        state,
        read,
        waiting_since,
        snoozed_until,
        priority,
        title,
        source_type,
        source_id,
        source_delivered_as,
        source_subject,
        source_body,
        source_url,
        source_author_type,
        source_author_id,
        team_assignee_id,
        first_contact_reply_type,
        first_contact_reply_url,
        first_contact_reply_created_at,
        sla_name,
        sla_status,
        conversation_rating_remark,
        conversation_rating_created_at,
        conversation_rating_teammate_id,
        conversation_rating_value,
        statistics_time_to_assignment,
        statistics_time_to_admin_reply,
        statistics_time_to_first_close,
        statistics_time_to_last_close,
        statistics_median_time_to_reply,
        statistics_first_contact_reply_at,
        statistics_first_assignment_at,
        statistics_first_admin_reply_at,
        statistics_first_close_at,
        statistics_last_assignment_at,
        statistics_last_assignment_admin_reply_at,
        statistics_last_contact_reply_at,
        statistics_last_admin_reply_at,
        statistics_last_close_at,
        statistics_last_closed_by_id,
        statistics_count_reopens,
        statistics_count_assignments,
        statistics_count_conversation_parts,
        assignee_id,
        _fivetran_synced,
        custom_type,
        custom_language,
        _fivetran_start,
        _fivetran_end,
        _fivetran_active,
        custom_workflow_preview,
        custom_created_by,
        custom_default_description_,
        custom_ticket_category,
        custom_screenshots,
        custom_default_title_,
        custom_description_of_problem_,
        custom_team,
        custom_severity,
        custom_tracker_type,
        custom_asset_information_,
        custom_camera_serial_,
        custom_tracker_serial_,
        custom_tracker_camera_serial,
        custom_t_3_application,
        custom_copilot_used,
        custom_screenshot,
        ai_agent_rating,
        ai_agent_participated,
        ai_agent_source_title,
        ai_agent_last_answer_type,
        ai_agent_rating_remark,
        ai_agent_source_type,
        ai_agent_resolution_state,
        custom_ai_answer_length,
        custom_ai_tone_of_voice,
        custom_fin_ai_agent_preview,
        custom_ai_pronoun_formality,
        {{ dbt_run_started_at_formatted() }}

    from source

)
select * from renamed

{% if is_incremental() -%}

{{ get_incremental_fivetran_data() }}

{% endif -%}