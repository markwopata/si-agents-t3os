view: crockett_base_revenue {
  sql_table_name: "ANALYTICS"."TREASURY"."CROCKETT_BASE_REVENUE" ;;

########### DIMENSIONS ###########



  dimension: asset_id {
    type: string
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
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

  dimension: line_item_type_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: lit_name {
    label: "Line Item Type Name"
    type: string
    sql: ${TABLE}."LIT_NAME" ;;
  }


  dimension: month_ {
    label: "Month"
    type: date_month
    sql: ${TABLE}."MONTH_" ;;
  }



  ########### MEASURES ###########

  measure:  base_revenue {
    type: sum
    value_format_name: usd_0
    drill_fields: [trx_details*]
    sql: ${TABLE}."AMOUNT" ;;
  }


  ########### DRILL FIELDS ###########

  set: trx_details {
    fields: [month_,asset_id,category,line_item_type_id,lit_name,base_revenue]
  }

}
