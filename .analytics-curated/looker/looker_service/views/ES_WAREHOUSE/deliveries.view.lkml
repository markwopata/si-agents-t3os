view: deliveries {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."DELIVERIES"
    ;;
  drill_fields: [delivery_id]

  dimension: delivery_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."DELIVERY_ID" ;;
  }

  dimension: partial_return {
    type: number
    sql: case when ${delivery_type_id} = 5 then ${TABLE}."DELIVERY_ID" else null end;;
  }

  dimension: drop_off{
    type: number
    sql: case when ${delivery_type_id} = 1 then ${TABLE}."DELIVERY_ID" else null end;;
  }

  dimension: final_return {
    type: number
    sql: case when ${delivery_type_id} = 6 then ${TABLE}."DELIVERY_ID" else null end;;
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
    value_format_name: id
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
  dimension: completed_trailing_30 {
    type: yesno
    sql: ${completed_date} <= current_date AND ${completed_date} >= (current_date - INTERVAL '30 days') ;;
  }

  measure: completed_dropoffs_30 {
    type: count_distinct
    sql: ${delivery_id} ;;
    filters: [completed_trailing_30: "yes"
      , delivery_type_id: " 1, 3"] #dropoff types
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
    value_format_name: id
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: quantity {
    type: number
    sql:case when ${TABLE}."QUANTITY" is not null then ${TABLE}."QUANTITY" else 0 end ;;
  }

  dimension: rental_id {
    type: number
    value_format_name: id
    # hidden: yes
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

  measure: partial_return_quantity{
    type: sum
    sql: ${quantity} ;;
    #drill_fields: []
  }

  measure: count {
    type: count
    drill_fields: [delivery_id, run_name, contact_name, orders.order_id, rentals.rental_id]
  }

  measure: count_distinct_delivery_id {
    type: count_distinct
    sql: ${delivery_id} ;;
  }

  measure: count_asset_detail_drill {
    type: count
    drill_fields: [delivery_id
        , dim_companies_fleet_opt.company_name
        , asset_id
        , dim_assets_fleet_opt.asset_equipment_make
        , dim_assets_fleet_opt.asset_equipment_model_name
        , dim_assets_fleet_opt.asset_equipment_subcategory_name
        , completed_time
        , scheduled_time
        , hours_late
        ]
  }

  dimension: hours_late {
    type: number
    value_format_name: decimal_0
    sql: datediff(hour, ${scheduled_time}, ${completed_time}) ;;
  }

  dimension: delivery_lateness_distribution_buckets {
    type: string
    sql:
    case
      when ${hours_late} <= -5 then '>= 5 Hours Early'
      when ${hours_late} >= -4 and ${hours_late} <= -2 then '2 - 4 Hours Early'
      when ${hours_late} >= -1 and ${hours_late} <= 1 then '1 Hour Early - 1 Hour Late'
      when ${hours_late} >= 2 and ${hours_late} <= 4 then '2 - 4 Hours Late'
      when ${hours_late} >= 5 and ${hours_late} <= 8 then '5 - 8 Hours Late'
      when ${hours_late} >= 9 and ${hours_late} <= 12 then '9 - 12 Hours Late'
      when ${hours_late} >= 13 and ${hours_late} <= 18 then '13 - 18 Hours Late'
      when ${hours_late} >= 19 and ${hours_late} <= 24 then '19 - 24 Hours Late'
      when ${hours_late} >= 25 and ${hours_late} <= 48 then '25 - 48 Hours Late'
      when ${hours_late} >= 49 and ${hours_late} <= 72 then '49 to 72 Hours Late'
      else '>= 73 Hours Late' end;;
  }

  measure: avg_hours_late {
    type: average
    value_format_name: decimal_1
    sql: ${hours_late} ;;
  }
}
