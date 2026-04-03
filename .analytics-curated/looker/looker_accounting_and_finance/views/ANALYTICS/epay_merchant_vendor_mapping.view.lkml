view: epay_merchant_vendor_mapping {
  sql_table_name: "ANALYTICS"."TREASURY"."EPAY_MERCHANT_VENDOR_MAPPING" ;;

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: merchant_name {
    type: string
    sql: ${TABLE}."MERCHANT_NAME" ;;
  }

}
