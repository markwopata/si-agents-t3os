view: deliveries {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."DELIVERIES"
    ;;
  drill_fields: [delivery_id]

  dimension: delivery_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."DELIVERY_ID" ;;
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_condition_snapshot_id {
    type: number
    sql: ${TABLE}."ASSET_CONDITION_SNAPSHOT_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: charge {
    type: number
    sql: ${TABLE}."CHARGE" ;;
  }

  dimension_group: completed {
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
    sql: CAST(${TABLE}."COMPLETED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}."CONTACT_NAME" ;;
  }

  dimension: contact_phone_number {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_NUMBER" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: delivery_company_id {
    type: number
    sql: ${TABLE}."DELIVERY_COMPANY_ID" ;;
  }

  dimension: delivery_creation_type_id {
    type: number
    sql: ${TABLE}."DELIVERY_CREATION_TYPE_ID" ;;
  }

  dimension: delivery_status_id {
    type: number
    sql: ${TABLE}."DELIVERY_STATUS_ID" ;;
  }

  dimension: delivery_type_id {
    type: number
    sql: ${TABLE}."DELIVERY_TYPE_ID" ;;
  }

  dimension: domain_id {
    type: number
    sql: ${TABLE}."DOMAIN_ID" ;;
  }

  dimension: driver_user_id {
    type: number
    sql: ${TABLE}."DRIVER_USER_ID" ;;
  }

  dimension: facilitator_type_id {
    type: number
    sql: ${TABLE}."FACILITATOR_TYPE_ID" ;;
  }

  dimension: facilitator_type {
    type: string
    sql: case when ${facilitator_type_id} = 1 then 'In House'
              when ${facilitator_type_id} = 2 then 'Outside Hauler'
              else 'Customer'
              end;;
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: origin_location_id {
    type: number
    sql: ${TABLE}."ORIGIN_LOCATION_ID" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: run_name {
    type: string
    sql: ${TABLE}."RUN_NAME" ;;
  }

  dimension: delivery_id_text {
    group_label: "Delivery ID Text"
    label: "Delivery ID"
    type: string
    sql: ${TABLE}."DELIVERY_ID" ;;
  }

  dimension_group: scheduled {
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
    sql: CAST(${TABLE}."SCHEDULED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: scheduled_formatted {
    group_label: "Formatted Dates"
    label: "Scheduled Date"
    type: date_time
    datatype: datetime
    sql: ${scheduled_time} ;;
    html: {{ value | date: "%b %-d, %Y %I:%M %p" }} ;;
  }

  dimension: requested_return {
    type: date
    sql:  case
          when ${delivery_status_id} = 1
          and ${delivery_type_id} IN (6, 4, 5) then ${scheduled_raw} else null end;;
  }

  measure: count {
    type: count
    drill_fields: [delivery_id, run_name, contact_name]
  }
}
