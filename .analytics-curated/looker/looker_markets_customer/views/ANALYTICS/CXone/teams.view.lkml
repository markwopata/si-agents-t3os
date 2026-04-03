# The name of this view in Looker is "Teams"
view: teams {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "CXONE_API"."TEAMS"
    ;;


  dimension: team_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TEAM_ID" ;;
  }

  dimension: _es_batch_number {
    description: "Incrementing number representing an execution of the Jenkins job."
    type: number
    sql: ${TABLE}."_ES_BATCH_NUMBER" ;;
  }

  dimension: _es_date_created {
    description: "Date the record was first pulled from the API."
    type: string
    sql: convert_timezone('America/Chicago', ${TABLE}."_ES_DATE_CREATED"::timestamp) ;;
  }

  dimension: _es_date_updated {
    description: "Date that the record was refreshed with data from the API.
    Doesn't necessarily mean that new data was added to it, just that it already existed in Snowflake and was pulled from the API again."
    type: string
    sql: convert_timezone('America/Chicago', ${TABLE}."_ES_DATE_UPDATED"::timestamp) ;;
  }

  dimension: agent_count {
    type: number
    sql: ${TABLE}."AGENT_COUNT" ;;
  }

  dimension: analytics_enabled {
    type: yesno
    sql: ${TABLE}."ANALYTICS_ENABLED" ;;
  }

  dimension: chat_threshold {
    type: number
    sql: ${TABLE}."CHAT_THRESHOLD" ;;
  }

  dimension: contact_auto_focus {
    type: yesno
    sql: ${TABLE}."CONTACT_AUTO_FOCUS" ;;
  }

  dimension: cxone_customer_authentication_enabled {
    type: yesno
    sql: ${TABLE}."CXONE_CUSTOMER_AUTHENTICATION_ENABLED" ;;
  }

  dimension: delivery_mode {
    type: string
    sql: ${TABLE}."DELIVERY_MODE" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: digital_threshold {
    type: number
    sql: ${TABLE}."DIGITAL_THRESHOLD" ;;
  }

  dimension: email_threshold {
    type: number
    sql: ${TABLE}."EMAIL_THRESHOLD" ;;
  }

  dimension: in_view_chat_enabled {
    type: yesno
    sql: ${TABLE}."IN_VIEW_CHAT_ENABLED" ;;
  }

  dimension: in_view_enabled {
    type: yesno
    sql: ${TABLE}."IN_VIEW_ENABLED" ;;
  }

  dimension: in_view_gamification_enabled {
    type: yesno
    sql: ${TABLE}."IN_VIEW_GAMIFICATION_ENABLED" ;;
  }

  dimension: in_view_lms_enabled {
    type: yesno
    sql: ${TABLE}."IN_VIEW_LMS_ENABLED" ;;
  }

  dimension: in_view_wallboard_enabled {
    type: yesno
    sql: ${TABLE}."IN_VIEW_WALLBOARD_ENABLED" ;;
  }

  dimension: is_active {
    type: yesno
    sql: ${TABLE}."IS_ACTIVE" ;;
  }

  dimension: last_update_time {
    type: string
    sql: convert_timezone('America/Chicago', ${TABLE}."LAST_UPDATE_TIME"::timestamp) ;;
  }

  dimension: max_concurrent_chats {
    type: number
    sql: ${TABLE}."MAX_CONCURRENT_CHATS" ;;
  }

  dimension: max_email_auto_parking_limit {
    type: number
    sql: ${TABLE}."MAX_EMAIL_AUTO_PARKING_LIMIT" ;;
  }

  dimension: nice_analytics_enabled {
    type: string
    sql: ${TABLE}."NICE_ANALYTICS_ENABLED" ;;
  }

  dimension: nice_audio_recording_enabled {
    type: yesno
    sql: ${TABLE}."NICE_AUDIO_RECORDING_ENABLED" ;;
  }

  dimension: nice_coaching_enabled {
    type: yesno
    sql: ${TABLE}."NICE_COACHING_ENABLED" ;;
  }

  dimension: nice_desktop_analytics_enabled {
    type: yesno
    sql: ${TABLE}."NICE_DESKTOP_ANALYTICS_ENABLED" ;;
  }

  dimension: nice_lesson_management_enabled {
    type: yesno
    sql: ${TABLE}."NICE_LESSON_MANAGEMENT_ENABLED" ;;
  }

  dimension: nice_performance_management_enabled {
    type: yesno
    sql: ${TABLE}."NICE_PERFORMANCE_MANAGEMENT_ENABLED" ;;
  }

  dimension: nice_qm_enabled {
    type: yesno
    sql: ${TABLE}."NICE_QM_ENABLED" ;;
  }

  dimension: nice_quality_optimization_enabled {
    type: yesno
    sql: ${TABLE}."NICE_QUALITY_OPTIMIZATION_ENABLED" ;;
  }

  dimension: nice_screen_recording_enabled {
    type: yesno
    sql: ${TABLE}."NICE_SCREEN_RECORDING_ENABLED" ;;
  }

  dimension: nice_shift_bidding_enabled {
    type: yesno
    sql: ${TABLE}."NICE_SHIFT_BIDDING_ENABLED" ;;
  }

  dimension: nice_speech_analytics_enabled {
    type: yesno
    sql: ${TABLE}."NICE_SPEECH_ANALYTICS_ENABLED" ;;
  }

  dimension: nice_strategic_planner_enabled {
    type: yesno
    sql: ${TABLE}."NICE_STRATEGIC_PLANNER_ENABLED" ;;
  }

  dimension: nice_survey_customer_enabled {
    type: yesno
    sql: ${TABLE}."NICE_SURVEY_CUSTOMER_ENABLED" ;;
  }

  dimension: nice_wfm_enabled {
    type: yesno
    sql: ${TABLE}."NICE_WFM_ENABLED" ;;
  }

  dimension: nice_wfo_advanced_enabled {
    type: yesno
    sql: ${TABLE}."NICE_WFO_ADVANCED_ENABLED" ;;
  }

  dimension: nice_wfo_essentials_enabled {
    type: yesno
    sql: ${TABLE}."NICE_WFO_ESSENTIALS_ENABLED" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: qm2_enabled {
    type: yesno
    sql: ${TABLE}."QM2_ENABLED" ;;
  }

  dimension: request_contact {
    type: yesno
    sql: ${TABLE}."REQUEST_CONTACT" ;;
  }

  dimension: sms_threshold {
    type: number
    sql: ${TABLE}."SMS_THRESHOLD" ;;
  }

  dimension: social_threshold {
    type: number
    sql: ${TABLE}."SOCIAL_THRESHOLD" ;;
  }

  dimension: team_lead_id {
    type: string
    sql: ${TABLE}."TEAM_LEAD_ID" ;;
  }

  dimension: team_name {
    type: string
    sql: ${TABLE}."TEAM_NAME" ;;
  }

  dimension: team_uuid {
    type: string
    sql: ${TABLE}."TEAM_UUID" ;;
  }

  # Doesn't seem to work
  dimension: total_contact_count {
    hidden: yes
    type: number
    sql: ${TABLE}."TOTAL_CONTACT_COUNT" ;;
  }

  dimension: voice_threshold {
    type: number
    sql: ${TABLE}."VOICE_THRESHOLD" ;;
  }

  dimension: wfm2_enabled {
    type: yesno
    sql: ${TABLE}."WFM2_ENABLED" ;;
  }

  dimension: wfo_enabled {
    type: yesno
    sql: ${TABLE}."WFO_ENABLED" ;;
  }

  dimension: work_item_threshold {
    type: number
    sql: ${TABLE}."WORK_ITEM_THRESHOLD" ;;
  }

  # - - - - - CUSTOM DIMENSIONS - - - - -


  # - - - - - MEASURES - - - - -

  measure: count {
    type: count
    drill_fields: [team_id, team_name, agents.count]
  }
}
