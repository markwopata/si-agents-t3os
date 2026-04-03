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

  dimension: assignment_id {
    type: number
    sql: ${TABLE}."ASSIGNMENT_ID" ;;
  }

  dimension: assignment_type_id {
    type: number
    sql: ${TABLE}."ASSIGNMENT_TYPE_ID" ;;
  }

  dimension: charge {
    type: number
    sql: ${TABLE}."CHARGE" ;;
  }

  dimension: completed_by_user_id {
    type: number
    sql: ${TABLE}."COMPLETED_BY_USER_ID" ;;
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

  dimension: delivery_details {
    type: string
    sql: ${TABLE}."DELIVERY_DETAILS" ;;
  }

  dimension: delivery_status_id {
    type: number
    sql: ${TABLE}."DELIVERY_STATUS_ID" ;;
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

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: run_name {
    type: string
    sql: ${TABLE}."RUN_NAME" ;;
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

  measure: count {
    type: count
    drill_fields: [delivery_id, run_name, contact_name]
  }
}
