view: collection_targets {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTION_TARGETS" ;;

######################### DIMENSIONS #########################

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }





  ######################### DATES #########################

  dimension: quarter {
    type: date
    sql: ${TABLE}."QUARTER" ;;
  }

  ######################### MEASURES #########################

  measure: collections_target {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."COLLECTIONS_TARGET" ;;
  }

  measure: collected {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."COLLECTED" ;;
  }

  measure: percent_collected {
    type: number
    sql: sum(${TABLE}."COLLECTED") / sum(${TABLE}."COLLECTIONS_TARGET")  ;;
  }

  measure: dso_target {
    type: number
    sql: 58 ;;
  }
}
