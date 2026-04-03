view: agents {
  sql_table_name: "CXONE_API"."AGENTS"
    ;;

  dimension: agent_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."AGENT_ID" ;;
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

  dimension: agent_chat_threshold {
    type: number
    sql: ${TABLE}."AGENT_CHAT_THRESHOLD" ;;
  }

  dimension: agent_contact_auto_focus {
    type: yesno
    sql: ${TABLE}."AGENT_CONTACT_AUTO_FOCUS" ;;
  }

  dimension: agent_delivery_mode {
    type: string
    sql: ${TABLE}."AGENT_DELIVERY_MODE" ;;
  }

  dimension: agent_email_threshold {
    type: number
    sql: ${TABLE}."AGENT_EMAIL_THRESHOLD" ;;
  }

  dimension: agent_max_version {
    type: number
    sql: ${TABLE}."AGENT_MAX_VERSION" ;;
  }

  dimension: agent_request_contact {
    type: yesno
    sql: ${TABLE}."AGENT_REQUEST_CONTACT" ;;
  }

  dimension: agent_total_contact_count {
    type: number
    sql: ${TABLE}."AGENT_TOTAL_CONTACT_COUNT" ;;
  }

  dimension: agent_voice_threshold {
    type: number
    sql: ${TABLE}."AGENT_VOICE_THRESHOLD" ;;
  }

  dimension: agent_work_item_threshold {
    type: number
    sql: ${TABLE}."AGENT_WORK_ITEM_THRESHOLD" ;;
  }

  dimension: api_key {
    type: string
    sql: ${TABLE}."API_KEY" ;;
  }

  dimension: at_home {
    type: yesno
    sql: ${TABLE}."AT_HOME" ;;
  }

  dimension: chat_refusal_timeout {
    type: string
    sql: ${TABLE}."CHAT_REFUSAL_TIMEOUT" ;;
  }

  dimension: chat_threshold {
    type: number
    sql: ${TABLE}."CHAT_THRESHOLD" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: combined_user_name_domain {
    type: string
    sql: ${TABLE}."COMBINED_USER_NAME_DOMAIN" ;;
  }

  dimension: contact_auto_focus {
    type: yesno
    sql: ${TABLE}."CONTACT_AUTO_FOCUS" ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: country_name {
    type: string
    sql: ${TABLE}."COUNTRY_NAME" ;;
  }

  dimension: create_date {
    type: string
    sql: convert_timezone('America/Chicago', ${TABLE}."CREATE_DATE"::timestamp) ;;
  }

  dimension: crm_user_name {
    type: string
    sql: ${TABLE}."CRM_USER_NAME" ;;
  }

  dimension: custom1 {
    type: string
    sql: ${TABLE}."CUSTOM1" ;;
  }

  dimension: custom2 {
    type: string
    sql: ${TABLE}."CUSTOM2" ;;
  }

  dimension: custom3 {
    type: string
    sql: ${TABLE}."CUSTOM3" ;;
  }

  dimension: custom4 {
    type: string
    sql: ${TABLE}."CUSTOM4" ;;
  }

  dimension: custom5 {
    type: string
    sql: ${TABLE}."CUSTOM5" ;;
  }

  dimension: customer_card {
    type: string
    sql: ${TABLE}."CUSTOMER_CARD" ;;
  }

  dimension: default_dialing_pattern {
    type: string
    sql: ${TABLE}."DEFAULT_DIALING_PATTERN" ;;
  }

  dimension: default_dialing_pattern_name {
    type: string
    sql: ${TABLE}."DEFAULT_DIALING_PATTERN_NAME" ;;
  }

  dimension: delivery_mode {
    type: string
    sql: ${TABLE}."DELIVERY_MODE" ;;
  }

  dimension: digital_threshold {
    type: number
    sql: ${TABLE}."DIGITAL_THRESHOLD" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: email_refusal_timeout {
    type: string
    sql: ${TABLE}."EMAIL_REFUSAL_TIMEOUT" ;;
  }

  dimension: email_threshold {
    type: number
    sql: ${TABLE}."EMAIL_THRESHOLD" ;;
  }

  dimension: employment_type {
    type: string
    sql: ${TABLE}."EMPLOYMENT_TYPE" ;;
  }

  dimension: employment_type_name {
    type: string
    sql: ${TABLE}."EMPLOYMENT_TYPE_NAME" ;;
  }

  dimension: federated_id {
    type: string
    sql: ${TABLE}."FEDERATED_ID" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: hire_date {
    type: string
    sql: convert_timezone('America/Chicago', ${TABLE}."HIRE_DATE"::timestamp) ;;
  }

  dimension: hiring_source {
    type: string
    sql: ${TABLE}."HIRING_SOURCE" ;;
  }

  dimension: hourly_cost {
    type: string
    sql: ${TABLE}."HOURLY_COST" ;;
  }

  dimension: inactive_date {
    type: string
    sql: convert_timezone('America/Chicago', ${TABLE}."INACTIVE_DATE"::timestamp) ;;
  }

  dimension: internal_id {
    type: string
    sql: ${TABLE}."INTERNAL_ID" ;;
  }

  dimension: is_active {
    type: yesno
    sql: ${TABLE}."IS_ACTIVE" ;;
  }

  dimension: is_billable {
    type: yesno
    sql: ${TABLE}."IS_BILLABLE" ;;
  }

  dimension: is_open_id_profile_complete {
    type: yesno
    sql: ${TABLE}."IS_OPEN_ID_PROFILE_COMPLETE" ;;
  }

  dimension: is_supervisor {
    type: yesno
    sql: ${TABLE}."IS_SUPERVISOR" ;;
  }

  dimension: is_what_if_agent {
    type: yesno
    sql: ${TABLE}."IS_WHAT_IF_AGENT" ;;
  }

  dimension: issuer {
    type: string
    sql: ${TABLE}."ISSUER" ;;
  }

  dimension: last_login {
    type: string
    sql: convert_timezone('America/Chicago', ${TABLE}."LAST_LOGIN"::timestamp) ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: last_updated {
    type: string
    sql: convert_timezone('America/Chicago', ${TABLE}."LAST_UPDATED") ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: locked {
    type: yesno
    sql: ${TABLE}."LOCKED" ;;
  }

  dimension: login_authenticator_id {
    type: string
    sql: ${TABLE}."LOGIN_AUTHENTICATOR_ID" ;;
  }

  dimension: max_concurrent_chats {
    type: number
    sql: ${TABLE}."MAX_CONCURRENT_CHATS" ;;
  }

  dimension: max_email_auto_parking_limit {
    type: number
    sql: ${TABLE}."MAX_EMAIL_AUTO_PARKING_LIMIT" ;;
  }

  dimension: max_preview {
    type: yesno
    sql: ${TABLE}."MAX_PREVIEW" ;;
  }

  dimension: middle_name {
    type: string
    sql: ${TABLE}."MIDDLE_NAME" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: nt_login_name {
    type: string
    sql: ${TABLE}."NT_LOGIN_NAME" ;;
  }

  dimension: phone_refusal_timeout {
    type: string
    sql: ${TABLE}."PHONE_REFUSAL_TIMEOUT" ;;
  }

  dimension: profile_id {
    type: number
    sql: ${TABLE}."PROFILE_ID" ;;
  }

  dimension: profile_name {
    type: string
    sql: ${TABLE}."PROFILE_NAME" ;;
  }

  dimension: recording_numbers {
    type: string
    sql: ${TABLE}."RECORDING_NUMBERS" ;;
  }

  dimension: referral {
    type: string
    sql: ${TABLE}."REFERRAL" ;;
  }

  dimension: rehire_status {
    type: yesno
    sql: ${TABLE}."REHIRE_STATUS" ;;
  }

  dimension: report_to_id {
    type: string
    sql: ${TABLE}."REPORT_TO_ID" ;;
  }

  dimension: report_to_name {
    type: string
    sql: ${TABLE}."REPORT_TO_NAME" ;;
  }

  dimension: request_contact {
    type: yesno
    sql: ${TABLE}."REQUEST_CONTACT" ;;
  }

  dimension: row_number {
    type: number
    sql: ${TABLE}."ROW_NUMBER" ;;
  }

  dimension: schedule_notification {
    type: number
    sql: ${TABLE}."SCHEDULE_NOTIFICATION" ;;
  }

  dimension: send_email_notifications {
    type: yesno
    sql: ${TABLE}."SEND_EMAIL_NOTIFICATIONS" ;;
  }

  dimension: sip_user {
    type: string
    sql: ${TABLE}."SIP_USER" ;;
  }

  dimension: sms_refusal_timeout {
    type: string
    sql: ${TABLE}."SMS_REFUSAL_TIMEOUT" ;;
  }

  dimension: sms_threshold {
    type: number
    sql: ${TABLE}."SMS_THRESHOLD" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: subject {
    type: string
    sql: ${TABLE}."SUBJECT" ;;
  }

  dimension: system_domain {
    type: string
    sql: ${TABLE}."SYSTEM_DOMAIN" ;;
  }

  dimension: system_user {
    type: string
    sql: ${TABLE}."SYSTEM_USER" ;;
  }

  dimension: team_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."TEAM_ID" ;;
  }

  dimension: team_name {
    type: string
    sql: ${TABLE}."TEAM_NAME" ;;
  }

  dimension: team_uuid {
    type: string
    sql: ${TABLE}."TEAM_UUID" ;;
  }

  dimension: telephone1 {
    type: string
    sql: ${TABLE}."TELEPHONE1" ;;
  }

  dimension: telephone2 {
    type: string
    sql: ${TABLE}."TELEPHONE2" ;;
  }

  dimension: termination_date {
    type: string
    sql: convert_timezone('America/Chicago', ${TABLE}."TERMINATION_DATE"::timestamp) ;;
  }

  dimension: time_display_format {
    type: string
    sql: ${TABLE}."TIME_DISPLAY_FORMAT" ;;
  }

  dimension: time_zone {
    type: string
    sql: ${TABLE}."TIME_ZONE" ;;
  }

  dimension: time_zone_offset {
    type: string
    sql: ${TABLE}."TIME_ZONE_OFFSET" ;;
  }
  # This doesn't seem to work
  dimension: total_contact_count {
    hidden: yes
    type: number
    sql: ${TABLE}."TOTAL_CONTACT_COUNT" ;;
  }

  dimension: use_agent_time_zone {
    type: yesno
    sql: ${TABLE}."USE_AGENT_TIME_ZONE" ;;
  }

  dimension: use_team_chat_threshold {
    type: yesno
    sql: ${TABLE}."USE_TEAM_CHAT_THRESHOLD" ;;
  }

  dimension: use_team_contact_auto_focus {
    type: yesno
    sql: ${TABLE}."USE_TEAM_CONTACT_AUTO_FOCUS" ;;
  }

  dimension: use_team_delivery_mode_settings {
    type: yesno
    sql: ${TABLE}."USE_TEAM_DELIVERY_MODE_SETTINGS" ;;
  }

  dimension: use_team_digital_threshold {
    type: string
    sql: ${TABLE}."USE_TEAM_DIGITAL_THRESHOLD" ;;
  }

  dimension: use_team_email_auto_parking_limit {
    type: yesno
    sql: ${TABLE}."USE_TEAM_EMAIL_AUTO_PARKING_LIMIT" ;;
  }

  dimension: use_team_email_threshold {
    type: yesno
    sql: ${TABLE}."USE_TEAM_EMAIL_THRESHOLD" ;;
  }

  dimension: use_team_max_concurrent_chats {
    type: yesno
    sql: ${TABLE}."USE_TEAM_MAX_CONCURRENT_CHATS" ;;
  }

  dimension: use_team_request_contact {
    type: yesno
    sql: ${TABLE}."USE_TEAM_REQUEST_CONTACT" ;;
  }

  dimension: use_team_voice_threshold {
    type: yesno
    sql: ${TABLE}."USE_TEAM_VOICE_THRESHOLD" ;;
  }

  dimension: use_team_work_item_threshold {
    type: yesno
    sql: ${TABLE}."USE_TEAM_WORK_ITEM_THRESHOLD" ;;
  }

  dimension: use_teamsms_threshold {
    type: yesno
    sql: ${TABLE}."USE_TEAMSMS_THRESHOLD" ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: user_name_domain {
    type: string
    sql: ${TABLE}."USER_NAME_DOMAIN" ;;
  }

  dimension: user_type {
    type: string
    sql: ${TABLE}."USER_TYPE" ;;
  }

  dimension: voice_threshold {
    type: number
    sql: ${TABLE}."VOICE_THRESHOLD" ;;
  }

  dimension: voicemail_refusal_timeout {
    type: string
    sql: ${TABLE}."VOICEMAIL_REFUSAL_TIMEOUT" ;;
  }

  dimension: work_item_refusal_timeout {
    type: string
    sql: ${TABLE}."WORK_ITEM_REFUSAL_TIMEOUT" ;;
  }

  dimension: work_item_threshold {
    type: number
    sql: ${TABLE}."WORK_ITEM_THRESHOLD" ;;
  }

  # - - - - - CUSTOM DIMENSIONS - - - - -

  dimension: full_name {
    label: "Agent Name"
    type: string
    sql: CONCAT(${first_name}, ' ', ${last_name}) ;;
  }

  # - - - - - MEASURES - - - - -

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      full_name,
      create_date,
      last_login,
      teams.team_name
    ]
  }
}
