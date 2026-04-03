view: notification_delivery_logs {
  derived_table: {
    sql:
    SELECT * FROM ES_WAREHOUSE.PUBLIC.NOTIFICATION_DELIVERY_LOGS
    LEFT JOIN  BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ALERT_RENTAL_INFO USING(NOTIFICATION_DELIVERY_LOG_ID)
    ;;
  }

  drill_fields: [notification_delivery_log_id]

  dimension: notification_delivery_log_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."NOTIFICATION_DELIVERY_LOG_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}', CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_TZ)) ;;
  }

  dimension: asset_alert_rule_id {
    type: number
    sql: ${TABLE}."ASSET_ALERT_RULE_ID" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_TZ)) ;;
  }

  filter: date_filter {
    type: date_time
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql:convert_timezone('{{ _user_attributes['user_timezone'] }}', CAST(${TABLE}."DELIVERED_AT" AS TIMESTAMPTZ)) ;;
  }

  dimension: delivered_time_formatted {
    group_label: "HTML Format" label: "Delivered Time"
    sql: ${delivered_time} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: delivery_message {
    type: string
    sql: ${TABLE}."DELIVERY_MESSAGE" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION";;
  }

  dimension: message {
    type: string
    sql: ${TABLE}."MESSAGE" ;;
  }

  dimension: notification_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."NOTIFICATION_TYPE_ID" ;;
  }

  dimension: recipient {
    type: string
    sql: ${TABLE}."RECIPIENT" ;;
  }

  dimension: tracking_diagnostic_codes_id {
    type: number
    sql: ${TABLE}."TRACKING_DIAGNOSTIC_CODES_ID" ;;
  }

  dimension: tracking_incident_id {
    type: number
    sql: ${TABLE}."TRACKING_INCIDENT_ID" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: asset_ownership {
    type: string
    sql: ${TABLE}."ASSET_OWNERSHIP" ;;
  }

  dimension: current_status {
    type: string
    sql: ${TABLE}."CURRENT_STATUS" ;;
  }

  dimension: ordered_by {
    type: string
    sql: ${TABLE}."ORDERED_BY" ;;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension: jobsite_address {
    type: string
    sql: ${TABLE}."JOBSITE_ADDRESS" ;;
  }

  measure: count {
    type: count
    drill_fields: [assets.custom_name, users.full_name, delivered.time, notification_types.name, description]
  }
}
