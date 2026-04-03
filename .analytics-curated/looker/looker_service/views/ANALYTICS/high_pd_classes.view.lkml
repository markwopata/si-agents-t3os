view: high_pd_classes {
  sql_table_name: "ANALYTICS"."RATE_ACHIEVEMENT"."HIGH_PD_CLASSES" ;;

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: equipment_class_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: tier1_per_hour {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."TIER1_PER_HOUR" ;;
  }
  dimension: tier2_per_hour {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."TIER2_PER_HOUR" ;;
  }
  dimension: tier3_per_hour {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."TIER3_PER_HOUR" ;;
  }
  measure: count {
    type: count
  }
}
