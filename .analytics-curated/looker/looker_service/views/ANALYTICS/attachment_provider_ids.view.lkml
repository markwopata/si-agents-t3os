view: attachment_provider_ids {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."ATTACHMENT_PROVIDER_IDS" ;;

  dimension: provider_id {
    type: number
    sql: ${TABLE}."PROVIDER_ID" ;;
  }
  measure: count {
    type: count
  }
}
