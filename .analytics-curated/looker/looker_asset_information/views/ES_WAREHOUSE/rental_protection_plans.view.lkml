view: rental_protection_plans {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."RENTAL_PROTECTION_PLANS" ;;
  drill_fields: [rental_protection_plan_id]

  dimension: rental_protection_plan_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_PROTECTION_PLAN_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: name {
    label: "RPP Type"
    type: string
    sql: COALESCE(${TABLE}."NAME",'None') ;;
  }
  dimension: percent {
    type: number
    sql: ${TABLE}."PERCENT" ;;
  }
  measure: count {
    type: count
    drill_fields: [rental_protection_plan_id, name]
  }
}
