view: collection_targets_collector {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTION_TARGETS_COLLECTOR" ;;

  ################## PRIMARY KEY ##################
  dimension: collector {
    type: string
    primary_key: yes
    sql: ${TABLE}."COLLECTOR" ;;
  }

  ################## DIMENSIONS ##################
  dimension: quarter {
    type: string
    sql: ${TABLE}."QUARTER" ;;
  }

 ################## MEASURES ##################
  measure: collections_target {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."COLLECTIONS_TARGET" ;;
  }

  measure: amount_to_be_collected {
    type: number
    sql: ${collections_target} - ${collections_actuals.collections} ;;
    value_format_name: usd_0
  }

}
