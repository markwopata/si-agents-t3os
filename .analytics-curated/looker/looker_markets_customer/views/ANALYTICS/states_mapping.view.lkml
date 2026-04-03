view: states_mapping {
  sql_table_name: "MARKET_DATA"."STATES_MAPPING"
    ;;

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
    map_layer_name: state_map_layer
  }

  dimension: state_id {
    type: number
    sql: ${TABLE}."STATE_ID" ;;
  }

  dimension: value {
    type: number
    sql: ${TABLE}."VALUE" ;;
  }

  measure: total_value {
    type: sum
    sql: ${value};;

  }

  measure: count {
    type: count
    drill_fields: []
  }
}
