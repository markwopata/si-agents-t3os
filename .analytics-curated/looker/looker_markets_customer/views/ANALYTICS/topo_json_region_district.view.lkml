view: topo_json_region_district {
  sql_table_name: "MARKET_DATA"."TOPO_JSON_REGION_DISTRICT"
    ;;

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: id {
    type: number
    sql: ${TABLE}."ID" ;;
    map_layer_name: region_layer
  }

  measure: amount_measure {
    type: average
    sql: ${id} ;;
  }


  measure: count {
    type: count
    drill_fields: [id]
  }
}
