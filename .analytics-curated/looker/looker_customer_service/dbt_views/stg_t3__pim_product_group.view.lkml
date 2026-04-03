view: stg_t3__pim_product_group {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__PIM_PRODUCT_GROUP" ;;

  dimension: group_name {
    type: string
    sql: ${TABLE}."GROUP_NAME" ;;
  }
  dimension: group_uom {
    type: string
    sql: ${TABLE}."GROUP_UOM" ;;
  }
  dimension: group_value {
    type: string
    sql: ${TABLE}."GROUP_VALUE" ;;
  }
  dimension: pim_product_id {
    type: string
    sql: ${TABLE}."PIM_PRODUCT_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [group_name]
  }
}
