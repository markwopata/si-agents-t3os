view: customer_collector_mapping {
  sql_table_name: "ANALYTICS"."TREASURY"."CUSTOMER_COLLECTOR_MAPPING" ;;

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: customer_id {
    type: string
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }


}
