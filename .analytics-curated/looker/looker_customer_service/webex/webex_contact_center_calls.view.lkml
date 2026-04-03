view: webex_contact_center_calls {
  # # You can specify the table name if it's different from the view name:
   sql_table_name: business_intelligence.webex.stg_webex_contact_center_call_details ;;


    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: id {
      primary_key: yes
      type: string
      sql: ${TABLE}."ID" ;;
    }

    dimension: origin {
      type: string
      sql: ${TABLE}."ORIGIN" ;;
    }

    dimension: phone_number {
      type: string
      sql: ${TABLE}."PHONE_NUMBER" ;;
    }

    dimension: abandoned_sl_count {
      type: number
      sql: ${TABLE}."ABANDONED_SL_COUNT" ;;
    }

    dimension: abandoned_type {
      type: string
      sql: ${TABLE}."ABANDONED_TYPE" ;;
    }

    dimension: agent_hangup_count {
      type: number
      sql: ${TABLE}."AGENT_HANGUP_COUNT" ;;
    }

    dimension: agent_to_dn_transfer_count {
      type: number
      sql: ${TABLE}."AGENT_TO_DN_TRANSFER_COUNT" ;;
    }

    dimension: agent_to_queue_transfer_count {
      type: number
      sql: ${TABLE}."AGENT_TO_QUEUE_TRANSFER_COUNT" ;;
    }

    dimension: agent_transfered_in_count {
      type: number
      sql: ${TABLE}."AGENT_TRANSFERED_IN_COUNT" ;;
    }

    dimension: barged_in_duration {
      type: number
      sql: ${TABLE}."BARGED_IN_DURATION" ;;
    }

    dimension: call_completed_count {
      type: number
      sql: ${TABLE}."CALL_COMPLETED_COUNT" ;;
    }

    dimension: callback_request_time {
      type: number
      sql: ${TABLE}."CALLBACK_REQUEST_TIME" ;;
    }

    dimension: callback_retry_count {
      type: number
      sql: ${TABLE}."CALLBACK_RETRY_COUNT" ;;
    }

    dimension: conference_duration {
      type: number
      sql: ${TABLE}."CONFERENCE_DURATION" ;;
    }

    dimension: connected_duration {
      type: number
      sql: ${TABLE}."CONNECTED_DURATION" ;;
    }

    dimension: consult_duration {
      type: number
      sql: ${TABLE}."CONSULT_DURATION" ;;
    }

    dimension: consult_to_ep_duration {
      type: number
      sql: ${TABLE}."CONSULT_TO_EP_DURATION" ;;
    }

    dimension_group: created_at {
      type: time
      sql: ${TABLE}."CREATED_AT" ;;
    }

    dimension_group: ended_at {
      type: time
      sql: ${TABLE}."ENDED_AT" ;;
    }

    dimension: flow_activity_name {
      type: string
      sql: ${TABLE}."FLOW_ACTIVITY_NAME" ;;
    }

    dimension: hold_duration {
      type: number
      sql: ${TABLE}."HOLD_DURATION" ;;
    }

    dimension: is_active {
      type: yesno
      sql: ${TABLE}."IS_ACTIVE" ;;
    }

    dimension: is_callback {
      type: yesno
      sql: ${TABLE}."IS_CALLBACK" ;;
    }

    dimension: is_outdial {
      type: yesno
      sql: ${TABLE}."IS_OUTDIAL" ;;
    }

    dimension: is_recording_deleted {
      type: yesno
      sql: ${TABLE}."IS_RECORDING_DELETED" ;;
    }

    dimension: ivr_ended_count {
      type: number
      sql: ${TABLE}."IVR_ENDED_COUNT" ;;
    }

    dimension: ivr_script_id {
      type: string
      sql: ${TABLE}."IVR_SCRIPT_ID" ;;
    }

    dimension: ivr_script_name {
      type: string
      sql: ${TABLE}."IVR_SCRIPT_NAME" ;;
    }

    dimension: matched_skills {
      type: string
      sql: ${TABLE}."MATCHED_SKILLS" ;;
    }

    dimension: matched_skill_name {
      type: string
      sql: ${TABLE}."MATCHED_SKILL_NAME" ;;
    }

    dimension: matched_skill_value {
      type: number
      sql: ${TABLE}."MATCHED_SKILL_VALUE" ;;
    }

    dimension: outdial_conference_count {
      type: number
      sql: ${TABLE}."OUTDIAL_CONFERENCE_COUNT" ;;
    }

    dimension: outdial_conference_duration {
      type: number
      sql: ${TABLE}."OUTDIAL_CONFERENCE_DURATION" ;;
    }

    dimension: outdial_consult_count {
      type: number
      sql: ${TABLE}."OUTDIAL_CONSULT_COUNT" ;;
    }

    dimension: outdial_consult_to_ep_duration {
      type: number
      sql: ${TABLE}."OUTDIAL_CONSULT_TO_EP_DURATION" ;;
    }

    dimension: outdial_consult_to_queue_count {
      type: number
      sql: ${TABLE}."OUTDIAL_CONSULT_TO_QUEUE_COUNT" ;;
    }

    dimension: outdial_consult_to_queue_duration {
      type: number
      sql: ${TABLE}."OUTDIAL_CONSULT_TO_QUEUE_DURATION" ;;
    }

    dimension: overflow_count {
      type: number
      sql: ${TABLE}."OVERFLOW_COUNT" ;;
    }

    dimension: paused_duration {
      type: number
      sql: ${TABLE}."PAUSED_DURATION" ;;
    }

    dimension: post_call_consult_duration {
      type: number
      sql: ${TABLE}."POST_CALL_CONSULT_DURATION" ;;
    }

    dimension: post_call_duration {
      type: number
      sql: ${TABLE}."POST_CALL_DURATION" ;;
    }

    dimension: queue_count {
      type: number
      sql: ${TABLE}."QUEUE_COUNT" ;;
    }

    dimension: queue_duration {
      type: number
      sql: ${TABLE}."QUEUE_DURATION" ;;
    }

    dimension: required_skills {
      type: string
      sql: ${TABLE}."REQUIRED_SKILLS" ;;
    }

    dimension: required_skill_name {
      type: string
      sql: ${TABLE}."REQUIRED_SKILL_NAME" ;;
    }

    dimension: required_skill_value {
      type: number
      sql: ${TABLE}."REQUIRED_SKILL_VALUE" ;;
    }

    dimension: required_skill_operand {
      type: string
      sql: ${TABLE}."REQUIRED_SKILL_OPERAND" ;;
    }

    dimension: ringing_duration {
      type: number
      sql: ${TABLE}."RINGING_DURATION" ;;
    }

    dimension: selfservice_duration {
      type: number
      sql: ${TABLE}."SELFSERVICE_DURATION" ;;
    }

    dimension: short_in_ivr_count {
      type: number
      sql: ${TABLE}."SHORT_IN_IVR_COUNT" ;;
    }

    dimension: short_in_queue_count {
      type: number
      sql: ${TABLE}."SHORT_IN_QUEUE_COUNT" ;;
    }

    dimension: terminating_end {
      type: string
      sql: ${TABLE}."TERMINATING_END" ;;
    }

    dimension: termination_reason {
      type: string
      sql: ${TABLE}."TERMINATION_REASON" ;;
    }

    dimension: termination_type {
      type: string
      sql: ${TABLE}."TERMINATION_TYPE" ;;
    }

    dimension: total_bnr_duration {
      type: number
      sql: ${TABLE}."TOTAL_BNR_DURATION" ;;
    }

    dimension: total_duration {
      type: number
      sql: ${TABLE}."TOTAL_DURATION" ;;
    }

    dimension: wrapup_duration {
      type: number
      sql: ${TABLE}."WRAPUP_DURATION" ;;
    }

    dimension: is_branch_call {
      type: yesno
      sql: ${TABLE}."IS_BRANCH_CALL" ;;
    }

    dimension_group: extraction_started_at {
      type: time
      sql: ${TABLE}."EXTRACTION_STARTED_AT" ;;
    }

    dimension_group: extraction_completed_at {
      type: time
      sql: ${TABLE}."EXTRACTION_COMPLETED_AT" ;;
    }

    set: detail {
      fields: [
        id,
        origin,
        phone_number,
        abandoned_sl_count,
        abandoned_type,
        agent_hangup_count,
        agent_to_dn_transfer_count,
        agent_to_queue_transfer_count,
        agent_transfered_in_count,
        barged_in_duration,
        call_completed_count,
        callback_request_time,
        callback_retry_count,
        conference_duration,
        connected_duration,
        consult_duration,
        consult_to_ep_duration,
        created_at_time,
        ended_at_time,
        flow_activity_name,
        hold_duration,
        is_active,
        is_callback,
        is_outdial,
        is_recording_deleted,
        ivr_ended_count,
        ivr_script_id,
        ivr_script_name,
        matched_skills,
        matched_skill_name,
        matched_skill_value,
        outdial_conference_count,
        outdial_conference_duration,
        outdial_consult_count,
        outdial_consult_to_ep_duration,
        outdial_consult_to_queue_count,
        outdial_consult_to_queue_duration,
        overflow_count,
        paused_duration,
        post_call_consult_duration,
        post_call_duration,
        queue_count,
        queue_duration,
        required_skills,
        required_skill_name,
        required_skill_value,
        required_skill_operand,
        ringing_duration,
        selfservice_duration,
        short_in_ivr_count,
        short_in_queue_count,
        terminating_end,
        termination_reason,
        termination_type,
        total_bnr_duration,
        total_duration,
        wrapup_duration,
        is_branch_call,
        extraction_started_at_time,
        extraction_completed_at_time
      ]
    }

    measure: phone_volume {
      group_label: "Webex"
      type: count_distinct
      sql: case when ${connected_duration} > 0 then ${id} end ;;
    }

    measure: avg_ring_time {
      group_label: "Webex"
      type: number
      sql: avg(${ringing_duration});;
      value_format_name: decimal_2
    }

    measure: avg_handle_time {
      group_label: "Webex"
      type: number
      sql: avg(${connected_duration} + ${hold_duration} + ${wrapup_duration});;
      value_format_name: decimal_2
    }

    measure: avg_wrap_up_time {
      group_label: "Webex"
      type: number
      sql: avg(${wrapup_duration});;
      value_format_name: decimal_2
    }

    measure: RONA {
      group_label: "Webex"
      type: count_distinct
      sql: case when ${termination_reason} = 'RONA Timer Expired' then ${id} end;;
    }

    measure: ASA {
      group_label: "Webex"
      type: number
      sql: avg(${queue_duration} + ${ringing_duration});;
      value_format_name: decimal_2
    }

    measure: abandoned_calls {
      group_label: "Webex"
      type: count_distinct
      sql: null;;
    }
  }
