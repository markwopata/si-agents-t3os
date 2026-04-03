view: work_orders {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS" ;;
  drill_fields: [work_order_id]

  dimension: work_order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _work_order_id {
    type: number
    sql: ${TABLE}."_WORK_ORDER_ID" ;;
    value_format_name: id
  }
  dimension: _work_order_status_id {
    type: number
    sql: ${TABLE}."_WORK_ORDER_STATUS_ID" ;;
    value_format_name: id
  }
  dimension_group: archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."ARCHIVED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_company_id {
    type: number
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
    value_format_name: id
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/652632/service/inspections" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: billing_notes {
    type: string
    sql: ${TABLE}."BILLING_NOTES" ;;
  }
  dimension: billing_type_id {
    type: number
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
    value_format_name: id
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }
  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
  }
  dimension: creator_user_id {
    type: number
    sql: ${TABLE}."CREATOR_USER_ID" ;;
    value_format_name: id
  }
  dimension: customer_user_id {
    type: number
    sql: ${TABLE}."CUSTOMER_USER_ID" ;;
    value_format_name: id
  }
  dimension_group: date_billed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_BILLED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension_group: due {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: formatted_description {
    type: string
    sql: ${TABLE}."FORMATTED_DESCRIPTION" ;;
  }
  dimension: hours_at_service {
    type: number
    sql: ${TABLE}."HOURS_AT_SERVICE" ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: location_and_access_instructions {
    type: string
    sql: ${TABLE}."LOCATION_AND_ACCESS_INSTRUCTIONS" ;;
  }
  dimension: mileage_at_service {
    type: number
    sql: ${TABLE}."MILEAGE_AT_SERVICE" ;;
  }
  dimension: requesting_user_id {
    type: number
    sql: ${TABLE}."REQUESTING_USER_ID" ;;
    value_format_name: id
  }
  dimension_group: scheduled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."SCHEDULED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: service_company_id {
    type: number
    sql: ${TABLE}."SERVICE_COMPANY_ID" ;;
    value_format_name: id
  }
  dimension: severity_level_id {
    type: number
    sql: ${TABLE}."SEVERITY_LEVEL_ID" ;;
    value_format_name: id
  }
  dimension: severity_level_name {
    type: string
    sql: ${TABLE}."SEVERITY_LEVEL_NAME" ;;
  }
  dimension: site_point_of_contact {
    type: string
    sql: ${TABLE}."SITE_POINT_OF_CONTACT" ;;
  }
  dimension: solution {
    type: string
    sql: ${TABLE}."SOLUTION" ;;
  }
  dimension: urgency_level_id {
    type: number
    sql: ${TABLE}."URGENCY_LEVEL_ID" ;;
    value_format_name: id
  }
  dimension: urgency_level_name {
    type: string
    sql: ${TABLE}."URGENCY_LEVEL_NAME" ;;
  }
  dimension: work_order_status_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_STATUS_ID" ;;
    value_format_name: id
  }
  dimension: work_order_status_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS_NAME" ;;
  }
  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
    value_format_name: id
  }
  dimension: work_order_type_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_TYPE_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  work_order_id,
  work_order_type_name,
  severity_level_name,
  work_order_status_name,
  urgency_level_name,
  work_order_originators.count
  ]
  }

}
