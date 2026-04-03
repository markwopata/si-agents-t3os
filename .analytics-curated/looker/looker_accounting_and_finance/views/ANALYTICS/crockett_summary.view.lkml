view: crockett_summary {
  sql_table_name: "ANALYTICS"."TREASURY"."CROCKETT_SUMMARY" ;;

########## DIMENSIONS ##########

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }



  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }



  ########## MEASURES ##########

  measure: oec {
    label: "OEC"
    type: sum
    value_format_name: usd
    drill_fields: [trx_details*]
    sql: ${TABLE}."OEC" ;;
  }

  measure: oec_mm {
    label: "OEC $MM"
    type: sum
    value_format_name: decimal_1
    drill_fields: [trx_details*]
    sql: ${TABLE}."OEC"/1000000 ;;
  }

  measure: asset_count {
    type: count_distinct
    value_format_name: decimal_0
    drill_fields: [trx_details*]
    sql: ${asset_id} ;;
  }



  ########## DRILL FIELDS ##########

set: trx_details {
  fields: [asset_id,company_id,company_name,category,asset_inventory_status,oec]
}

}
