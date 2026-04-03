view: event_coaching_library {
  sql_table_name: "ANALYTICS"."BI_OPS"."EVENT_COACHING_LIBRARY" ;;

  dimension: event_name {
    primary_key: yes
    type: string
    sql: ${TABLE}."EVENT_NAME" ;;
  }

  dimension: recommendation_1 {
    label: "Recommendation 1"
    type: string
    sql: ${TABLE}."RECOMMENDATION_1" ;;
  }

  dimension: recommendation_2 {
    label: "Recommendation 2"
    type: string
    sql: ${TABLE}."RECOMMENDATION_2" ;;
  }

  dimension: recommendation_3 {
    label: "Recommendation 3"
    type: string
    sql: ${TABLE}."RECOMMENDATION_3" ;;
  }

  measure: count {
    type: count
    drill_fields: [event_name]
  }
}
