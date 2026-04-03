view: concur_invoice_exceptions {
  sql_table_name: "CONCUR_GOLD"."CONCUR_INVOICE_EXCEPTIONS" ;;

  dimension: exception_event {
    type: string
    sql: ${TABLE}."EXCEPTION_EVENT" ;;
  }
  dimension: exception_text {
    type: string
    sql: ${TABLE}."EXCEPTION_TEXT" ;;
  }
  dimension: fk_request_key {
    type: number
    sql: ${TABLE}."FK_REQUEST_KEY" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: is_cleared {
    type: string
    sql: ${TABLE}."IS_CLEARED" ;;
  }
  dimension: name_request {
    type: string
    sql: ${TABLE}."NAME_REQUEST" ;;
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  measure: count {
    type: count
  }
}
