view: company_to_sage_vendor_xwalk {
  sql_table_name: "INTACCT"."COMPANY_TO_SAGE_VENDOR_XWALK" ;;

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: sage_vendor_name {
    type: string
    sql: ${TABLE}."SAGE_VENDOR_NAME" ;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }
  measure: count {
    type: count
    drill_fields: [company_name, sage_vendor_name]
  }
}
