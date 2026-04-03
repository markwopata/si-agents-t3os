view: collection_targets_salesperson {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTION_TARGETS_SALESPERSON" ;;

  ################## PRIMARY KEY ##################
  dimension: salesperson_user_id {
    type: number
    primary_key: yes
    value_format_name: id
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  ################## DIMENSIONS ##################
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
    sql: case when ${collections_target} is null or ${collections_target} = 0 then ${collections_actuals.collections} - ${collections_actuals.collections} else ${collections_target} - ${collections_actuals.collections} end ;;
    value_format_name: usd_0
  }


}
