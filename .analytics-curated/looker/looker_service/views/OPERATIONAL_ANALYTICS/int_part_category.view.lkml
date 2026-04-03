view: int_part_category {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."INT_PART_CATEGORY" ;;

  dimension: product_category {
    type: string
    sql: ${TABLE}."PRODUCT_CATEGORY" ;;
  }
  dimension: product_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PRODUCT_ID" ;;
  }
  dimension: product_type {
    type: string
    sql: ${TABLE}."PRODUCT_TYPE" ;;
  }
  measure: count {
    type: count
  }
}
