
view: rental_protection_plans {
  sql_table_name: es_warehouse.public.rental_protection_plans ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: rental_protection_plan_id {
    type: string
    sql: ${TABLE}."RENTAL_PROTECTION_PLAN_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: percent {
    type: number
    sql: ${TABLE}."PERCENT" ;;
    value_format_name: percent_0
  }

  dimension: expiry_date {
    type: date
    sql: ${TABLE}."EXPIRY_DATE" ;;
  }

  dimension: rental_protection_plan_type_id {
    type: string
    sql: ${TABLE}."RENTAL_PROTECTION_PLAN_TYPE_ID" ;;
  }

  dimension: created_date {
    type: date
    sql: ${TABLE}."CREATED_DATE" ;;
  }

  set: detail {
    fields: [
        _es_update_timestamp_time,
  rental_protection_plan_id,
  name,
  percent,
  expiry_date,
  rental_protection_plan_type_id,
  created_date
    ]
  }
}
