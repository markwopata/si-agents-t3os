view: collection_targets_branch_district {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTION_TARGETS_BRANCH_DISTRICT" ;;


  ################## PRIMARY KEY ##################
  dimension: branch_id {
    type: number
    primary_key: yes
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  ################## DIMENSIONS ##################
  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: quarter  {
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
    sql: case when ${collections_actuals.collections} >= ${collections_target} then 0 else  ${collections_target} - ${collections_actuals.collections} end ;;
    value_format_name: usd_0
  }

}
