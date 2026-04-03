view: deliveries {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."DELIVERIES";;
  drill_fields: [delivery_id]

  dimension: delivery_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."DELIVERY_ID" ;;
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
    sql: ${TABLE}."COMPLETED_DATE" ;;
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
    sql: ${TABLE}."DATE_CREATED" ;;
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
    sql: ${TABLE}."DATE_UPDATED" ;;
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
    # hidden: yes
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
    sql: ${TABLE}."SCHEDULED_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [delivery_id, contact_name, run_name, locations.location_id, locations.nickname]
  }
}
