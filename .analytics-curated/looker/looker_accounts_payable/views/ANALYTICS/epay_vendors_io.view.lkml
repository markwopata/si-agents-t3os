
view: epay_vendors_io {
  sql_table_name: "ANALYTICS"."TREASURY"."EPAY_VENDORS_IO" ;;

  dimension: epay_status {
    label: "Epay Status"
    type: string
    sql: ${TABLE}."EPAY_STATUS"  ;;

  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

}
