view: crockett_hard_down {
  sql_table_name: "ANALYTICS"."TREASURY"."CROCKETT_HARD_DOWN" ;;

############ DIMENSIONS ############

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }


  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
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

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }


  ############ MEASURES ############
  measure: asset_count {
    type: count_distinct
    value_format_name: decimal_0
    drill_fields: [trx_details*]
    sql: ${asset_id} ;;
  }

  measure: oec {
    label: "OEC"
    type: sum
    value_format_name: usd_0
    drill_fields: [trx_details*]
    sql: ${TABLE}."OEC" ;;
  }



  ########## DRILL FIELDS ##########

  set: trx_details {
    fields: [asset_id,date,company_id,company_name,asset_inventory_status,oec]
  }

}
