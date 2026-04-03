view: payments_vendor_mapping {
  sql_table_name: "ANALYTICS"."TREASURY"."PAYMENTS_VENDOR_MAPPING"
    ;;

  dimension: tag {
    type: string
    sql: ${TABLE}."TAG" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [vendor_name]
  }
}
